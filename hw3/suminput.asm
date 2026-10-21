DATA SEGMENT
    MSG1    DB 'Please input a number (1-100):', 0DH, 0AH, '$'
    MSG2    DB 'The sum is:', 0DH, 0AH, '$'
    CRLF    DB 0DH, 0AH, '$'
    BUF     DB 5, 0, 5 DUP(0)   ; 缓冲输入：最大长度、实际长度、字符内容
DATA ENDS

STACK SEGMENT STACK
    DW 100H DUP(?)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    MOV AX, DATA
    MOV DS, AX

    LEA DX, MSG1
    MOV AH, 09H
    INT 21H                     ; 输出提示信息

    LEA DX, BUF
    MOV AH, 0AH
    INT 21H                     ; 从键盘输入字符串（带回显）

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H                     ; 换到下一行

    ; ---- 把输入的十进制字符串转换为数值，结果放入 BX ----
    MOV CL, [BUF+1]             ; 实际输入的字符数
    XOR CH, CH
    LEA SI, BUF+2               ; SI 指向第一个字符
    XOR BX, BX                  ; BX = 转换结果

PARSE:
    MOV AL, [SI]
    SUB AL, '0'                 ; 数字字符转换为数值
    XOR AH, AH

    PUSH AX                     ; 保存当前位的值
    MOV AX, BX
    MOV DX, 10
    MUL DX                      ; DX:AX = BX * 10
    MOV BX, AX
    POP AX
    ADD BX, AX                  ; BX = BX * 10 + 当前位
    INC SI
    LOOP PARSE                  ; 处理下一个字符

    ; ---- 计算 1+2+...+n（n 在 BX 中）----
    XOR AX, AX                  ; AX = 0，累加和
    MOV CX, BX                  ; 循环 n 次
    MOV BX, 1                   ; 当前加数

SUM_LOOP:
    ADD AX, BX                  ; AX = AX + BX
    INC BX
    LOOP SUM_LOOP               ; AX = 1+2+...+n

    PUSH AX                     ; 保存累加和（AH=09H 输出字符串会改写 AX）

    LEA DX, MSG2
    MOV AH, 09H
    INT 21H                     ; 输出提示信息

    POP AX                      ; 恢复累加和
    CALL PRINT_DEC              ; 按十进制输出 AX
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H                     ; 返回 DOS

; ------------------------------------------------------------
; 子程序 PRINT_DEC
; 入口：AX = 无符号整数
; 说明：反复除以 10，余数压栈，最后按相反顺序输出
; ------------------------------------------------------------
PRINT_DEC PROC
    MOV CX, 0
    MOV BX, 10
DEC_DIV:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DEC_DIV
DEC_OUT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP DEC_OUT
    RET
PRINT_DEC ENDP

CODE ENDS
END START
