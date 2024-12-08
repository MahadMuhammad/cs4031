#include <stdio.h>
enum Exception { division_by_zero, null_pointer };
#define division_by_zero Exception::division_by_zero
int main() {
  printf(% lf, 10.000000);
  double a = 7.000000;
  double b = 9.000000;
  printf(% lf, 9.000000);
  try {
  } catch (Exception e) {
    if (e == division_by_zero) {
      printf("Caught division_by_zero exception\n");
    }
  }
  return 0;
}
