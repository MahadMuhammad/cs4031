#include <map>
#include <setjmp.h>
#include <stack>
#include <stdexcept>
#include <stdio.h>
#include <string>
using namespace std;

static map<string, double> symbolTable;
static stack<string> exceptionStack;
bool exceptionThrown = false;

class CustomException : public exception {
public:
  explicit CustomException(const string &message) : msg_(message) {}
  virtual const char *what() const noexcept { return msg_.c_str(); }

private:
  string msg_;
};

double performBinaryOperation(double lhs, double rhs, int op) {
  switch (op) {
  case '+':
    return lhs + rhs;
  case '-':
    return lhs - rhs;
  case '*':
    return lhs * rhs;
  case '/':
    if (rhs == 0) {
      exceptionThrown = true;
      string msg = "Division by zero: Attempted to divide " + to_string(lhs) +
                   " by " + to_string(rhs);
      throw CustomException(msg);
    }
    return lhs / rhs;
  default:
    return 0;
  }
}

void print(const char *format, const char *value) { printf(format, value); }

void print(const char *format, double value) { printf(format, value); }

void setValueInSymbolTable(const char *id, double value) {
  string name(id);
  symbolTable[name] = value;
}

double getValueFromSymbolTable(const char *id) {
  string name(id);
  if (symbolTable.find(name) != symbolTable.end()) {
    return symbolTable[name];
  }
  return 0;
}

void throwException(const char *exceptionType) {
  string exType(exceptionType);
  exceptionStack.push(exType);
  throw CustomException(exType);
}

void tryBlock(void (*tryBlock)()) {
  if (tryBlock == nullptr) {
    return;
  }
  printf("%s",*tryBlock);
}

void CatchBlock(void (*catchBlock)(), const char *exception) {
  if(!exceptionThrown){
    return;
  }
  else if (catchBlock == nullptr) {
    return;
  }
  else if (exceptionThrown) {
    catchBlock();
    throwException(exception);
    exceptionThrown = false;
  }
}