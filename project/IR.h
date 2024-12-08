#include <exception>
#include <map>
#include <setjmp.h>
#include <stack>
#include <stdexcept>
#include <stdio.h>
#include <string>
using namespace std;

static map<string, double> doubleSymbolTable;
static map<string, string> stringSymbolTable;
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
      /*       string msg = "Division by zero: Attempted to divide " +
         to_string(lhs) + " by " + to_string(rhs); exceptionStack.push(msg);
            exceptionThrown = false;
            throw CustomException(msg); */
    }
    return lhs / rhs;
  default:
    return 0;
  }
}

void print(const char *format, const char *value, bool isStderr = false) {
  if (isStderr) {
    fprintf(stderr, format, value);
  } else {
    printf(format, value);
  }
}

void print(const char *format, double value, bool isStderr = false) {
  if (isStderr) {
    fprintf(stderr, format, value);
  } else {
    printf(format, value);
  }
}

void setValueInSymbolTable(const char *id, double value) {
  string name(id);
  doubleSymbolTable[name] = value;
}

void setValueInStringSymbolTable(const char *id, const char *value) {
  string name(id);
  stringSymbolTable[name] = string(value);
}

double getValueFromSymbolTable(const char *id) {
  string name(id);
  if (doubleSymbolTable.find(name) != doubleSymbolTable.end()) {
    return doubleSymbolTable[name];
  }
  return 0;
}

string getValueFromStringSymbolTable(const char *id) {
  string name(id);
  if (stringSymbolTable.find(name) != stringSymbolTable.end()) {
    return stringSymbolTable[name];
  }
  return "";
}

bool isExceptionThrown() { return exceptionThrown; }
void setExceptionThrown(bool value) { exceptionThrown = value; }
void throwException(const char *exceptionType) {
  string exType(exceptionType);
  exceptionStack.push(exType);
  exceptionThrown = true;
  throw CustomException(exType);
}