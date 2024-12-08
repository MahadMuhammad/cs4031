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
    int block;
    int ival;
}

%token tok_printd
%token tok_prints
%token tok_try
%token tok_catch
%token tok_throw
%token tok_printe
%token tok_if
%token tok_else
%token tok_while
%token tok_eq
%token tok_neq
%token tok_lt
%token tok_lte
%token tok_gt
%token tok_gte
%token tok_and
%token tok_or
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <double_literal> term expression
%type <block> root catch_root
%type <ival> condition 

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
    | if_else  root				{debugBison(7);}
    | while  root				{debugBison(8);}
    ;

catch_root:    /* empty */				{debugBison(1);}  	
    /* | prints  catch_root			{debugBison(2);}
    | printd  catch_root			{debugBison(3);} */
    | printe  catch_root			{debugBison(80);}
    | assignment  catch_root		{debugBison(4);}
    | try_catch  catch_root		{debugBison(5);}
    | throw  catch_root			{debugBison(6);}
    ;

prints:	tok_prints '(' tok_string_literal ')' ';'   {debugBison(6); print("%s\n", $3);} 
    ;

printd:	tok_printd '(' term ')' ';'		{debugBison(7); print("%lf\n", $3); }
    ;

printe:    tok_printe '(' tok_string_literal ')' ';'   {debugBison(8); if (exceptionThrown){ print("%s\n", $3,true); exceptionThrown = false;}} 
    ;

term:	tok_identifier				{debugBison(8); $$ = getValueFromSymbolTable($1); } 
    | tok_double_literal			{debugBison(9); $$ = $1; }
    ;

assignment:  tok_identifier '=' expression ';'	{debugBison(10); setValueInSymbolTable($1, $3); } 
    ;

condition: 
    '(' expression ')' {debugBison(10); $$ = $2;}
    | expression tok_gt expression {debugBison(11); $$ = ($1 > $3);}
    | expression tok_lt expression {debugBison(12); $$ = ($1 < $3);}
    | expression tok_gte expression {debugBison(13); $$ = ($1 >= $3);}
    | expression tok_lte expression {debugBison(14); $$ = ($1 <= $3);}
    | expression tok_eq expression {debugBison(15); $$ = ($1 == $3);}
    | expression tok_neq expression {debugBison(16); $$ = ($1 != $3);}
    ;
if_else: tok_if expression '{' root '}' tok_else '{' root '}' 
        {
            debugBison(11); 
            if ($2) {
                printf("%s\n", $2);
                $4;
            } else {
                $8;
            }
        }
        | tok_if expression '{' root '}'
        {
            debugBison(12); 
            if ($2) {
                $4;
            }
        }
    ;

while: tok_while '(' condition ')' '{' root '}' 
        {
            debugBison(13); 
            while ($3) {
                $6;
            }
        }

expression: term				{debugBison(11); $$= $1;}
       | expression '+' expression		{debugBison(12); $$ = performBinaryOperation ($1, $3, '+');}
       | expression '-' expression		{debugBison(13); $$ = performBinaryOperation ($1, $3, '-');}
       | expression '/' expression		{debugBison(14); $$ = performBinaryOperation ($1, $3, '/');}
       | expression '*' expression		{debugBison(15); $$ = performBinaryOperation ($1, $3, '*');}
       | '(' expression ')'			{debugBison(16); $$= $2;}
       ;


try_catch: tok_try '{' root '}' tok_catch '(' tok_identifier ')' '{' catch_root '}' 
        {
            debugBison(17); 
            try {
                $3;
            } catch (const char* e) {
                if (!isExceptionThrown()){
                    setValueInStringSymbolTable($7, e);
                    setExceptionThrown(false);
                    $10;
                }
            }
        }
        | tok_try '{' root '}' 
        {
            debugBison(18); 
            try {
                $3;
            } catch (const char* e) {
                printf("Exception caught: %s\n", e);
            }
        }
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