// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// 原理: R2 = R0 + R0 + ... + R0 (共加 R1 次)，用迴圈實作乘法
// 假設: R0, R1 >= 0 (本次測試皆為非負數，所以不用處理負數)

    @R2         // A = 2，準備存取 RAM[2]
    M=0         // R2 = 0，先把乘積歸零 (測試會先設 R2=-1，所以這行一定要有)

    @R1         // A = 1，準備讀 RAM[1] (乘數)
    D=M         // D = R1，把乘數讀進 D 暫存器
    @i          // A = 變數 i (自動分配到 RAM[16])，當作迴圈計數器
    M=D         // i = R1，複製一份計數器，避免直接改到 R1

(LOOP)          // 迴圈進入點標籤
    @i          // A = i，準備檢查還剩幾次要加
    D=M         // D = i
    @END        // A = END 標籤位址，準備跳躍
    D;JEQ       // if D == 0 (i==0) goto END，代表加完了就離開迴圈

    @R0         // A = 0，準備讀 RAM[0] (被乘數)
    D=M         // D = R0
    @R2         // A = 2，準備更新乘積
    M=D+M       // R2 = R0 + R2，累加一次

    @i          // A = i，準備扣計數器
    M=M-1       // i = i - 1

    @LOOP       // A = LOOP 標籤位址
    0;JMP       // 無條件跳回 LOOP，繼續下一圈

(END)           // 迴圈結束標籤
    @END        // A = END 自己
    0;JMP       // 無條件跳到自己，無窮迴圈停住程式 (Mult.tst 要求程式結束後停住)
