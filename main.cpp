#include <cstdio>

extern FILE* yyin;
int yyparse();
extern FILE* gAsmOut;

int main(int argc, char** argv) {
    if (argc < 2) {
        std::printf("Utilizare: translator <fisier.min> [out.asm]\n");
        return 1;
    }

    const char* inPath = argv[1];
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

    int rc = yyparse();

    std::fclose(gAsmOut);
    std::fclose(yyin);

    if (rc == 0) {
        std::printf("OK. ASM32 generat in: %s\n", outPath);
        return 0;
    }
    return 2;
}
