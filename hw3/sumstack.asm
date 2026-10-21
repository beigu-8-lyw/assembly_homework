; ============================================================
; 作业3：求和（结果放在栈中）
; 求 1+2+...+100，把结果 5050 输出到屏幕。
;
; 本程序：在栈上分配一个字，累加结果始终保存在该栈单元中，
;         用 BP 寄存器访问（BP 默认使用 SS 段）。
; ============================================================
DATA SEGMENT
    CRLF    DB 0DH, 0AH, '$'
DATA ENDS

STACK SEGMENT STACK
    DW 100H DUP(?)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    MOV AX, DATA
    MOV DS, AX

    SUB SP, 2                   ; 在栈上分配一个字，用来存放累加和
    MOV BP, SP                  ; BP 指向这块栈空间
    MOV WORD PTR [BP], 0        ; 累加和初始化为 0

    MOV BX, 1                   ; BX = 当前要加的整数
    MOV CX, 100                 ; 循环 100 次

SUM_LOOP:
    MOV AX, [BP]                ; 从栈中取出当前累加和
    ADD AX, BX                  ; 加上当前整数
    MOV [BP], AX                ; 结果存回栈中
    INC BX
    LOOP SUM_LOOP               ; 循环结束后栈中存放 5050

    MOV AX, [BP]                ; 从栈中取出最终结果
    ADD SP, 2                   ; 释放刚才分配的栈空间
    CALL PRINT_DEC              ; 按十进制输出
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
