// Fill 精簡穩定版
// 外圈讀鍵盤決定黑白，內圈用 addr<KBD 判斷結尾
// 變數只有 addr 一個，黑白分開寫省時間

(START)
    @KBD
    D=M
    @BLACK
    D;JNE

    @SCREEN
    D=A
    @addr
    M=D

(WHITE_LOOP)
    @addr
    A=M
    M=0

    @addr
    M=M+1

    @addr
    D=M
    @KBD
    D=D-A
    @WHITE_LOOP
    D;JLT

    @START
    0;JMP

(BLACK)
    @SCREEN
    D=A
    @addr
    M=D

(BLACK_LOOP)
    @addr
    A=M
    M=-1

    @addr
    M=M+1

    @addr
    D=M
    @KBD
    D=D-A
    @BLACK_LOOP
    D;JLT

    @START
    0;JMP
