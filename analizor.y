%{
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unordered_set>
#include <vector>
#include <sstream>

extern int yylex();
extern int yylineno;
extern FILE* yyin;
void yyerror(const char* s);

FILE* gAsmOut = nullptr;

static std::unordered_set<std::string> gVarSet;
static std::vector<std::string> gVars;
static std::ostringstream gCode;

static void linie(const std::string& s) { gCode << "    " << s << "\n"; }

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

static void cere_declarata(const std::string& name) {
    if (!gVarSet.count(name)) {
        std::fprintf(stderr,
                     "Eroare semantica (linia %d): variabila '%s' nu este declarata.\n",
                     yylineno, name.c_str());
        std::exit(1);
    }
}

static void scrie_asm_complet() {
    /* ASM32 compatibil cu: nasm -fobj + alink -entry start */
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

    for (const auto& v : gVars) {
        std::fprintf(gAsmOut, "    %s dd 0\n", v.c_str());
    }

    std::fprintf(gAsmOut,
        "\n"
        "segment code use32 class=code\n"
        "start:\n"
    );

    std::fputs(gCode.str().c_str(), gAsmOut);

    std::fprintf(gAsmOut,
        "\n"
        "    push dword 0\n"
        "    call [exit]\n"
    );
}
%}

%union { int ival; char* sval; }

%token INT READ WRITE
%token ARROW
%token <sval> ID
%token <ival> NUMBER
%start program

%%

program : lista_stmt { scrie_asm_complet(); } ;

lista_stmt : stmt | stmt lista_stmt ;

stmt : decl_stmt | read_stmt | write_stmt | assign_stmt ;

decl_stmt : INT ID ';'
{
    std::string name($2);
    free($2);
    declara_variabila(name);
}
;

read_stmt : READ ID ';'
{
    std::string name($2);
    free($2);
    cere_declarata(name);

    linie("; read " + name);
    linie("push dword " + name);     /* &name */
    linie("push dword fmt_in");
    linie("call [scanf]");
    linie("add esp, 8");
    linie("");
}
;

write_stmt : WRITE ID ';'
{
    std::string name($2);
    free($2);
    cere_declarata(name);

    linie("; write " + name);
    linie("push dword [" + name + "]");
    linie("push dword fmt_out");
    linie("call [printf]");
    linie("add esp, 8");
    linie("");
}
;

assign_stmt : ID ARROW expr ';'
{
    std::string name($1);
    free($1);
    cere_declarata(name);

    linie("; store in " + name);
    linie("pop eax");
    linie("mov [" + name + "], eax");
    linie("");
}
;

/* precedenta: expr (+/-), term (*), factor */
expr : term
     | expr '+' term {
        linie("; ADD");
        linie("pop ebx");
        linie("pop eax");
        linie("add eax, ebx");
        linie("push eax");
     }
     | expr '-' term {
        linie("; SUB");
        linie("pop ebx");
        linie("pop eax");
        linie("sub eax, ebx");
        linie("push eax");
     }
     ;

term : factor
     | term '*' factor {
        linie("; MUL");
        linie("pop ebx");
        linie("pop eax");
        linie("imul eax, ebx");
        linie("push eax");
     }
     ;

factor : NUMBER { linie("push dword " + std::to_string($1)); }
       | ID {
            std::string name($1);
            free($1);
            cere_declarata(name);
            linie("push dword [" + name + "]");
         }
       | '(' expr ')'
       ;

%%

void yyerror(const char* s) {
    std::fprintf(stderr, "Eroare de parsare (linia %d): %s\n", yylineno, s);
}
