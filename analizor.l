%{
/* include robust: merge indiferent dacă Bison generează .h sau .hpp */
#if __has_include("parser.tab.hpp")
  #include "parser.tab.hpp"
#else
  #include "parser.tab.h"
#endif

#include <string.h>
#include <stdlib.h>

static char* dup_yytext(void) {
    size_t n = strlen(yytext);
    char* s = (char*)malloc(n + 1);
    memcpy(s, yytext, n + 1);
    return s;
}
%}


%option noyywrap
%option yylineno

DIGIT      [0-9]
LETTER     [A-Za-z]
ID         {LETTER}({LETTER}|{DIGIT}|_)*
INTCONST   {DIGIT}+
WS         [ \t\r\n]+

%%

"int"      { return INT; }
"cin"      { return CIN; }
"cout"     { return COUT; }

">>"       { return SHR; }
"<<"       { return SHL; }

";"        { return ';'; }
"="        { return '='; }
"("        { return '('; }
")"        { return ')'; }
"+"        { return '+'; }
"-"        { return '-'; }
"*"        { return '*'; }

{INTCONST} { yylval.ival = atoi(yytext); return NUMBER; }
{ID}       { yylval.sval = dup_yytext(); return ID; }

{WS}       { }
"//".*     { }

.          { return yytext[0]; }

%%
