DATA SEGMENT
    CHAR    DB 'a'              ; 当前需要输出的字母
    NEWLINE DB 0DH, 0AH, '$'    ; 回车换行
DATA ENDS

STACK SEGMENT STACK
    DW 100H DUP(?)              ; 程序中使用 PUSH/POP，需要定义栈段
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    MOV AX, DATA
    MOV DS, AX

    MOV CX, 2                   ; 外层循环：共 2 行

OUTER_LOOP:
    PUSH CX                     ; 保存外层循环计数器（内层循环会改写 CX）
    MOV CX, 13                  ; 内层循环：每行 13 个字母

INNER_LOOP:
    MOV AH, 02H                 ; DOS 单字符输出功能
    MOV DL, CHAR                ; 将当前字母放入 DL
    INT 21H                     ; 输出字母

    INC CHAR                    ; 指向下一个字母

    DEC CX                      ; 内层计数器减 1
    JZ  ROW_END                 ; 若 CX=0（本行 13 个已输出完），不再输出空格

    MOV AH, 02H
    MOV DL, ' '
    INT 21H                     ; 输出字母之间的空格

    JMP INNER_LOOP              ; 无条件跳转回内层循环开头

ROW_END:
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H                     ; 一行结束，输出回车换行

    POP CX                      ; 恢复外层循环计数器
    DEC CX                      ; 外层计数器减 1
    JNZ OUTER_LOOP              ; 若不为 0，继续输出下一行

    MOV AX, 4C00H
    INT 21H                     ; 返回 DOS

CODE ENDS
END START
