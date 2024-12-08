%{
    #include "IR.h"
    #include <stdio.h>
    #include <string.h>
    FILE *outputFile;
    extern int yyparse();
    extern int yylex();
    string exception;
    extern FILE *yyin;
    void yyerror(const char *err);

    #ifdef DEBUGBISON
        #define debugBison(a) (printf("\n%d \n", a))
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
    char* exception;
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
%token <exception> tok_exception
%token <exception> tok_division_by_zero
%token <exception> tok_null_pointer
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal
%type <double_literal> term expression
%type <exception> exceptions
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

prints:	tok_prints '(' tok_string_literal ')' ';'   {debugBison(6); fprintf(outputFile, "printf(%s);\n", $3); } 
    ;

printd:	tok_printd '(' term ')' ';'		{debugBison(7); fprintf(outputFile, "printf(%%lf, %lf);\n", $3); }
    ;

printe:    tok_printe '(' tok_string_literal ')' ';'   {debugBison(8); 
exceptionThrown=false;
if (exceptionThrown)
    { 
        // fprintf(outputFile, "} catch (Exception e) {\n");
        // fprintf(outputFile, "\tif (e == %s) {\n", $3);
        fprintf(outputFile, "fprintf(stderr, %s);\n", $3); 
        // fprintf(outputFile, "}}\n");
        exceptionThrown = false;
    }
} 
    ;

term:	tok_identifier				{debugBison(8); $$ = getValueFromSymbolTable($1); } 
    | tok_double_literal			{debugBison(9); $$ = $1; }
    ;

assignment:  tok_identifier '=' expression ';'	{debugBison(10); fprintf(outputFile, "double %s = %lf;\n", $1, $3); setValueInSymbolTable($1, $3); } 
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
                fprintf(outputFile, "if (%lf) {\n", $2);
                $4;
                fprintf(outputFile, "}\n");
            } else {
                fprintf(outputFile, "else {\n");
                $8;
                fprintf(outputFile, "}\n");
            }
        }
        | tok_if expression '{' root '}'
        {
            debugBison(12); 
            if ($2) {
                fprintf(outputFile, "if (%lf) {\n", $2);
                $4;
                fprintf(outputFile, "}\n");
            }
        }
    ;

while: tok_while '(' condition ')' '{' root '}' 
        {
            debugBison(13); 
            fprintf(outputFile, "while (%d) {\n", $3);
            while ($3) {
                $6;
            }
            fprintf(outputFile, "}\n");
        }

expression: term				{debugBison(11); $$= $1;}
       | expression '+' expression		{debugBison(12); $$ = performBinaryOperation ($1, $3, '+');}
       | expression '-' expression		{debugBison(13); $$ = performBinaryOperation ($1, $3, '-');}
       | expression '/' expression		{debugBison(14); $$ = performBinaryOperation ($1, $3, '/');}
       | expression '*' expression		{debugBison(15); $$ = performBinaryOperation ($1, $3, '*');}
       | '(' expression ')'			{debugBison(16); $$= $2;}
       ;

exceptions: tok_division_by_zero {debugBison(16); $$ = "division_by_zero";}
        | tok_null_pointer {debugBison(17); $$ = "null_pointer";}
        ;

try_catch: try_block catch_block {debugBison(16);}
    ;

try_block: tok_try '{' root '}' 
        {
            debugBison(17); 
            fprintf(outputFile, "try {\n");
            $3;
            fprintf(outputFile, "}");
            // fprintf(outputFile, "catch (Exception e) {\n");
            // fprintf(outputFile, "\tif (e == %s) {\n", $7);
            // $10;
            // fprintf(outputFile, "\t\tprintf(\"Caught %s exception\\n\");\n", $7);
            // fprintf(outputFile, "}}\n");
        }

    ;

catch_block:  tok_catch '(' exceptions ')' '{' catch_root '}' 
        {
            debugBison(17); 
            fprintf(outputFile, "catch (Exception e) {\n");
            fprintf(outputFile, "\tif (e == %s) {\n", $3);
            fprintf(outputFile, "printf(\"Caught %s exception\\n\");\n", $3);
            $6;
            fprintf(outputFile, "}}\n");
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
    outputFile = fopen("output.cpp", "w");
    if (!outputFile) {
        perror("Error opening output file");
        exit(EXIT_FAILURE);
    }

    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        yyin = fp;
    } 
    if (yyin == NULL) { 
        yyin = stdin;
    }

    fprintf(outputFile, "#include <stdio.h>\n"); /* int main() {\n */
    fprintf(outputFile, "enum Exception {division_by_zero, null_pointer};\n");
    fprintf(outputFile, "#define division_by_zero Exception::division_by_zero\n");
    fprintf(outputFile, "int main() {\n");
    int parserResult = yyparse();
    fprintf(outputFile, "return 0;\n}\n");
    fclose(outputFile);
    
    return parserResult == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}