cmake_minimum_required(VERSION 3.20)
project(LFTC_Laborator6 CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(translator
        main.cpp
        parser.tab.c
        lex.yy.c
)

set_source_files_properties(parser.tab.c lex.yy.c PROPERTIES LANGUAGE CXX)

add_executable(asm_vm
        asm_vm.cpp
)
