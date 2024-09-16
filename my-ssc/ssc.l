%{
    #include "ssc.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #ifdef DEBUGSSC
        #define debugFlex(a) (printf("\n%d: Token=<ID, lexeme>=<%d, %s>\n",yylineno,a,yytext))
    #else
        #define debugFlex(a)
    #endif
    void yyerror(const char *msg);
%}

%option yylineno
%option noyywrap


%%

"printd"                        {debugFlex(tok_printd);   return tok_printd;}
"prints"                        {debugFlex(tok_prints);   return tok_prints;}
[a-zA-Z][a-zA-Z0-9_]*           {debugFlex(tok_identifier);   yylval.identifier=yytext;  return tok_identifier;}
[0-9]+(\.[0-9]+)?               {debugFlex(tok_double_literal);   yylval.double_literal=atof(yytext);  return tok_double_literal;}
\"[^"]*\"                       {debugFlex(tok_string_literal);   yylval.string_literal=yytext;  return tok_string_literal;}
\/\/.*                          {;}
[ \n\r\t]                       {;}
"+"|"-"|"*"|"\/"|"="            {return yytext[0];} // This will return ASCII value of character
.                               {debugFlex(-1);   yyerror("this is illegal lexeme"); exit(EXIT_FAILURE);}

%%