## 第1回課題
単純な方法で文字列検索をする  
以下がソースコード

```c
#include <stdio.h>

int main(int argc, const char * argv[]) {
  char text[] = "abcdefghcd";
  char patt[] = "cd";
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
```

### 実行結果  

- テスト1

```c
char text[] = "abcdefghcd";
char patt[] = "cd";
```

> 3文字目  
9文字目

- テスト2

```c
char text[] = "abcdefghcdcdcdijk";
char patt[] = "cdc";
```

>9文字目  
11文字目

- テスト3

```c
char text[] = "fdjioamvbuealmcnbvbheiapxlmvudnhaxlcnfjieao";
char patt[] = "hoge";
```

> 出力せず正常終了

- テスト4

```c
char text[] = "hoge";
char patt[] = "hoge";
```

> 1文字目

- テスト5

```c
char text[] = "ho";
char patt[] = "hoge";
```

> 出力せず正常終了
