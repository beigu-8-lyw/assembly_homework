#include <stdio.h>

int main(void)
{
    int  row, col;              /* row：行号；col：列号 */
    char ch = 'a';              /* 当前要输出的字母 */

    for (row = 0; row < 2; row++) {          /* 外层循环：2 行 */
        for (col = 0; col < 13; col++) {     /* 内层循环：每行 13 个 */
            putchar(ch);                     /* 输出当前字母 */
            ch++;                            /* 指向下一个字母 */

            if (col != 12)                   /* 不是本行最后一个字母 */
                putchar(' ');                /* 输出字母之间的空格 */
        }
        putchar('\n');                       /* 一行结束，输出换行 */
    }

    return 0;
}
