#include <stdio.h>

int main(int argc, const char * argv[]) {
  char text[] = "hoge";
  char patt[] = "hoge";
  int m = sizeof(text) / sizeof(char) -1;
  int n = sizeof(patt) / sizeof(char) -1;

  for (int i=0; i<m-n+1; i++) {
    for (int j=0; j<n; j++) {
      if (text[i+j] != patt[j]) {
        break;
      }
      if (j == n-1) {
        printf("%d文字目\n", i+1);
      }
    }
  }

  return 0;
}
