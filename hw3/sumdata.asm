; ============================================================
; 作业3：求和（结果放在数据段中）
; 求 1+2+...+100，把结果 5050 输出到屏幕。
;
; 本程序：累加结果保存在【数据段】的变量 SUM 中。
; 注意：SUM 必须定义为 DW（字，16 位）。若定义为 DB，
;       5050（13BAH）会超出 8 位范围而被截断。
; ============================================================
DATA SEGMENT
    SUM     DW 0                ; 累加和（16 位，最大可表示 65535）
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

    MOV SUM, 0                  ; 数据段中的累加和清零
    MOV BX, 1                   ; BX = 当前要加的整数
    MOV CX, 100                 ; 循环 100 次

SUM_LOOP:
    MOV AX, SUM                 ; 取出当前累加和
    ADD AX, BX                  ; 加上当前整数
    MOV SUM, AX                 ; 存回数据段变量
    INC BX
    LOOP SUM_LOOP               ; 循环结束后 SUM = 5050

    MOV AX, SUM                 ; 从数据段取出最终结果
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
