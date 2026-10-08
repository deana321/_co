# Mult 教學：R2 = R0 * R1

對應檔案：`mult.asm`、`Mult.tst`、`Mult.cmp`

## 1. 題目在做什麼

把 `RAM[0] (R0)` 和 `RAM[1] (R1)` 相乘，結果存到 `RAM[2] (R2)`。

測試檔 `Mult.tst` 會依序測這 6 組（來自 `Mult.cmp`）：

| R0 | R1 | 預期 R2 |
|----|----|---------|
| 0 | 0 | 0 |
| 1 | 0 | 0 |
| 0 | 2 | 0 |
| 3 | 1 | 3 |
| 2 | 4 | 8 |
| 6 | 7 | 42 |

每次測試前會 `set RAM[2] -1`，所以你的程式**第一件事必須是 `R2 = 0`**，不然第一個 output 就錯了。

## 2. 需要的 Hack 觀念

Hack 組語只有 2 種指令：

1. **A 指令 `@xxx`**：把 `xxx` 載入 A 暫存器。`xxx` 可以是數字、符號（`R0`、`SCREEN`、自訂 label / 變數）。
2. **C 指令 `dest=comp;jump`**：計算後存回去，可選跳躍。
   - `M=0`：把 RAM[A] 設 0
   - `D=M`：把 RAM[A] 讀到 D
   - `M=D+M`：RAM[A] = D + RAM[A]
   - `M=M-1`：RAM[A] 減 1
   - `D;JEQ`：D == 0 才跳；`0;JMP`：永遠跳。

Label 寫法 `(LOOP)` 是標記下一行的位址，不是可執行的指令。
變數 `i` 第一次出現時會自動分配到 `RAM[16]`，第二個變數到 `RAM[17]`，依此類推。

## 3. 演算法：迴圈加法

因為 Hack 沒有乘法指令，只能用加法湊：

```
R2 = 0
i = R1          // 複製一份計數器，不要直接扣 R1
while i != 0:
    R2 = R2 + R0
    i = i - 1
無窮迴圈停住
```

為什麼要複製 `i = R1`？直接拿 `R1` 當計數器也可以過測資（測試會幫你還原 R1 再 output），但會破壞輸入，是壞習慣。考試或後續題目可能要求保留 R0/R1，所以這裡示範正規寫法。

## 4. 程式對照（mult.asm 逐段解說）

```asm
@R2
M=0        // 乘積歸零
```

```asm
@R1
D=M
@i
M=D        // i = R1
```

```asm
(LOOP)
@i
D=M
@END
D;JEQ      // i==0 就結束
```

```asm
@R0
D=M
@R2
M=D+M      // R2 += R0
```

```asm
@i
M=M-1      // i--
@LOOP
0;JMP      // 回圈頂
```

```asm
(END)
@END
0;JMP      // 停住
```

追蹤範例 `R0=2, R1=4`：

1. `R2=0, i=4`
2. `R2=2, i=3` → `R2=4, i=2` → `R2=6, i=1` → `R2=8, i=0`
3. `i==0` 跳 END，停住。`R2=8` 正確。

## 5. 怎麼驗證

1. 用 `nand2tetris/tools/Assembler` 把 `mult.asm` 轉成 `Mult.hack`
2. 用 `CPUEmulator` 開 `Mult.tst`，按執行
3. 顯示 `Comparison ended successfully` 就是全對；或用 `TextComparer` 比 `Mult.out` vs `Mult.cmp`

## 6. 常見錯誤

- 忘記 `M=0` 初始化 R2：第一筆 `0*0` 會輸出 `-1`
- 寫成 `D;JEQ` 卻忘了前面 `@END`：會跳到錯誤位址
- 結尾沒有無窮迴圈：CPU 會一路跑到記憶體外的垃圾指令
- 迴圈太肥：`6*7` 必須在 `repeat 210 ticktock` 內算完，指令越多跑越慢
