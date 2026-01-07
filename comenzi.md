cd C:\Users\Antonia\CLionProjects\LFTC-Laborator6

bison -d analizor.y -o parser.tab.cpp
flex -o lex.yy.c analizor.l

!! BUILD

.\cmake-build-debug\LFTC_Laborator6.exe test1.min out.asm
build_nasm out.asm
