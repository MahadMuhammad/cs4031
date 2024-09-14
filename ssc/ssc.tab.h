#include <cstdio>
enum Token {
  // We do not have to add 0 because it is used by EOF
  tok_printd = 1,
  tok_prints = 2,
  tok_identifier = 3,
  tok_double_literal = 4,
  tok_string_literal = 5,
};

union yylval {
  char *identifier;
  double double_literal;
  char *string_literal;
} yylval;

void yyerror(const char *msg) {
    fprintf(stderr, "\n%s\n",msg);
}