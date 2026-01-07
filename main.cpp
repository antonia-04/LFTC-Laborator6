#include <cstdio>

// fisierul de intrare pentru lexer (Flex)
extern FILE* yyin;

// fisierul de iesire pentru codul ASM
extern FILE* gAsmOut;

int yyparse();

int main(int argc, char** argv) {

    if (argc < 2) {
        std::printf("Utilizare: translator <fisier.min> [out.asm]\n");
        return 1;
    }

    // numele fisierului sursa (.min)
    const char* inPath = argv[1];

    // numele fisierului ASM (implicit out.asm)
    const char* outPath = (argc >= 3) ? argv[2] : "out.asm";

    yyin = std::fopen(inPath, "r");
    if (!yyin) {
        std::perror("Nu pot deschide fisierul de intrare");
        return 1;
    }

    gAsmOut = std::fopen(outPath, "w");
    if (!gAsmOut) {
        std::perror("Nu pot crea fisierul ASM de iesire");
        std::fclose(yyin);
        return 1;
    }

    // pornim analiza sintactica si generarea de cod ASM
    int rc = yyparse();

    std::fclose(gAsmOut);
    std::fclose(yyin);

    if (rc == 0) {
        std::printf("OK. ASM32 generat in: %s\n", outPath);
        return 0;
    }

    // eroare la parsare
    return 2;
}
