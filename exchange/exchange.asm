DATA SEGMENT
    MSG1    DB 'Please input a Hex number:', 0DH, 0AH, '$'
    MSG2    DB 'The Dec number:', 0DH, 0AH, '$'
    MSG3    DB 'Please input a Dec number:', 0DH, 0AH, '$'
    MSG4    DB 'The Hex number:', 0DH, 0AH, '$'
    CRLF    DB 0DH, 0AH, '$'
    BUF     DB 5, 0, 5 DUP(0)       ; 缓冲输入：最大长度、实际长度、字符内容
DATA ENDS

STACK SEGMENT STACK
    DW 100H DUP(?)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    MOV AX, DATA
    MOV DS, AX

; ==================== 第一部分：十六进制 -> 十进制 ====================
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H                         ; 输出提示信息

    LEA DX, BUF
    MOV AH, 0AH
    INT 21H                         ; 从键盘输入字符串（带回显）

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H                         ; 回车后换到下一行

    ; 逐位转换：BX = BX * 16 + 当前位的值
    MOV CL, [BUF+1]                 ; BUF+1 中存放实际输入的字符数
    XOR CH, CH
    LEA SI, BUF+2                   ; SI 指向第一个字符
    XOR BX, BX                      ; BX 保存转换结果

HEX_CONVERT:
    MOV AL, [SI]
    CALL HEX_DIGIT                  ; 把字符转换为数值（0~15）
    SHL BX, 1
    SHL BX, 1
    SHL BX, 1
    SHL BX, 1                       ; BX = BX * 16
    XOR AH, AH
    ADD BX, AX                      ; 加上当前位的值
    INC SI
    LOOP HEX_CONVERT                ; 处理下一个字符

    LEA DX, MSG2
    MOV AH, 09H
    INT 21H                         ; 输出提示信息

    MOV AX, BX
    CALL PRINT_DEC                  ; 以十进制形式输出 AX
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

; ==================== 第二部分：十进制 -> 十六进制 ====================
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H                         ; 输出提示信息

    LEA DX, BUF
    MOV AH, 0AH
    INT 21H                         ; 再次从键盘输入（带回显）

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H                         ; 回车后换到下一行

    ; 逐位转换：BX = BX * 10 + 当前位的值
    MOV CL, [BUF+1]
    XOR CH, CH
    LEA SI, BUF+2
    XOR BX, BX                      ; BX 保存转换结果

DEC_CONVERT:
    MOV AL, [SI]
    SUB AL, '0'                     ; 数字字符转换为数值
    XOR AH, AH

    PUSH AX                         ; 保存当前位的值
    MOV AX, BX
    MOV DX, 10
    MUL DX                          ; DX:AX = BX * 10
    MOV BX, AX
    POP AX
    ADD BX, AX                      ; BX = BX * 10 + 当前位
    INC SI
    LOOP DEC_CONVERT

    LEA DX, MSG4
    MOV AH, 09H
    INT 21H                         ; 输出提示信息

    ; 输出十六进制：先高 4 位，再低 4 位
    MOV DX, BX
    MOV CL, 4
    SHR DX, CL                      ; 右移 4 位，得到高 4 位
    CMP DL, 0
    JZ  LOW_NIBBLE                  ; 高 4 位为 0 则只输出低 4 位
    CALL PRINT_HEX_DIGIT

LOW_NIBBLE:
    MOV DX, BX
    AND DL, 0FH                     ; 取低 4 位
    CALL PRINT_HEX_DIGIT

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H                         ; 返回 DOS

; ------------------------------------------------------------
; 子程序 HEX_DIGIT
; 入口：AL = 待转换字符
; 出口：AL = 数值 0~15
; 说明：支持 '0'~'9'、'a'~'f'、'A'~'F'
; ------------------------------------------------------------
HEX_DIGIT PROC
    CMP AL, '9'
    JBE DIGIT_NUM
    OR  AL, 20H                     ; 大写字母统一转成小写
    SUB AL, 'a' - 10                ; 'a' -> 10，'f' -> 15
    RET
DIGIT_NUM:
    SUB AL, '0'                     ; '0' -> 0，'9' -> 9
    RET
HEX_DIGIT ENDP

; ------------------------------------------------------------
; 子程序 PRINT_DEC
; 入口：AX = 无符号整数
; 说明：反复除以 10，把余数压栈，最后按相反顺序输出
; ------------------------------------------------------------
PRINT_DEC PROC
    MOV CX, 0                       ; CX = 十进制位数
    MOV BX, 10                      ; 除数为 10
DEC_DIV:
    XOR DX, DX                      ; 被除数高 16 位置 0
    DIV BX                          ; AX = 商，DX = 余数
    PUSH DX                         ; 保存当前最低位
    INC CX
    CMP AX, 0
    JNE DEC_DIV                     ; 商不为 0 则继续除
DEC_OUT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H                         ; 逐位输出
    LOOP DEC_OUT
    RET
PRINT_DEC ENDP

; ------------------------------------------------------------
; 子程序 PRINT_HEX_DIGIT
; 入口：DL = 0~15
; 说明：把 DL 中的一位十六进制数转换成字符并输出（大写）
; ------------------------------------------------------------
PRINT_HEX_DIGIT PROC
    CMP DL, 9
    JBE HEX_NUM
    ADD DL, 'A' - 10                ; 10~15 转换为 'A'~'F'
    JMP HEX_OUT
HEX_NUM:
    ADD DL, '0'                     ; 0~9 转换为 '0'~'9'
HEX_OUT:
    MOV AH, 02H
    INT 21H
    RET
PRINT_HEX_DIGIT ENDP

CODE ENDS
END START
