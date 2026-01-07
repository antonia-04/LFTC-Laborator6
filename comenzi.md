bison -d analizor.y -o parser.tab.c

flex -o lex.yy.c analizor.l

!!! BUILD

.\cmake-build-debug\translator.exe test1.min out.asm

.\cmake-build-debug\translator.exe test2.min out.asm
