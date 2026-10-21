; ============================================================
; 作业3：求和（基本要求）
; 求 1+2+...+100，把结果 5050 输出到屏幕。
;
; 运行结果：
;   D:\>sum
;   5050
;
; 本程序：累加结果放在【寄存器 AX】中。
; 注意：5050 = 13BAH，超过 8 位寄存器能表示的范围（0~255），
;       所以必须使用 16 位寄存器（AX/BX/CX 等）和字操作。
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

    XOR AX, AX                  ; AX = 0，累加和存放在寄存器 AX 中
    MOV BX, 1                   ; BX = 当前要加的整数
    MOV CX, 100                 ; 循环 100 次

SUM_LOOP:
    ADD AX, BX                  ; AX = AX + BX
    INC BX                      ; BX 指向下一个整数
    LOOP SUM_LOOP               ; 循环结束后 AX = 5050

    CALL PRINT_DEC              ; 把 AX 中的数按十进制输出
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H                     ; 换行

    MOV AX, 4C00H
    INT 21H                     ; 返回 DOS

; ------------------------------------------------------------
; 子程序 PRINT_DEC
; 入口：AX = 无符号整数
; 说明：反复除以 10，余数压栈，最后按相反顺序输出
; ------------------------------------------------------------
PRINT_DEC PROC
    MOV CX, 0                   ; CX = 十进制位数
    MOV BX, 10                  ; 除数为 10
DEC_DIV:
    XOR DX, DX                  ; 被除数高 16 位置 0
    DIV BX                      ; AX = 商，DX = 余数
    PUSH DX                     ; 保存当前最低位
    INC CX
    CMP AX, 0
    JNE DEC_DIV                 ; 商不为 0 则继续除
DEC_OUT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H                     ; 逐位输出
    LOOP DEC_OUT
    RET
PRINT_DEC ENDP

CODE ENDS
END START
