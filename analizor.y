%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <unordered_set>
#include <vector>
#include <sstream>

/* functii si variabile expuse de flex/bison */
extern int yylex();
extern int yylineno;
extern FILE* yyin;
void yyerror(const char* s);

/* fisierul in care scriem codul asm generat */
FILE* gAsmOut = nullptr;

/* tabel de simboluri: variabile declarate */
static std::unordered_set<std::string> gVarSet;

/* lista de variabile pentru a le declara in segmentul data */
static std::vector<std::string> gVars;

/* buffer pentru codul din segmentul code (start:) */
static std::ostringstream gCode;

/* helper: adauga o linie in codul asm (cu indentare) */
static void linie(const std::string& s) { gCode << "    " << s << "\n"; }

/* declara o variabila; daca exista deja, oprim cu eroare */
static void declara_variabila(const std::string& name) {
    if (gVarSet.count(name)) {
        std::fprintf(stderr,
                     "Eroare semantica (linia %d): variabila '%s' este deja declarata.\n",
                     yylineno, name.c_str());
        std::exit(1);
    }
    gVarSet.insert(name);
    gVars.push_back(name);
}

/* verifica daca variabila a fost declarata inainte de utilizare */
static void cere_declarata(const std::string& name) {
    if (!gVarSet.count(name)) {
        std::fprintf(stderr,
                     "Eroare semantica (linia %d): variabila '%s' nu este declarata.\n",
                     yylineno, name.c_str());
        std::exit(1);
    }
}

/* scrie in fisier un program asm complet (data + code + exit) */
static void scrie_asm_complet() {
    /* antet asm32 compatibil cu nasm -fobj si alink */
    std::fprintf(gAsmOut,
        "bits 32\n\n"
        "global start\n\n"
        "extern exit\n"
        "import exit msvcrt.dll\n\n"
        "extern scanf\n"
        "import scanf msvcrt.dll\n\n"
        "extern printf\n"
        "import printf msvcrt.dll\n\n"
        "segment data use32 class=data\n"
        "    fmt_in  db \"%%d\", 0\n"
        "    fmt_out db \"%%d\", 10, 0\n\n"
    );

    /* declaram toate variabilele din program */
    for (const auto& v : gVars) {
        std::fprintf(gAsmOut, "    %s dd 0\n", v.c_str());
    }

    /* inceput segment de cod */
    std::fprintf(gAsmOut,
        "\n"
        "segment code use32 class=code\n"
        "start:\n"
    );

    /* scriem codul generat pe parcursul parsarii */
    std::fputs(gCode.str().c_str(), gAsmOut);

    /* terminam programul cu exit(0) */
    std::fprintf(gAsmOut,
        "\n"
        "    push dword 0\n"
        "    call [exit]\n"
    );
}
%}

/* union clasic: number pentru constante, sval pentru id (char*) */
%union {
    int ival;
    char* sval;
}

/* token-uri pentru sintaxa "c++ like" */
%token INT CIN COUT
%token SHR SHL

/* valori asociate token-urilor */
%token <sval> ID
%token <ival> NUMBER

/* simbolul de start */
%start program

%%

/* program = lista de instructiuni; la final scriem asm-ul */
program
    : lista_stmt { scrie_asm_complet(); }
    ;

/* lista de instructiuni (una sau mai multe) */
lista_stmt
    : stmt
    | stmt lista_stmt
    ;

/* tipuri de instructiuni acceptate */
stmt
    : decl_stmt
    | cin_stmt
    | cout_stmt
    | assign_stmt
    ;

/* declaratie: int x; */
decl_stmt
    : INT ID ';'
      {
        std::string name($2);
        std::free($2);
        declara_variabila(name);
      }
    ;

/* citire: cin >> x; (folosim scanf) */
cin_stmt
    : CIN SHR ID ';'
      {
        std::string name($3);
        std::free($3);
        cere_declarata(name);

        linie("; cin >> " + name);
        linie("push dword " + name);   /* &x */
        linie("push dword fmt_in");    /* "%d" */
        linie("call [scanf]");
        linie("add esp, 8");
        linie("");
      }
    ;

/* afisare: cout << x; (folosim printf cu newline) */
cout_stmt
    : COUT SHL ID ';'
      {
        std::string name($3);
        std::free($3);
        cere_declarata(name);

        linie("; cout << " + name);
        linie("push dword [" + name + "]"); /* valoarea lui x */
        linie("push dword fmt_out");        /* "%d\n" */
        linie("call [printf]");
        linie("add esp, 8");
        linie("");
      }
    ;

/* atribuire: x = expr; (expr produce un rezultat pe stiva) */
assign_stmt
    : ID '=' expr ';'
      {
        std::string name($1);
        std::free($1);
        cere_declarata(name);

        linie("; store in " + name);
        linie("pop eax");              /* luam rezultatul expresiei */
        linie("mov [" + name + "], eax"); /* x = eax */
        linie("");
      }
    ;

/* expresii fara %left/%right: expr (+/-), term (*), factor */
expr
    : term
    | expr '+' term
      {
        /* (a + b): scoatem doua valori si punem rezultatul */
        linie("; add");
        linie("pop ebx");
        linie("pop eax");
        linie("add eax, ebx");
        linie("push eax");
      }
    | expr '-' term
      {
        /* (a - b) */
        linie("; sub");
        linie("pop ebx");
        linie("pop eax");
        linie("sub eax, ebx");
        linie("push eax");
      }
    ;

/* term gestioneaza inmultirea pentru precedenta mai mare */
term
    : factor
    | term '*' factor
      {
        /* (a * b) */
        linie("; mul");
        linie("pop ebx");
        linie("pop eax");
        linie("imul eax, ebx");
        linie("push eax");
      }
    ;

/* factor = constanta, variabila, sau expresie intre paranteze */
factor
    : NUMBER
      {
        /* punem constanta pe stiva */
        linie("push dword " + std::to_string($1));
      }
    | ID
      {
        /* incarcam valoarea variabilei pe stiva */
        std::string name($1);
        std::free($1);
        cere_declarata(name);
        linie("push dword [" + name + "]");
      }
    | '(' expr ')'
    ;

%%

/* mesaj de eroare pentru bison */
void yyerror(const char* s) {
    std::fprintf(stderr, "Eroare de parsare (linia %d): %s\n", yylineno, s);
}
