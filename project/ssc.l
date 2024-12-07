%{
    #include "ssc.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <string>
    extern void yyerror(const char *msg);
    
    #ifdef DEBUGSSC
        #define debugFlex(a) (printf("\n%d: Token=<ID, lexeme>=<%d, %s>\n",yylineno, a, yytext))
    #else
        #define debugFlex(a)
    #endif
%}

%option yylineno 
%option noyywrap

%%

"printd"                {debugFlex(tok_printd); return tok_printd;}
"prints"                {debugFlex(tok_prints); return tok_prints;}
"printe"                {debugFlex(tok_printe); return tok_printe;}
"try"                   {debugFlex(tok_try); return tok_try;}
"catch"                 {debugFlex(tok_catch); return tok_catch;}
"throw"                 {debugFlex(tok_throw); return tok_throw;}
"if"                    {debugFlex(tok_if); return tok_if;}
"else"                  {debugFlex(tok_else); return tok_else;}
"while"                 {debugFlex(tok_while); return tok_while;}
"=="                    {debugFlex(tok_eq); return tok_eq;}
"!="                    {debugFlex(tok_neq); return tok_neq;}
"<"                     {debugFlex(tok_lt); return tok_lt;}
"<="                    {debugFlex(tok_lte); return tok_lte;}
">"                     {debugFlex(tok_gt); return tok_gt;}
">="                    {debugFlex(tok_gte); return tok_gte;}
"&&"                    {debugFlex(tok_and); return tok_and;}
"||"                    {debugFlex(tok_or); return tok_or;}
[a-zA-Z][a-zA-Z0-9_]*   {debugFlex(tok_identifier); yylval.identifier=strdup(yytext); return tok_identifier;}
[0-9]+(\.[0-9]+)?       {debugFlex(tok_double_literal); yylval.double_literal=atof(yytext); return tok_double_literal;}
\"[^"]*\"               {debugFlex(tok_string_literal); yylval.string_literal=strdup(yytext); return tok_string_literal;}
\/\/.*                  {;}
[ \n\r\t]               {;}
"+"|"-"|"*"|"\/"|"="|";"|"("|")"|"{"|"}" {debugFlex(yytext[0]); return yytext[0];} 
.                       {debugFlex(-1); yyerror("this is an illegal lexeme"); exit(EXIT_FAILURE);}
%%