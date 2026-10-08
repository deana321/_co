# Fill 教學：鍵盤控制螢幕黑白

對應檔案：`Fill.asm`、`Fill.tst`、`FillAutomatic.tst`、`FillAutomatic.cmp`

## 1. 題目在做什麼

寫一個**永遠不結束**的程式監聽鍵盤：

- 有按任意鍵（`KBD != 0`）：全螢幕塗黑（每個 pixel 都是黑）
- 沒按鍵（`KBD == 0`）：全螢幕塗白

`FillAutomatic.tst` 會自動模擬三階段（來自 `FillAutomatic.cmp`）：

| 階段 | KBD | 抽查 9 個 screen 位址預期值 |
|------|-----|------------------------------|
| 1. 沒碰鍵盤 | 0 | 全部 `0`（白） |
| 2. 按住鍵盤 | 1 | 全部 `-1`（黑） |
| 3. 放開鍵盤 | 0 | 全部 `0`（白） |

每階段跑 `1000000 ticktock`，所以你的內圈必須夠快，能在 100 萬個 cycle 內塗滿 8192 個字。

## 2. 需要的 Hack 觀念

記憶體對應（死背）：

| 符號 | 位址 | 說明 |
|------|------|------|
| `SCREEN` | 16384 | 螢幕起始，連續 8192 字到 24575 |
| `KBD` | 24576 | 鍵盤，有按鍵 > 0，沒按 = 0 |
| `R0~R15` | 0~15 | 通用暫存器 |
| 自訂變數 | 16~ | 如 `color`→16，`addr`→17，`n`→18 |

顏色表示：

- 白 = `0` = `0000000000000000`
- 黑 = `-1` = `1111111111111111`（16 bits 全 1，剛好把一個字的 16 個 pixels 全點亮）

間接定址（Fill 最重要的一招）：

```asm
@addr
A=M     // A = addr 變數的值，也就是「真正的螢幕位址」
M=D     // RAM[真正的螢幕位址] = D
```

第一行 `@addr` 的 A 是變數自己的位址，第二行 `A=M` 才切換到它存的螢幕位址。

跳躍條件：

- `D;JEQ`：D == 0 跳
- `D;JNE`：D != 0 跳（本題判斷按鍵用這個）
- `0;JMP`：永遠跳

## 3. 演算法：外圈看鍵盤 + 內圈塗螢幕

```
while true:              // 外圈，永不結束
    if KBD != 0:
        color = -1       // 黑
    else:
        color = 0        // 白

    addr = SCREEN        // 從第一格開始
    n = 8192             // 還剩 8192 格
    while n != 0:        // 內圈
        *addr = color
        addr += 1
        n -= 1
    // 內圈結束後回到外圈頂，重新看鍵盤
```

為什麼內圈結束要回外圈？如果填完就停住，第二次按鍵/放開就不會換顏色了。`FillAutomatic.tst` 第二、三階段就是測這個。

## 4. 程式對照（Fill.asm 逐段解說）

外圈讀鍵盤：

```asm
(START)
@KBD
D=M
@BLACK
D;JNE        // 有按鍵跳 BLACK
```

沒按鍵設白色：

```asm
@color
M=0
@FILL_INIT
0;JMP        // 跳過設黑色的部分
```

有按鍵設黑色：

```asm
(BLACK)
@color
M=-1
```

初始化 pointer：

```asm
(FILL_INIT)
@SCREEN
D=A          // 注意是 D=A，不是 D=M
@addr
M=D          // addr = 16384
@8192
D=A
@n
M=D          // n = 8192
```

內圈填充：

```asm
(FILL_LOOP)
@n
D=M
@START
D;JEQ        // 寫完回 START
@color
D=M
@addr
A=M
M=D          // *addr = color
@addr
M=M+1        // 下一格
@n
M=M-1        // n--
@FILL_LOOP
0;JMP
```

## 5. 怎麼驗證

1. Assembler 轉出 `Fill.hack`
2. `CPUEmulator` 開 `FillAutomatic.tst` 執行，等三個 `output` 跑完
3. `Comparison ended successfully` 即通過
4. 想看動畫：改開 `Fill.tst`，選 `No Animation`，用鍵盤按著放開，看螢幕是否全黑/全白

## 6. 常見錯誤

- 沒有 `(START)` 外圈：只塗一次就不動了，第二階段測不過
- 把 `@SCREEN D=A` 寫成 `D=M`：會讀到螢幕第一格的內容（0 或 -1），不是 16384
- 忘記 `@addr A=M` 直接 `M=D`：會把顏色寫到 `addr` 變數自己，不是螢幕
- 內圈結束跳到自己 `(FILL_LOOP)` 而不是 `(START)`：鍵盤永遠沒被重讀
- 用 `D;JGT` 判斷鍵盤：鍵盤碼都是正數可以動，但 `D;JNE` 最保險（任何非零都算有按）
