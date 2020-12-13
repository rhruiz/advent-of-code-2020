#include <stdio.h>
#include <stdlib.h>

int main(void) {
  unsigned short buses[9] = {19, 41, 823, 23, 17, 29, 443, 37, 13};
  unsigned short delays[9] = {0, 9, 19, 27, 36, 48, 50, 56, 63};

  unsigned long ts = 0;
  unsigned long step = 1;

  for (int i = 0; i < 9; i++) {
    do {
      ts += step;
    } while((ts + delays[i]) % buses[i] != 0);

    step *= buses[i];
  }

  printf("%lu\n", ts);
}
