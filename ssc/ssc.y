%{
  #include <stdio.h>
  #include <stdlib.h>
  
  extern int yyparse();
  extern int yylex();
  extern void yyerror(const char *msg);
  extern FILE* yyin;

  #define DEBUGBISON
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
}

%token tok_printd
%token tok_prints
%token tok_identifier
%token tok_double_literal
%token tok_string_literal

%left '+' '-'
%left '*' '/'
%left '(' ')'

%start root

%%

root: /* empty */               {debugBison(1);}
    | prints root               {debugBison(2);}
    | printd root               {debugBison(3);}
    | assignment root           {debugBison(4);}
    ;

/* prints(" abc ") */
prints: 
  tok_prints '(' tok_string_literal ')' ';' {debugBison(5);}
  ;

/* printd(700) or printd(l) here l is a ident */
printd: 
  tok_printd '(' term ')' ';' {debugBison(6);}
  ;

term: 
  tok_double_literal      {debugBison(7);}
  | tok_identifier        {debugBison(8);}
  ;

/* ident = expr | ident ;  */
assignment:
  tok_identifier '=' expresion ';' {debugBison(9);} 
  ;

expresion:
    term {debugBison(10);}
  | expresion '+' expresion {debugBison(11);}
  | expresion '-' expresion {debugBison(12);}
  | expresion '/' expresion {debugBison(14);}
  | expresion '*' expresion {debugBison(13);}
  | '(' expresion ')'
  ;
%%

void yyerror(const char *msg) {
  fprintf(stderr, "\n%s\n", msg);
}

int main(int argc, char **argv) {
  if (argc > 1) {
    FILE *fp = fopen(argv[1], "r");
    yyin = fp;
  }
  if (yyin == NULL) {
    // read from stdin
    yyin = stdin;
  }

  int parseResult = yyparse();

  return EXIT_SUCCESS;
}