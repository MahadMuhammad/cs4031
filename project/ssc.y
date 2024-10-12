%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "IR.h"
    
    extern int yyparse();
    extern int yylex();
    extern FILE *yyin;
    void yyerror(const char *err);

    #ifdef DEBUGBISON
        #define debugBison(a) (printf("\n%d \n",a))
    #else
        #define debugBison(a)
    #endif
%}

%union {
    char *identifier;
    double double_literal;
    char *string_literal;
    void (*block)();
}

%token tok_printd
%token tok_prints
%token tok_try
%token tok_catch
%token tok_throw
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <double_literal> term expression
%type <block> root exception_root try_root

%left '+' '-' 
%left '*' '/'
%left '(' ')'

%start root

%%

root:	/* empty */				{debugBison(1);}  	
    | prints  root				{debugBison(2);}
    | printd  root				{debugBison(3);}
    | assignment  root			{debugBison(4);}
    | try_catch  root			{debugBison(5);}
    | throw  root				{debugBison(6);}
    ;


try_root:	/* empty */				{debugBison(1);}  	
    | prints  try_root				{debugBison(2);}
    | printd  try_root				{debugBison(3);}
    | assignment  try_root			{debugBison(4);}
    ;

exception_root:	/* empty */				{debugBison(1);}  	
    | prints  exception_root				{debugBison(2);}
    | printd  exception_root				{debugBison(3);}
    | assignment  exception_root			{debugBison(4);}
    ; 

prints:	tok_prints '(' tok_string_literal ')' ';'   {debugBison(6); print("%s\n", $3); } 
    ;

printd:	tok_printd '(' term ')' ';'		{debugBison(7); print("%lf\n", $3); }
    ;

term:	tok_identifier				{debugBison(8); $$ = getValueFromSymbolTable($1); } 
    | tok_double_literal			{debugBison(9); $$ = $1; }
    ;

assignment:  tok_identifier '=' expression ';'	{debugBison(10); setValueInSymbolTable($1, $3); } 
    ;

expression: term				{debugBison(11); $$= $1;}
       | expression '+' expression		{debugBison(12); $$ = performBinaryOperation ($1, $3, '+');}
       | expression '-' expression		{debugBison(13); $$ = performBinaryOperation ($1, $3, '-');}
       | expression '/' expression		{debugBison(14); $$ = performBinaryOperation ($1, $3, '/');}
       | expression '*' expression		{debugBison(15); $$ = performBinaryOperation ($1, $3, '*');}
       | '(' expression ')'			{debugBison(16); $$= $2;}
       ;


try_catch: tok_try '{' try_root '}' tok_catch '(' tok_identifier ')' '{' exception_root '}' 
        {debugBison(17); tryBlock($3); if (exceptionThrown) CatchBlock($10, $7);}
    ;

throw: tok_throw '(' tok_identifier ')' ';' 
        {debugBison(18); throwException($3);}
    ;

%%

void yyerror(const char *err) {
    fprintf(stderr, "\n%s\n", err);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        yyin = fp;
    } 
    if (yyin == NULL) { 
        yyin = stdin;
    }
    
    int parserResult = yyparse();
    
    return EXIT_SUCCESS;
}