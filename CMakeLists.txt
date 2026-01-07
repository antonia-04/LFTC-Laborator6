cmake_minimum_required(VERSION 3.20)
project(LFTC_Laborator6 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# forțăm lex.yy.c să fie tratat ca C++
set_source_files_properties(lex.yy.c PROPERTIES LANGUAGE CXX)

add_executable(LFTC_Laborator6
        main.cpp
        parser.tab.cpp
        lex.yy.c
)
