; Field.s : フィールド
;


; モジュール宣言
;
    .module Field

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Item.inc"
    .include    "Camera.inc"
    .include	"Field.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; フィールドを初期化する
;
_FieldInitialize::
    
    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; フィールドを更新する
;
_FieldUpdate::
    
    ; レジスタの保存

    ; 通り道の更新
    call    FieldUpdatePath

    ; レジスタの復帰
    
    ; 終了
    ret

; フィールドを描画する
;
_FieldRender::

    ; レジスタの保存

    ; フィールドの描画
    ld      a, (_field + FIELD_FLAG)
    bit     #FIELD_FLAG_VIEW_BIT, a
    jr      z, 10$
    call    FieldPrintView
    jr      19$
10$:
    bit     #FIELD_FLAG_SCROLL_UP_BIT, a
    jr      z, 11$
    call    FieldPrintScrollUp
    jr      19$
11$:
    bit     #FIELD_FLAG_SCROLL_DOWN_BIT, a
    jr      z, 12$
    call    FieldPrintScrollDown
    jr      19$
12$:
    bit     #FIELD_FLAG_SCROLL_LEFT_BIT, a
    jr      z, 13$
    call    FieldPrintScrollLeft
    jr      19$
13$:
    bit     #FIELD_FLAG_SCROLL_RIGHT_BIT, a
    jr      z, 19$
    call    FieldPrintScrollRight
;   jr      19$
19$:
    ld      hl, #(_field + FIELD_FLAG)
    ld      a, (hl)
    and     #~(FIELD_FLAG_VIEW | FIELD_FLAG_SCROLL_UP | FIELD_FLAG_SCROLL_DOWN | FIELD_FLAG_SCROLL_LEFT | FIELD_FLAG_SCROLL_RIGHT)
    ld      (hl), a
    
    ; レジスタの復帰

    ; 終了
    ret

; フィールドを作成する
;
_FieldBuild:

    ; レジスタの保存

    ; フィールドの初期化
    ld      hl, #fieldDefault
    ld      de, #_field
    ld      bc, #FIELD_LENGTH
    ldir

    ; 乱数の初期化
    ld      de, (_app + APP_GAME_RANDOM_L)
    ld      (_field + FIELD_RANDOM_L), de

    ; 草原で埋める
    call    FieldBuildGrass

    ; エリアの並び替え
    call    FieldBuildArea

    ; 地形の作成
    call    FieldBuildGround

    ; 水を流す
    call    FieldBuildWater

    ; 障害物の設置
    call    FieldBuildObstacle

    ; 宝箱を開ける
    call    FieldBuildBox

    ; パターンの作成
    call    FieldBuildPattern

    ; フィールドの描画
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_VIEW_BIT, (hl)
    
    ; レジスタの復帰

    ; 終了
    ret

; フィールドを草原で埋める
;
FieldBuildGrass:

    ; レジスタの保存

    ; 草原で埋める
    ld      hl, #(fieldCell + 0x0000)
    ld      de, #(fieldCell + 0x0001)
    ld      bc, #(FIELD_CELL_SIZE_X * FIELD_CELL_SIZE_Y - 0x0001)
    ld      (hl), #FIELD_TYPE_GRASS
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; エリアを並び替える
;
FieldBuildArea:

    ; レジスタの保存

    ; エリアの初期化
    ld      hl, #fieldAreaDefault
    ld      de, #fieldArea
    ld      bc, #(FIELD_AREA_SIZE_X * FIELD_AREA_SIZE_Y)
    ldir
    ld      de, #fieldArea
    ld      b, #(FIELD_AREA_SIZE_X * FIELD_AREA_SIZE_Y)
10$:
    push    bc
    call    FieldGetRandom
    rrca
    and     #0x3f
    ld      c, a
    ld      b, #0x00
    ld      hl, #fieldArea
    add     hl, bc
    ld      c, (hl)
    ld      a, (de)
    ld      (hl), a
    ld      a, c
    ld      (de), a
    pop     bc
    inc     hl
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; 地形を作成する
;
FieldBuildGround:

    ; レジスタの保存

    ; エリア毎に地形を展開する
    ld      hl, #fieldArea
    ld      b, #0x00
10$:
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    ld      c, a
;   cp      #FIELD_TYPE_GRASS
;   jr      nz, 11$
;   jr      19$
;11$:
    cp      #FIELD_TYPE_DESERT
    jr      nz, 12$
    call    20$
    call    30$
    jr      19$
12$:
    cp      #FIELD_TYPE_MARSH
    jr      nz, 13$
    call    20$
    call    30$
    jr      19$
13$:
    cp      #FIELD_TYPE_FOREST
    jr      nz, 14$
    call    20$
    call    30$
;   jr      19$
14$:
;   jr      19$
19$:
    inc     hl
    inc     b
    ld      a, b
    cp      #(FIELD_AREA_SIZE_X * FIELD_AREA_SIZE_Y)
    jr      c, 10$
    jr      90$

    ; 固定パターンの展開
20$:
    push    hl
    push    bc
    call    FieldGetCellAreaHead
    ld      hl, #fieldCell
    add     hl, de
    ld      de, #fieldAreaFixedPosition
    ld      b, #FIELD_AREA_CELL_SIZE_Y
21$:
    push    bc
    ld      b, #FIELD_AREA_CELL_SIZE_X
    ld      a, (de)
22$:
    rlca
    jr      nc, 23$
    ld      (hl), c
23$:
    inc     hl
    djnz    22$
    ld      bc, #(FIELD_CELL_SIZE_X - FIELD_AREA_CELL_SIZE_X)
    add     hl, bc
    inc     de
    pop     bc
    djnz    21$
    pop     bc
    pop     hl
    ret

    ; ノイズパターンの展開
30$:
    push    hl
    push    bc
    ld      hl, #fieldAreaNoisePosition
    ld      de, #fieldWork
    ld      bc, #0x0100
    ldir
    ld      de, #fieldWork
    ld      b, #0x80
31$:
    push    bc
    call    FieldGetRandom
    and     #0xfe
    ld      c, a
    ld      b, #0x00
    ld      hl, #fieldWork
    add     hl, bc
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    dec     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    dec     de
;   inc     hl
    ld      a, c
    ld      (de), a
    inc     de
    ld      a, b
    ld      (de), a
    inc     de
    pop     bc
    djnz    31$
    pop     bc
    push    bc
    call    FieldGetCellAreaHead
    ld      hl, #fieldWork
    ld      b, #0x40
32$:
    push    de
    ld      a, (hl)
    call    FieldGetCellHorizon
    inc     hl
    ld      a, (hl)
    call    FieldGetCellVertical
    inc     hl
    push    hl
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), c
    pop     hl
    pop     de
    djnz    32$
    pop     bc
    pop     hl
    ret

    ; 地形展開の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; フィールドに水を流す
;
FieldBuildWater:

    ; レジスタの保存

    ; 開始位置の取得
    call    FieldGetRandom
    and     #0xbe
    ld      e, a
    call    FieldGetRandom
    and     #0x0f
    ld      d, a
    bit     #0x02, a
    jr      nz, 110$

    ; 縦方向に流す
100$:
    ld      c, #(FIELD_CELL_SIZE_Y / 2)
101$:
    call    FieldGetRandom
    and     #0x06
    add     a, #0x05
    cp      c
    jr      c, 102$
    ld      a, c
102$:
    ld      b, a
    ld      a, c
    sub     b
    cp      #0x05
    jr      nc, 103$
    add     a, b
    ld      b, a
    xor     a
103$:
    ld      c, a
    push    de
    ld      a, #(FIELD_CELL_SIZE_X / 2)
    call    FieldGetCellHorizon
    ld      (_field + FIELD_HOLE_L), de
    pop     de
    call    210$
    ld      a, c
    or      a
    jr      z, 106$
    call    FieldGetRandom
    and     #0x07
    add     a, #0x04
    ld      b, a
    bit     #0x00, a
    jr      nz, 104$
    call    220$
    jr      105$
104$:
    call    230$
;   jr      105$
105$:
    jr      101$
106$:
    ld      b, #(FIELD_CELL_SIZE_X / 2)
    call    FieldGetRandom
    and     #0x08
    jr      nz, 107$
    call    220$
    jr      108$
107$:
    call    230$
;   jr      108$
108$:
    jr      120$

    ; 横方向に流す
110$:
    ld      c, #(FIELD_CELL_SIZE_X / 2)
111$:
    call    FieldGetRandom
    and     #0x06
    add     a, #0x05
    cp      c
    jr      c, 112$
    ld      a, c
112$:
    ld      b, a    
    ld      a, c
    sub     b
    cp      #0x05
    jr      nc, 113$
    add     a, b
    ld      b, a
    xor     a
113$:
    ld      c, a
    push    de
    ld      a, #(FIELD_CELL_SIZE_Y / 2)
    call    FieldGetCellVertical
    ld      (_field + FIELD_HOLE_L), de
    pop     de
    call    230$
    ld      a, c
    or      a
    jr      z, 116$
    call    FieldGetRandom
    and     #0x07
    add     a, #0x04
    ld      b, a
    bit     #0x00, a
    jr      nz, 114$
    call    200$
    jr      115$
114$:
    call    210$
;   jr      115$
115$:
    jr      111$
116$:
    ld      b, #(FIELD_CELL_SIZE_Y / 2)
    call    FieldGetRandom
    and     #0x08
    jr      nz, 117$
    call    200$
    jr      118$
117$:
    call    210$
;   jr      118$
118$:
;   jr      120$

    ; 川への設置
120$:
    call    FieldGetRandom
    ld      e, a
    call    FieldGetRandom
    and     #0x0f
    ld      d, a
    ld      bc, #(FIELD_CELL_SIZE_X * FIELD_CELL_SIZE_Y)
121$:
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    cp      #FIELD_TYPE_WATER
    jr      nz, 122$
    call    FieldGetCellDown
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    cp      #FIELD_TYPE_WATER
    jr      z, 122$
    ld      (hl), #FIELD_TYPE_BRICK
    call    FieldGetCellUp
    ld      (_field + FIELD_CRYSTAL_BLUE_L), de
    jr      129$
122$:
    inc     de
    ld      a, d
    and     #0x0f
    ld      d, a
    dec     bc
    ld      a, b
    or      c
    jr      nz, 121$
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_ERROR_BIT, (hl)
;   jr      129$
129$:

    ; 湖の作成
130$:
    ld      de, (_field + FIELD_HOLE_L)
    push    de
    call    FieldGetCellLeft
    ld      a, #-0x02
    call    FieldGetCellVertical
    push    de
    ld      b, #0x03
131$:
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_WATER
    call    FieldGetCellRight
    djnz    131$
    pop     de
    call    FieldGetCellDown
    call    FieldGetCellLeft
    ld      c, #0x03
132$:
    push    de
    ld      b, #0x05
133$:
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_WATER
    call    FieldGetCellRight
    djnz    133$
    pop     de
    call    FieldGetCellDown
    dec     c
    jr      nz, 132$
    call    FieldGetCellRight
    ld      b, #0x03
134$:
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_WATER
    call    FieldGetCellRight
    djnz    134$
    pop     de
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_HOLE
    ld      a, #0x03
    call    FieldGetCellVertical
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    cp      #FIELD_TYPE_WATER
    jr      z, 135$
    ld      (hl), #FIELD_TYPE_BRICK
    jr      139$
135$:
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_ERROR_BIT, (hl)
;   jr      139$
139$:

    ; 穴の取得
    ld      de, (_field + FIELD_HOLE_L)
    ld      a, e
    and     #0x3f
    add     a, a
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      (_field + FIELD_HOLE_X), a
    ld      a, d
    sla     e
    rla
    sla     e
    rla
    add     a, a
    inc     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      (_field + FIELD_HOLE_Y), a

    ; 入り口の取得
    ld      de, (_field + FIELD_HOLE_X)
    ld      a, d
    add     a, #0x05
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    ld      (_field + FIELD_ENTRANCE_X), de
    jr      90$

    ; 上へ流す
200$:
    call    300$
    jr      c, 201$
    ld      a, #-0x02
    call    FieldGetCellVertical
    djnz    200$
    or      a
201$:
    ret

    ; 下へ流す
210$:
    call    300$
    jr      c, 211$
    ld      a, #0x02
    call    FieldGetCellVertical
    djnz    210$
    or      a
211$:
    ret

    ; 左へ流す
220$:
    call    300$
    jr      c, 221$
    ld      a, #-0x02
    call    FieldGetCellHorizon
    djnz    220$
    or      a
221$:
    ret

    ; 右へ流す
230$:
    call    300$
    jr      c, 231$
    ld      a, #0x02
    call    FieldGetCellHorizon
    djnz    230$
    or      a
231$:
    ret

    ; 2x2 の川の作成
300$:
    ld      a, #FIELD_TYPE_WATER
    ld      hl, #fieldCell
    add     hl, de
    cp      (hl)
    jr      z, 301$
    push    de
    ld      (hl), a
    inc     hl
    ld      (hl), a
    ld      de, #FIELD_CELL_SIZE_X
    add     hl, de
    ld      (hl), a
    dec     hl
    ld      (hl), a
    pop     de
    or      a
    jr      309$
301$:
    scf
;   jr      309$
309$:
    ret

    ; 水を流すの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 障害物を設置する
;
FieldBuildObstacle:

    ; レジスタの保存

    ; エリア毎に障害物を設置する
    ld      hl, #fieldArea
    ld      b, #0x00
100$:
    push    bc
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    ld      c, a
110$:
    cp      #FIELD_TYPE_GRASS
    jr      nz, 120$
    ld      a, #FIELD_TYPE_STONE
    call    20$
    ld      a, (hl)
    and     #FIELD_EVENT_MASK
    cp      #FIELD_EVENT_CRYSTAL
    jr      nz, 111$
    ld      c, #FIELD_TYPE_STONE
    call    40$
    ld      (_field + FIELD_CRYSTAL_WHITE_L), de
    jr      119$
111$:
    cp      #FIELD_EVENT_BOX
    jr      nz, 119$
    call    50$
    ld      (_field + FIELD_RING_L), de
;   jr      119$
119$:
    jp      190$
120$:
    cp      #FIELD_TYPE_DESERT
    jr      nz, 130$
    call    FieldGetRandom
    and     #0x01
    add     a, #0x02
121$:
    push    af
    ld      a, #FIELD_TYPE_CACTUS
    call    20$
    pop     af
    dec     a
    jr      nz, 121$
    ld      a, (hl)
    and     #FIELD_EVENT_MASK
    cp      #FIELD_EVENT_CRYSTAL
    jr      nz, 122$    
    ld      c, #FIELD_TYPE_CACTUS
    call    40$
    ld      (_field + FIELD_CRYSTAL_YELLOW_L), de
    jr      129$
122$:
    cp      #FIELD_EVENT_BOX
    jr      nz, 129$
    call    50$
    ld      (_field + FIELD_ROD_L), de
;   jr      129$
129$:
    jr      190$
130$:
    cp      #FIELD_TYPE_MARSH
    jr      nz, 140$
    ld      a, #FIELD_TYPE_DEADTREE
    call    30$
    ld      a, (hl)
    and     #FIELD_EVENT_MASK
    cp      #FIELD_EVENT_CRYSTAL
    jr      nz, 131$
    ld      c, #FIELD_TYPE_DEADTREE
    call    40$
    ld      (_field + FIELD_CRYSTAL_RED_L), de
    jr      139$
131$:
    cp      #FIELD_EVENT_BOX
    jr      nz, 139$
    call    50$
    ld      (_field + FIELD_NECKLACE_L), de
;   jr      139$
139$:
    jr      190$
140$:
    cp      #FIELD_TYPE_FOREST
    jr      nz, 150$
    ld      a, (hl)
    and     #FIELD_EVENT_MASK
    cp      #FIELD_EVENT_CRYSTAL
    jr      nz, 141$
    ld      a, #FIELD_TYPE_TREE
    call    20$
    ld      c, #FIELD_TYPE_TREE
    call    40$
    ld      (_field + FIELD_CRYSTAL_GREEN_L), de
    jr      149$
141$:
    cp      #FIELD_EVENT_BOX
    jr      nz, 149$
    call    50$
    ld      (_field + FIELD_CANDLE_L), de
;   jr      149$
149$:
    jr      190$
150$:
;   jr      190$
190$:
    inc     hl
    pop     bc
    inc     b
    ld      a, b
    cp      #(FIELD_AREA_SIZE_X * FIELD_AREA_SIZE_Y)
    jp      c, 100$
    jp      90$

    ; ランダムな位置に障害物を設置する
20$:
    push    hl
    push    af
    call    FieldGetCellAreaRandom
    ld      hl, #fieldCell
    add     hl, de
    pop     af
    ld      d, a
    ld      a, c
    cp      (hl)
    jr      nz, 21$
    ld      (hl), d
21$:
    pop     hl
    ret

    ; 間隔をあけて障害物を設置する
30$:
    push    hl
    push    af
    call    FieldGetCellAreaHead
    call    FieldGetRandom
    and     #0x40
    add     a, #0x41
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ex      de, hl
    pop     af
    call    31$
    ld      hl, #(0x0002 * FIELD_CELL_SIZE_X + 0x0001)
    add     hl, de
    ex      de, hl
    call    31$
    ld      hl, #(0x0002 * FIELD_CELL_SIZE_X - 0x0001)
    add     hl, de
    ex      de, hl
    call    31$
    pop     hl
    ret
31$:
    push    af
    push    bc
    ld      hl, #fieldCell
    add     hl, de
    ld      b, a
    ld      a, #0x03
32$:
    push    af
    ld      a, (hl)
    cp      c
    jr      nz, 33$
    ld      (hl), b
33$:
    inc     hl
    inc     hl
    pop     af
    dec     a
    jr      nz, 32$
    pop     bc
    pop     af
    ret

    ; ランダムな障害物にクリスタルを隠す
40$:
    push    hl
    call    FieldGetCellAreaRandom
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    cp      c
    jr      nz, 41$
    or      #0x0f
    ld      (hl), a
    jr      49$
41$:
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_ERROR_BIT, (hl)
;   jr      49$
49$:
    pop     hl
    ret

    ; 宝箱を設置する
50$:
    push    hl
    ld      c, #0xff
    call    FieldGetCellAreaRandom
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    cp      #(FIELD_TYPE_FOREST + 0x01)
    jr      nc, 51$
    ld      (hl), #(FIELD_TYPE_BOX | 0x0f)
    jr      59$
51$:
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_ERROR_BIT, (hl)
;   jr      59$
59$:
    pop     hl
    ret

    ; 障害物設置の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 取得済みのアイテムが入った宝箱を開ける
;
FieldBuildBox:

    ; レジスタの保存

    ; 宝箱を開ける
    ld      hl, #(_field + FIELD_RING_L)
    ld      a, (_app + APP_GAME_ITEM)
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    rl      c
    call    c, #_FieldSetKey
    ld      b, #0x04
10$:
    rl      c
    jr      nc, 11$
    push    hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_BOX
    pop     hl
11$:
    inc     hl
    inc     hl
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; セルのパターンを作成する
;
FieldBuildPattern:

    ; レジスタの保存

    ; パターンの作成
    ld      de, #0x0000
    ld      c, #FIELD_CELL_SIZE_Y
100$:
    ld      b, #FIELD_CELL_SIZE_Y
101$:
    push    bc
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    ld      b, a
    jr      z, 110$
    cp      #FIELD_TYPE_DESERT
    jr      z, 120$
    cp      #FIELD_TYPE_MARSH
    jr      z, 130$
    cp      #FIELD_TYPE_FOREST
    jp      z, 140$
    cp      #FIELD_TYPE_WATER
    jr      z, 120$
    jp      190$

    ; 草原の作成
110$:
    ld      a, b
    or      #(FIELD_PATTERN_UP | FIELD_PATTERN_DOWN | FIELD_PATTERN_LEFT | FIELD_PATTERN_RIGHT)
    ld      c, a
    ld      b, #FIELD_TYPE_STONE
    call    20$
    cp      b
    jr      nz, 111$
    res     #FIELD_PATTERN_UP_BIT, c
111$:
    call    21$
    cp      b
    jr      nz, 112$
    res     #FIELD_PATTERN_DOWN_BIT, c
112$:
    call    22$
    cp      b
    jr      nz, 113$
    res     #FIELD_PATTERN_LEFT_BIT, c
113$:
    call    23$
    cp      b
    jr      nz, 114$
    res     #FIELD_PATTERN_RIGHT_BIT, c
114$:
    ld      (hl), c
    jp      190$

    ; 砂漠／川の作成
120$:
    ld      c, b
    call    20$
    cp      b
    jr      nz, 121$
    set     #FIELD_PATTERN_UP_BIT, c
121$:
    call    21$
    cp      b
    jr      nz, 122$
    set     #FIELD_PATTERN_DOWN_BIT, c
122$:
    call    22$
    cp      b
    jr      nz, 123$
    set     #FIELD_PATTERN_LEFT_BIT, c
123$:
    call    23$
    cp      b
    jr      nz, 124$
    set     #FIELD_PATTERN_RIGHT_BIT, c
124$:
    ld      (hl), c
    jr      190$

    ; 湿地の作成
130$:
    push    hl
    ld      c, b
    ld      h, #FIELD_TYPE_DEADTREE
    call    20$
    cp      b
    jr      z, 131$
    cp      h
    jr      nz, 132$
131$:
    set     #FIELD_PATTERN_UP_BIT, c
132$:
    call    21$
    cp      b
    jr      z, 133$
    cp      h
    jr      nz, 134$
133$:
    set     #FIELD_PATTERN_DOWN_BIT, c
134$:
    call    22$
    cp      b
    jr      z, 135$
    cp      h
    jr      nz, 136$
135$:
    set     #FIELD_PATTERN_LEFT_BIT, c
136$:
    call    23$
    cp      b
    jr      z, 137$
    cp      h
    jr      nz, 138$
137$:
    set     #FIELD_PATTERN_RIGHT_BIT, c
138$:
    pop     hl
    ld      (hl), c
    jr      190$

    ; 森林の作成
140$:
    ld      c, b
    call    21$
    cp      b
    jr      nz, 142$
    call    22$
    cp      b
    jr      nz, 141$
    call    24$
    cp      b
    jr      nz, 141$
    set     #FIELD_PATTERN_DOWN_BIT, c
    set     #FIELD_PATTERN_LEFT_BIT, c
141$:
    call    23$
    cp      b
    jr      nz, 142$
    call    25$
    cp      b
    jr      nz, 142$
    set     #FIELD_PATTERN_DOWN_BIT, c
    set     #FIELD_PATTERN_RIGHT_BIT, c
142$:
    ld      (hl), c
    jr      190$

    ; 次のセルへ
190$:
    inc     de
    pop     bc
    dec     b
    jp      nz, 101$
    dec     c
    jp      nz, 100$
    jr      90$

    ; 上のセルの取得
20$:
    push    hl
    push    de
    call    FieldGetCellUp
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    pop     de
    pop     hl
    ret

    ; 下のセルの取得
21$:
    push    hl
    push    de
    call    FieldGetCellDown
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    pop     de
    pop     hl
    ret

    ; 左のセルの取得
22$:
    push    hl
    push    de
    call    FieldGetCellLeft
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    pop     de
    pop     hl
    ret

    ; 右のセルの取得
23$:
    push    hl
    push    de
    call    FieldGetCellRight
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    pop     de
    pop     hl
    ret

    ; 左下のセルの取得
24$:
    push    hl
    push    de
    call    FieldGetCellDown
    call    FieldGetCellLeft
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    pop     de
    pop     hl
    ret

    ; 右下のセルの取得
25$:
    push    hl
    push    de
    call    FieldGetCellDown
    call    FieldGetCellRight
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    pop     de
    pop     hl
    ret

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 通り道を出現させる
;
FieldBuildPath:

    ; レジスタの保存

    ; 一歩目の通り道
100$:
    ld      de, (_field + FIELD_HOLE_L)
    ld      a, (_field + FIELD_PATH_COUNT)
    dec     a
    jr      nz, 110$
    ld      a, #0x02
    call    FieldGetCellVertical
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_BRICK
    push    de
    call    FieldGetCellLeft
    ld      hl, #fieldCell
    add     hl, de
    res     #FIELD_PATTERN_RIGHT_BIT, (hl)
    ld      a, #0x02
    call    FieldGetCellHorizon
    ld      hl, #fieldCell
    add     hl, de
    res     #FIELD_PATTERN_LEFT_BIT, (hl)
    pop     de
    call    FieldGetCellUp
    ld      hl, #fieldCell
    add     hl, de
    res     #FIELD_PATTERN_DOWN_BIT, (hl)
    jr      180$

    ; 二歩目の通り道
110$:
    dec     a
    jr      nz, 190$
    call    FieldGetCellDown
    ld      hl, #fieldCell
    add     hl, de
    ld      (hl), #FIELD_TYPE_BRICK
    call    FieldGetCellLeft
    ld      hl, #fieldCell
    add     hl, de
    res     #FIELD_PATTERN_RIGHT_BIT, (hl)
    ld      a, #0x02
    call    FieldGetCellHorizon
    ld      hl, #fieldCell
    add     hl, de
    res     #FIELD_PATTERN_LEFT_BIT, (hl)
;   jr      180$

    ; 描画のリクエスト
180$:
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_VIEW_BIT, (hl)

    ; SE の再生
    ld      a, #SOUND_SE_PATH
    call    _SoundPlaySe
;   jr      190$

    ; 通り道の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 通り道を更新する
;
FieldUpdatePath:

    ; レジスタの保存

    ; 通り道の更新
    ld      a, (_field + FIELD_PATH_COUNT)
    cp      #FIELD_PATH_COUNT_LENGTH
    jr      nc, 19$
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_ENTRANCE_BIT, a
    jr      z, 19$
    ld      hl, #(_field + FIELD_PATH_FRAME)
    inc     (hl)
    ld      a, (hl)
    cp      #FIELD_PATH_FRAME_LENGTH
    jr      c, 19$
    xor     a
    ld      (hl), a
    ld      hl, #(_field + FIELD_PATH_COUNT)
    inc     (hl)
    call    FieldBuildPath
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エラーを設定する
;
FieldSetError:

    ; レジスタの保存
    push    hl

    ; エラーの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_ERROR_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; エラーかどうかを判定する
;
_FieldIsError::

    ; レジスタの保存

    ; cf > 1 = エラー

    ; エラーの取得
    ld      a, (_field + FIELD_FLAG)
    rlca

    ; レジスタの復帰

    ; 終了
    ret

; キーを設定する
;
_FieldSetKey::

    ; レジスタの保存
    push    hl

    ; キーの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_KEY_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; エリアを取得する
;
_FieldGetArea::

    ; レジスタの保存
    push    hl
    push    de

    ; de < Y/X 位置
    ; a  > エリア

    ; エリアの取得
    ld      a, e
    rrca
    rrca
    rrca
    rrca
    and     #0x07
    ld      e, a
    ld      a, d
    rrca
    and     #0x38
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #fieldArea
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 開始位置を取得する
;
_FieldGetStartPosition::

    ; レジスタの保存
    push    hl
    push    bc

    ; de > Y/X 位置

    ; 位置の取得
    ld      hl, #fieldArea
    ld      bc, #(((FIELD_AREA_SIZE_X * FIELD_AREA_SIZE_Y) << 8) | 0x00)
10$:
    ld      a, (hl)
    and     #FIELD_EVENT_MASK
    cp      #FIELD_EVENT_START
    jr      z, 11$
    inc     hl
    inc     c
    djnz    10$
    ld      c, #0x00
11$:
    ld      b, c
    ld      c, #0xff
    call    FieldGetCellAreaRandom
    ld      a, e
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      a, d
    add     a, a
    inc     a
    ld      d, a
    ld      a, e
    and     #0x3f
    add     a, a
    inc     a
    ld      e, a

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 指定した位置から一番離れている位置を取得する
;
_FieldGetFarPosition::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > Y/X 位置

    ; 位置の取得
    ld      a, e
    rrca
    rrca
    rrca
    rrca
    add     a, #(FIELD_AREA_SIZE_X / 2)
    and     #(FIELD_AREA_SIZE_X - 0x01)
    ld      e, a
    ld      a, d
    rrca
    add     a, #((FIELD_AREA_SIZE_Y / 2) << 3)
    and     #((FIELD_AREA_SIZE_Y - 0x01) << 3)
    add     a, e
    ld      b, a
    ld      c, #0xff
    call    FieldGetCellAreaRandom
    ld      a, e
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      a, d
    add     a, a
    inc     a
    ld      d, a
    ld      a, e
    and     #0x3f
    add     a, a
    inc     a
    ld      e, a

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 指定した位置がコリジョンかどうかを判定する
;
_FieldIsCollision::

    ; レジスタ保存
    push    hl
    push    bc
    push    de

    ; de < Y/X 位置
    ; cf > 1 = コリジョンにヒット

    ; セルの取得
    ld      a, e
    srl     a
    ld      c, a
    ld      b, d
    srl     b
    xor     a
    srl     b
    rra
    srl     b
    rra
    add     a, c
    ld      c, a
    ld      hl, #fieldCell
    add     hl, bc
    ld      a, (hl)

    ; コリジョンの取得
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      b, #0x00
    ld      hl, #fieldCollision
    add     hl, bc
    inc     b
    rrc     d
    jr      nc, 20$
    inc     b
    inc     b
20$:
    rrc     e
    jr      nc, 21$
    inc     b
21$:
    ld      a, (hl)
22$:
    rlca
    djnz    22$
    rra

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 指定した位置が上レイヤかどうかを判定する
;
_FieldIsLayerUpper::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < Y/X 位置
    ; cf > 1 = 上レイヤ

    ; セルの取得
    ld      a, e
    srl     a
    ld      c, a
    ld      b, d
    srl     b
    xor     a
    srl     b
    rra
    srl     b
    rra
    add     a, c
    ld      c, a
    ld      hl, #fieldCell
    add     hl, bc
    ld      a, (hl)

    ; パターンの取得
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, a
    ld      hl, #fieldCellPatternName
    add     hl, bc
    rrc     d
    jr      nc, 20$
    inc     hl
    inc     hl
20$:
    rrc     e
    jr      nc, 21$
    inc     hl
21$:
    ld      a, (hl)

    ; レイヤの取得
    ld      e, a
    srl     e
    srl     e
    srl     e
    ld      d, #0x00
    ld      hl, #fieldLayer
    add     hl, de
    and     #0x07
    inc     a
    ld      b, a
    ld      a, (hl)
30$:
    rlca
    djnz    30$
    rra

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 穴かどうかを判定する
;
_FieldIsHole::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; cf > 1 = 穴

    ; 穴の判定
    ld      hl, (_field + FIELD_HOLE_X)
    ld      a, l
    cp      e
    jr      nz, 18$
    ld      a, h
    cp      d
    jr      nz, 18$
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 入り口かどうかを判定する
;
_FieldIsEntrance::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; cf > 1 = 入り口

    ; 入り口の判定
    ld      hl, (_field + FIELD_ENTRANCE_X)
    ld      a, l
    cp      e
    jr      nz, 18$
    ld      a, h
    cp      d
    jr      nz, 18$
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 休息できる場所かどうかを判定する
;
_FieldIsRest::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; cf > 1 = 入り口

    ; セルの取得
    ld      a, e
    srl     a
    ld      c, a
    ld      b, d
    srl     b
    xor     a
    srl     b
    rra
    srl     b
    rra
    add     a, c
    ld      c, a
    ld      hl, #fieldCell
    add     hl, bc
    ld      a, (hl)

    ; セルの判定
    and     #FIELD_TYPE_MASK
    cp      #FIELD_TYPE_GRASS
    jr      nz, 10$
    scf
    jr      19$
10$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 通り道が出現したかどうかを判定する
;
_FieldIsPath::

    ; レジスタの保存

    ; cf > 1 = 通り道が出現

    ; 通り道の判定
    ld      a, (_field + FIELD_PATH_COUNT)
    cp      #FIELD_PATH_COUNT_LENGTH
    ccf

    ; レジスタの復帰

    ; 終了
    ret

; エリアのセル位置を取得する
;
FieldGetCellAreaHead:

    ; レジスタの保存

    ; b  < エリア
    ; de > エリアの左上のセル位置

    ; 位置の取得
    ld      a, b
    and     #0x38
    rrca
    rrca
    ld      d, a
    ld      a, b
    and     #0x07
    add     a, a
    add     a, a
    add     a, a
    ld      e, a

    ; レジスタの復帰

    ; 終了
    ret

FieldGetCellAreaRandom:

    ; レジスタの保存
    push    hl
    push    bc

    ; b  < エリア
    ; c  < 地形
    ; de > エリアのセル位置

    ; 位置の取得
    call    FieldGetCellAreaHead
    ld      hl, #fieldCell
    add     hl, de
    call    FieldGetRandom
    and     #0xc7
    ld      e, a
    call    FieldGetRandom
    and     #0x01
    ld      d, a
    ld      b, #(FIELD_AREA_CELL_SIZE_X * FIELD_AREA_CELL_SIZE_Y)
10$:
    ld      a, c
    cp      #0xff
    jr      z, 11$
    push    hl
    add     hl, de
    ld      a, (hl)
    pop     hl
    cp      c
    jr      z, 14$
    jr      12$
11$:
    push    hl
    add     hl, de
    ld      a, (hl)
    pop     hl
    cp      #(FIELD_TYPE_FOREST + 0x01)
    jr      c, 14$
;   jr      12$
12$:
    inc     e
    ld      a, e
    and     #0x07
    jr      nz, 13$
    ld      a, e
    and     #0xc0
    add     a, #0x40
    ld      e, a
    ld      a, d
    adc     a, #0x00
    and     #0x01
    ld      d, a
13$:
    djnz    10$
14$:
    ld      bc, #fieldCell
    or      a
    sbc     hl, bc
    add     hl, de
    ex      de, hl

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 上下左右のセル位置を取得する
;
FieldGetCellVertical:

    ; レジスタの保存

    ; de < セル位置
    ; a  < 移動量
    ; de > 移動後のセル位置

    ; 位置の取得
    sla     e
    rl      d
    sla     e
    rl      d
    add     a, d
    and     #0x3f
    ld      d, a
    srl     d
    rr      e
    srl     d
    rr      e

    ; レジスタの復帰

    ; 終了
    ret

FieldGetCellHorizon:

    ; レジスタの保存

    ; de < セル位置
    ; a  < 移動量
    ; de > 移動後のセル位置

    ; 位置の取得
    add     a, e
    and     #0x3f
    push    af
    ld      a, e
    and     #0xc0
    ld      e, a
    pop     af
    add     a, e
    ld      e, a

    ; レジスタの復帰

    ; 終了
    ret

FieldGetCellUp:

    ; レジスタの保存

    ; de < セル位置
    ; de > 上のセル位置

    ; 位置の取得
    ld      a, #-0x01
    call    FieldGetCellVertical

    ; レジスタの復帰

    ; 終了
    ret

FieldGetCellDown:

    ; レジスタの保存

    ; de < セル位置
    ; de > 下のセル位置

    ; 位置の取得
    ld      a, #0x01
    call    FieldGetCellVertical

    ; レジスタの復帰

    ; 終了
    ret

FieldGetCellLeft:

    ; レジスタの保存

    ; de < セル位置
    ; de > 左のセル位置

    ; 位置の取得
    ld      a, #-0x01
    call    FieldGetCellHorizon

    ; レジスタの復帰

    ; 終了
    ret

FieldGetCellRight:

    ; レジスタの保存

    ; de < セル位置
    ; de > 右のセル位置

    ; 位置の取得
    ld      a, #0x01
    call    FieldGetCellHorizon

    ; レジスタの復帰

    ; 終了
    ret

; フィールドを上下左右に移動する
;
_FieldMoveUp::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した

    ; コリジョンの判定
    ld      c, e
    ld      b, d
    ld      a, d
    dec     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 18$
    scf
    jr      19$
18$:
    ld      d, b
    or      a
;   jr      19$
19$:
    ld      e, c

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_FieldMoveDown::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した

    ; コリジョンの判定
    ld      c, e
    ld      b, d
    ld      a, d
    inc     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 18$
    scf
    jr      19$
18$:
    ld      d, b
    or      a
;   jr      19$
19$:
    ld      e, c

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_FieldMoveLeft::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した

    ; コリジョンの判定
    ld      c, e
    ld      a, e
    sub     #0x02
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      a, e
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    scf
    jr      19$
18$:
    ld      e, c
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_FieldMoveRight::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した

    ; コリジョンの判定
    ld      c, e
    ld      a, e
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 18$
    scf
    jr      19$
18$:
    ld      e, c
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; フィールドを補正付きで上下左右に移動する
;
_FieldCorrectUp::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した
    ; a  > 取得したアイテム

    ; コリジョンの判定
    ld      c, e
    ld      b, d
    ld      a, d
    dec     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 10$
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 11$
    ld      e, c
    xor     a
    scf
    jr      19$
10$:
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 12$
    ld      e, c
    ld      d, b
    call    _FieldMoveLeft
    ld      a, #0x00
    jr      19$
11$:
    ld      a, e
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      e, c
    ld      d, b
    call    _FieldMoveRight
    ld      a, #0x00
    jr      19$
12$:
    bit     #0x00, c
    jr      z, 18$
    call    FieldPickupItem
    ld      e, c
    ld      d, b
    or      a
    jr      19$
18$:
    ld      e, c
    ld      d, b
    xor     a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_FieldCorrectDown::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した
    ; a  > 取得したアイテム

    ; コリジョンの判定
    ld      c, e
    ld      b, d
    ld      a, d
    inc     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 10$
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 11$
    ld      e, c
    xor     a
    scf
    jr      19$
10$:
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 12$
    ld      e, c
    ld      d, b
    call    _FieldMoveLeft
    ld      a, #0x00
    jr      19$
11$:
    ld      a, e
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      e, c
    ld      d, b
    call    _FieldMoveRight
    ld      a, #0x00
    jr      19$
12$:
    bit     #0x00, c
    jr      z, 18$
    call    FieldPickupItem
    ld      e, c
    ld      d, b
    or      a
    jr      19$
18$:
    ld      e, c
    ld      d, b
    xor     a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_FieldCorrectLeft::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した

    ; コリジョンの判定
    ld      c, e
    ld      b, d
    ld      a, e
    sub     #0x02
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 10$
    ld      a, e
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    scf
    jr      19$
10$:
    ld      a, b
    inc     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 11$
    ld      e, c
    ld      d, b
    call    _FieldMoveDown
    jr      19$
11$:
    ld      a, b
    dec     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      e, c
    ld      d, b
    call    _FieldMoveUp
    jr      19$
18$:
    ld      e, c
    ld      d, b
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_FieldCorrectRight::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; de > 移動後の Y/X 位置
    ; cf > 1 = 移動した

    ; コリジョンの判定
    ld      c, e
    ld      b, d
    ld      a, e
    inc     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsCollision
    jr      c, 10$
    scf
    jr      19$
10$:
    ld      a, b
    inc     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 11$
    ld      e, c
    ld      d, b
    call    _FieldMoveDown
    jr      19$
11$:
    ld      a, b
    dec     a
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    call    _FieldIsCollision
    jr      c, 18$
    ld      e, c
    ld      d, b
    call    _FieldMoveUp
    jr      19$
18$:
    ld      e, c
    ld      d, b
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; アイテムを拾う
;
FieldPickupItem:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < Y/X 位置
    ; a  > 拾ったアイテム

    ; セルの取得
    ld      a, e
    srl     a
    ld      e, a
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a

    ; アイテムの検索
    ld      hl, #(_field + FIELD_CRYSTAL_RED_L)
    ld      b, #ITEM_CRYSTAL_RED
10$:
    ld      a, (hl)
    inc     hl
    cp      e
    jr      z, 11$
    inc     hl
    jr      12$
11$:
    ld      a, (hl)
    inc     hl
    cp      d
    jr      z, 13$
12$:
    inc     b
    ld      a, b
    cp      #ITEM_LENGTH
    jr      c, 10$
    jr      18$
13$:
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    and     #FIELD_TYPE_MASK
    cp      #FIELD_TYPE_BOX
    jr      nz, 14$
    ld      a, (_field + FIELD_FLAG)
    bit     #FIELD_FLAG_KEY_BIT, a
    jr      z, 18$
    ld      a, (hl)
    and     #FIELD_PATTERN_MASK
    jr      z, 14$
    ld      (hl), #FIELD_TYPE_BOX
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_VIEW_BIT, (hl)
;   jr      14$
14$:
    ld      a, b
    jr      19$
18$:
    xor     a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 視野内のフィールドを描画させる
;
_FieldView:

    ; レジスタの保存
    push    hl

    ; フラグの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_VIEW_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 視野内のフィールドを描画する
;
FieldPrintView:

    ; レジスタの保存

    ; セルの取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      e, c
    srl     e
    ld      d, b
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)

    ; セルの描画
    rr      b
    jr      c, 100$
    rr      c
    jr      nc, 110$
    jr      120$
100$:
    rr      c
    jr      nc, 130$
    jp      140$

    ; X:0, Y:0
110$:
    ld      c, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y)
111$:
    push    de
    push    hl
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X)
112$:
    push    de
    call    150$
    call    160$
    pop     de
    call    170$
    djnz    112$
    pop     hl
    ld      de, #0x0040
    add     hl, de
    pop     de
    call    180$
    dec     c
    jr      nz, 111$
    jp      190$

    ; X:1, Y:0
120$:
    ld      c, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y)
121$:
    push    de
    push    hl
    push    de
    push    hl
    call    150$
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    push    bc
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
    pop     hl
    inc     hl
    pop     de
    call    170$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X - 0x01)
122$:
    push    de
    call    150$
    call    160$
    pop     de
    call    170$
    djnz    122$
    call    150$
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    push    bc
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   inc     de
    pop     hl
    ld      de, #0x0040
    add     hl, de
    pop     de
    call    180$
    dec     c
    jr      nz, 121$
    jp      190$

    ; X:0, Y:1
130$:
    push    de
    push    hl
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X)
131$:
    push    de
    call    150$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    170$
    djnz    131$
    pop     hl
    ld      de, #0x0020
    add     hl, de
    pop     de
    call    180$
    ld      c, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y - 0x01)
132$:
    push    de
    push    hl
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X)
133$:
    push    de
    call    150$
    call    160$
    pop     de
    call    170$
    djnz    133$
    pop     hl
    ld      de, #0x0040
    add     hl, de
    pop     de
    call    180$
    dec     c
    jr      nz, 132$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X)
134$:
    push    de
    call    150$
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    170$
    djnz    134$
    jp      190$

    ; X:1, Y:1
140$:
    push    de
    push    hl
    push    de
    call    150$
    inc     de
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    170$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X - 0x01)
141$:
    push    de
    call    150$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de    
    call    170$
    djnz    141$
    call    150$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   inc     hl
    pop     hl
    ld      de, #0x0020
    add     hl, de
    pop     de
    call    180$
    ld      c, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y - 0x01)
142$:
    push    de
    push    hl
    push    de
    push    hl
    call    150$
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de    
    push    bc
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
    pop     hl
    inc     hl
    pop     de
    call    170$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X - 0x01)
143$:
    push    de
    call    150$
    call    160$
    pop     de
    call    170$
    djnz    143$
    call    150$
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    push    bc
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   inc     de
    pop     hl
    ld      de, #0x0040
    add     hl, de
    pop     de
    call    180$
    dec     c
    jr      nz, 142$
    push    de
    call    150$
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    170$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X - 0x01)
144$:
    push    de
    call    150$
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    170$
    djnz    144$
    call    150$
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   inc     hl
    jr      190$

    ; パターンネームの取得
150$:
    push    hl
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #fieldCellPatternName
    add     hl, de
    ex      de, hl
    pop     hl
    ret

    ; 2x2 の展開
160$:
    push    bc
    ld      bc, #(0x0020 - 0x0001)
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    or      a
    sbc     hl, bc
    pop     bc
    ret

    ; 次の列へ
170$:
    ld      a, e
    push    af
    inc     a
    and     #0x3f
    ld      e, a
    pop     af
    and     #0xc0
    add     a, e
    ld      e, a
    ret

    ; 次の行へ
180$:
    ld      a, e
    add     a, #0x40
    ld      e, a
    ld      a, d
    adc     a, #0x00
    and     #0x0f
    ld      d, a
    ret

    ; 描画の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 上にスクロールさせる
;
_FieldScrollUp::

    ; レジスタの保存
    push    hl

    ; フラグの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_SCROLL_UP_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 上スクロールを描画する
;
FieldPrintScrollUp:

    ; レジスタの保存

    ; パターンネームをずらす
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + (CAMERA_VIEW_SIZE_Y - 0x0002) * 0x0020 + (CAMERA_VIEW_SIZE_X - 0x0001))
    ld      de, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + (CAMERA_VIEW_SIZE_Y - 0x0001) * 0x0020 + (CAMERA_VIEW_SIZE_X - 0x0001))
    ld      a, #(CAMERA_VIEW_SIZE_Y - 0x01)
10$:
    ld      bc, #CAMERA_VIEW_SIZE_X
    lddr
    ld      bc, #-(0x0020 - CAMERA_VIEW_SIZE_X)
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; セルの取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      e, c
    srl     e
    ld      d, b
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)

    ; スクロールの描画
    call    FieldPrintScrollVertical

    ; レジスタの復帰

    ; 終了
    ret

; 下にスクロールさせる
;
_FieldScrollDown::

    ; レジスタの保存
    push    hl

    ; フラグの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_SCROLL_DOWN_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 下スクロールを描画する
;
FieldPrintScrollDown:

    ; レジスタの保存

    ; パターンネームをずらす
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + 0x0001 * 0x0020)
    ld      de, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + 0x0000 * 0x0020)
    ld      a, #(CAMERA_VIEW_SIZE_Y - 0x01)
10$:
    ld      bc, #CAMERA_VIEW_SIZE_X
    ldir
    ld      bc, #(0x0020 - CAMERA_VIEW_SIZE_X)
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; セルの取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      e, c
    srl     e
    ld      a, b
    add     a, #(CAMERA_VIEW_SIZE_Y - 0x01)
    and     #(FIELD_SIZE_Y - 0x01)
    ld      b, a
    ld      d, a
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + (CAMERA_VIEW_SIZE_Y - 0x0001) * 0x0020)

    ; スクロールの描画
    call    FieldPrintScrollVertical

    ; レジスタの復帰

    ; 終了
    ret

; 上下スクロールを描画する
;
FieldPrintScrollVertical:

    ; レジスタの保存

    ; hl < パターンネーム
    ; de < セルのオフセット
    ; bc < スクロール Y/X 位置

    ; セルの描画
    rr      b
    jr      c, 10$
    rr      c
    jr      nc, 20$
    jr      30$
10$:
    rr      c
    jr      nc, 40$
    jr      50$

    ; X:0, Y:0
20$:
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X)
21$:
    push    de
    call    60$
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    70$
    djnz    21$
    jp      90$
    
    ; X:1, Y:0
30$:
    push    de
    call    60$
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    70$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X - 0x01)
31$:
    push    de
    call    60$
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    70$
    djnz    31$
    call    60$
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   inc     hl
    jr      90$

    ; X:0, Y:1
40$:
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X)
41$:
    push    de
    call    60$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    70$
    djnz    41$
    jr      90$
    
    ; X:1, Y:1
50$:
    push    de
    call    60$
    inc     de
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    70$
    ld      b, #(CAMERA_VIEW_SIZE_X / FIELD_NAME_SIZE_X - 0x01)
51$:
    push    de
    call    60$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
;   inc     de
    inc     hl
    pop     de
    call    70$
    djnz    51$
    call    60$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   inc     hl
    jr      90$

    ; パターンネームの取得
60$:
    push    hl
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #fieldCellPatternName
    add     hl, de
    ex      de, hl
    pop     hl
    ret

    ; 次の列へ
70$:
    ld      a, e
    push    af
    inc     a
    and     #0x3f
    ld      e, a
    pop     af
    and     #0xc0
    add     a, e
    ld      e, a
    ret

    ; 次の行へ
80$:
    ld      a, e
    add     a, #0x40
    ld      e, a
    ld      a, d
    adc     a, #0x00
    and     #0x0f
    ld      d, a
    ret

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 左にスクロールさせる
;
_FieldScrollLeft::

    ; レジスタの保存
    push    hl

    ; フラグの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_SCROLL_LEFT_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 左スクロールを描画する
;
FieldPrintScrollLeft:

    ; レジスタの保存

    ; パターンネームをずらす
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + CAMERA_VIEW_SIZE_X - 0x0002)
    ld      de, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + CAMERA_VIEW_SIZE_X - 0x0001)
    ld      a, #CAMERA_VIEW_SIZE_Y
10$:
    ld      bc, #(CAMERA_VIEW_SIZE_X - 0x0001)
    lddr
    ld      bc, #(0x0020 + (CAMERA_VIEW_SIZE_X - 0x01))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; セルの取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      e, c
    srl     e
    ld      d, b
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)

    ; スクロールの描画
    call    FieldPrintScrollHorizon

    ; レジスタの復帰

    ; 終了
    ret

; 右にスクロールさせる
;
_FieldScrollRight::

    ; レジスタの保存
    push    hl

    ; フラグの設定
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_SCROLL_RIGHT_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 右スクロールを描画する
;
FieldPrintScrollRight:

    ; レジスタの保存

    ; パターンネームをずらす
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + 0x0001)
    ld      de, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + 0x0000)
    ld      a, #CAMERA_VIEW_SIZE_Y
10$:
    ld      bc, #(CAMERA_VIEW_SIZE_X - 0x0001)
    ldir
    ld      bc, #(0x0020 - (CAMERA_VIEW_SIZE_X - 0x01))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; セルの取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, c
    add     a, #(CAMERA_VIEW_SIZE_X - 0x01)
    and     #(FIELD_SIZE_X - 0x01)
    ld      c, a
    ld      e, a
    srl     e
    ld      d, b
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET + CAMERA_VIEW_SIZE_X - 0x0001)

    ; スクロールの描画
    call    FieldPrintScrollHorizon

    ; レジスタの復帰

    ; 終了
    ret

; 左右スクロールを描画する
;
FieldPrintScrollHorizon:

    ; レジスタの保存

    ; セルの描画
    rr      b
    jr      c, 10$
    rr      c
    jr      nc, 20$
    jr      30$
10$:
    rr      c
    jr      nc, 40$
    jr      50$

    ; X:0, Y:0
20$:
    ld      b, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y)
21$:
    push    bc
    push    de
    call    60$
    ld      bc, #0x0020
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
    add     hl, bc
    pop     de
    pop     bc
    call    80$
    djnz    21$
    jp      90$
    
    ; X:1, Y:0
30$:
    ld      b, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y)
31$:
    push    bc
    push    de
    call    60$
    ld      bc, #0x0020
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
    add     hl, bc
    pop     de
    pop     bc
    call    80$
    djnz    31$
    jp      90$

    ; X:0, Y:1
40$:
    push    de
    call    60$
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
    ld      bc, #0x0020
    add     hl, bc
    pop     de
    call    80$
    ld      b, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y - 0x01)
41$:
    push    bc
    push    de
    call    60$
    ld      bc, #0x0020
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
    add     hl, bc
    pop     de
    pop     bc
    call    80$
    djnz    41$
    call    60$
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   ld      bc, #0x0020
;   add     hl, bc
    jr      90$
    
    ; X:1, Y:1
50$:
    push    de
    call    60$
    inc     de
    inc     de
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
    ld      bc, #0x0020
    add     hl, bc
    pop     de
    call    80$
    ld      b, #(CAMERA_VIEW_SIZE_Y / FIELD_NAME_SIZE_Y - 0x01)
51$:
    push    bc
    push    de
    call    60$
    ld      bc, #0x0020
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     de
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
;   inc     de
    add     hl, bc
    pop     de
    pop     bc
    call    80$
    djnz    51$
    call    60$
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     de
;   ld      bc, #0x0020
;   add     hl, bc
    jr      90$

    ; パターンネームの取得
60$:
    push    hl
    ld      hl, #fieldCell
    add     hl, de
    ld      a, (hl)
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #fieldCellPatternName
    add     hl, de
    ex      de, hl
    pop     hl
    ret

    ; 次の列へ
70$:
    ld      a, e
    push    af
    inc     a
    and     #0x3f
    ld      e, a
    pop     af
    and     #0xc0
    add     a, e
    ld      e, a
    ret

    ; 次の行へ
80$:
    ld      a, e
    add     a, #0x40
    ld      e, a
    ld      a, d
    adc     a, #0x00
    and     #0x0f
    ld      d, a
    ret

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; デバッグ用にマップを描画する
;
_FieldPrintMap::

    ; レジスタの保存

    ; マップの描画
    ld      a, (_camera + CAMERA_POSITION_X)
    srl     a
    ld      e, a
    ld      a, (_camera + CAMERA_POSITION_Y)
    ld      d, a
    srl     d
    xor     a
    srl     d
    rr      a
    srl     d
    rr      a
    add     a, e
    ld      e, a
    ld      hl, #fieldCell
    add     hl, de
    ld      de, #_patternName
    ld      c, #0x18
10$:
    ld      b, #0x20
11$:
    push    bc
    push    hl
    ld      c, (hl)
    srl     c
    srl     c
    srl     c
    srl     c
    ld      b, #0x00
    ld      hl, #fieldMapPatternName
    add     hl, bc
    ld      a, (hl)
    ld      (de), a
    inc     de
    pop     hl
    inc     hl
    pop     bc
    djnz    11$
    push    bc
    ld      bc, #(FIELD_CELL_SIZE_X - 0x0020)
    add     hl, bc
    pop     bc
    dec     c
    jr      nz, 10$

    ; レジスタの復帰

    ; 終了
    ret

; 乱数を取得する
;
FieldGetRandom:
    
    ; レジスタの保存
    push    hl
    push    de

    ; a > random number
    
    ; 乱数の生成
    ld      hl, (_field + FIELD_RANDOM_L)
    ld      e, l
    ld      d, h
    add     hl, hl
    add     hl, hl
    add     hl, de
    ld      de, #0x2019
    add     hl, de
    ld      (_field + FIELD_RANDOM_L), hl
    ld      a, h
    
    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

; 定数の定義
;

; フィールドの初期値
;
fieldDefault:

    .db     FIELD_STATE_NULL
    .db     FIELD_FLAG_NULL
    .dw     FIELD_RANDOM_NULL
    .db     FIELD_HOLE_NULL
    .db     FIELD_HOLE_NULL
    .db     FIELD_HOLE_NULL
    .db     FIELD_HOLE_NULL
    .db     FIELD_ENTRANCE_NULL
    .db     FIELD_ENTRANCE_NULL
    .db     FIELD_PATH_COUNT_NULL
    .db     FIELD_PATH_FRAME_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL
    .dw     FIELD_ITEM_NULL

; セル
;
fieldCellPatternName:

    ; 草原
    .db     0xc8, 0xca, 0xcd, 0xcf, 0xcb, 0xcc, 0xcd, 0xcf, 0xc8, 0xca, 0xcb, 0xcc, 0xcb, 0xcc, 0xcb, 0xcc
    .db     0xc9, 0xca, 0xce, 0xcf, 0xc0, 0xcc, 0xce, 0xcf, 0xc9, 0xca, 0xc0, 0xcc, 0xc0, 0xcc, 0xc0, 0xcc
    .db     0xc8, 0xc9, 0xcd, 0xce, 0xcb, 0xc0, 0xcd, 0xce, 0xc8, 0xc9, 0xcb, 0xc0, 0xcb, 0xc0, 0xcb, 0xc0
    .db     0xc9, 0xc9, 0xce, 0xce, 0xc0, 0xc0, 0xce, 0xce, 0xc9, 0xc9, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0
    ; 砂漠
    .db     0xd8, 0xda, 0xdd, 0xdf, 0xdb, 0xdc, 0xdd, 0xdf, 0xd8, 0xda, 0xdb, 0xdc, 0xdb, 0xdc, 0xdb, 0xdc
    .db     0xd9, 0xda, 0xde, 0xdf, 0xd0, 0xdc, 0xde, 0xdf, 0xd9, 0xda, 0xd0, 0xdc, 0xd0, 0xdc, 0xd0, 0xdc
    .db     0xd8, 0xd9, 0xdd, 0xde, 0xdb, 0xd0, 0xdd, 0xde, 0xd8, 0xd9, 0xdb, 0xd0, 0xdb, 0xd0, 0xdb, 0xd0
    .db     0xd9, 0xd9, 0xde, 0xde, 0xd0, 0xd0, 0xde, 0xde, 0xd9, 0xd9, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0
    ; 湿地
    .db     0xe8, 0xea, 0xed, 0xef, 0xeb, 0xec, 0xed, 0xef, 0xe8, 0xea, 0xeb, 0xec, 0xeb, 0xec, 0xeb, 0xec
    .db     0xe9, 0xea, 0xee, 0xef, 0xe0, 0xec, 0xee, 0xef, 0xe9, 0xea, 0xe0, 0xec, 0xe0, 0xec, 0xe0, 0xec
    .db     0xe8, 0xe9, 0xed, 0xee, 0xeb, 0xe0, 0xed, 0xee, 0xe8, 0xe9, 0xeb, 0xe0, 0xeb, 0xe0, 0xeb, 0xe0
    .db     0xe9, 0xe9, 0xee, 0xee, 0xe0, 0xe0, 0xee, 0xee, 0xe9, 0xe9, 0xe0, 0xe0, 0xe0, 0xe0, 0xe0, 0xe0
    ; 森林
    .db     0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc7
    .db     0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc5, 0xc7, 0xc4, 0xc5, 0xc5, 0xc7
    .db     0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc4, 0xc4, 0xc5, 0xc6, 0xc4
    .db     0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc6, 0xc7, 0xc4, 0xc5, 0xc5, 0xc4, 0xc4, 0xc5, 0xc5, 0xc4
    ; 煉瓦
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3, 0xa0, 0xa1, 0xa2, 0xa3
    ; 穴
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3, 0xb0, 0xb1, 0xb2, 0xb3
    ; 川
    .db     0xf8, 0xfa, 0xfd, 0xff, 0xfb, 0xfc, 0xfd, 0xff, 0xf8, 0xfa, 0xfb, 0xfc, 0xfb, 0xfc, 0xfb, 0xfc
    .db     0xf9, 0xfa, 0xfe, 0xff, 0xf0, 0xfc, 0xfe, 0xff, 0xf9, 0xfa, 0xf0, 0xfc, 0xf0, 0xfc, 0xf0, 0xfc
    .db     0xf8, 0xf9, 0xfd, 0xfe, 0xfb, 0xf0, 0xfd, 0xfe, 0xf8, 0xf9, 0xfb, 0xf0, 0xfb, 0xf0, 0xfb, 0xf0
    .db     0xf9, 0xf9, 0xfe, 0xfe, 0xf0, 0xf0, 0xfe, 0xfe, 0xf9, 0xf9, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0
    ; 岩
    .db     0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf
    .db     0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf
    .db     0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf
    .db     0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xac, 0xad, 0xae, 0xaf, 0xaa, 0xab, 0xae, 0xaf
    ; サボテン
    .db     0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf
    .db     0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf
    .db     0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf
    .db     0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xbc, 0xbd, 0xbe, 0xbf, 0xba, 0xbb, 0xbe, 0xbf
    ; 枯木
    .db     0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7
    .db     0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7
    .db     0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7
    .db     0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe6, 0xe7, 0xe4, 0xe5, 0xe2, 0xe3
    ; 木
    .db     0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7
    .db     0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7
    .db     0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7
    .db     0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7, 0xb4, 0xb5, 0xb6, 0xb7
    ; 宝箱
    .db     0x9c, 0x9d, 0x9e, 0x9f, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b
    .db     0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b
    .db     0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b
    .db     0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b, 0x98, 0x99, 0x9a, 0x9b

; エリア
;
fieldAreaDefault:

    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_NULL | FIELD_EVENT_CRYSTAL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_HIGH | FIELD_EVENT_BOX
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_DESERT | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_MARSH | FIELD_ENEMY_NULL | FIELD_EVENT_CRYSTAL
    .db     FIELD_TYPE_MARSH | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_MARSH | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_MARSH | FIELD_ENEMY_HIGH | FIELD_EVENT_BOX
    .db     FIELD_TYPE_MARSH | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_MARSH | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_CRYSTAL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_BOX
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_FOREST | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_START
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_CRYSTAL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_NULL | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_BOX
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL
    .db     FIELD_TYPE_GRASS | FIELD_ENEMY_HIGH | FIELD_EVENT_NULL

fieldAreaFixedPosition:

    .db     0b00000000
    .db     0b00111100
    .db     0b01111110
    .db     0b01111110
    .db     0b01111110
    .db     0b01111110
    .db     0b00111100
    .db     0b00000000

fieldAreaNoisePosition:

    .db     -0x02, -0x02, -0x01, -0x02,  0x00, -0x02,  0x01, -0x02,  0x02, -0x02,  0x03, -0x02,  0x04, -0x02,  0x05, -0x02,  0x06, -0x02,  0x07, -0x02,  0x08, -0x02,  0x09, -0x02
    .db     -0x02, -0x01, -0x01, -0x01,  0x00, -0x01,  0x01, -0x01,  0x02, -0x01,  0x03, -0x01,  0x04, -0x01,  0x05, -0x01,  0x06, -0x01,  0x07, -0x01,  0x08, -0x01,  0x09, -0x01
    .db     -0x02,  0x00, -0x01,  0x00,  0x00,  0x00,  0x01,  0x00,  0x02,  0x00,  0x03,  0x00,  0x04,  0x00,  0x05,  0x00,  0x06,  0x00,  0x07,  0x00,  0x08,  0x00,  0x09,  0x00
    .db     -0x02,  0x01, -0x01,  0x01,  0x00,  0x01,  0x01,  0x01,  0x02,  0x01,  0x03,  0x01,  0x04,  0x01,  0x05,  0x01,  0x06,  0x01,  0x07,  0x01,  0x08,  0x01,  0x09,  0x01
    .db     -0x02,  0x02, -0x01,  0x02,  0x00,  0x02,  0x01,  0x02,                                                          0x06,  0x02,  0x07,  0x02,  0x08,  0x02,  0x09,  0x02
    .db     -0x02,  0x03, -0x01,  0x03,  0x00,  0x03,  0x01,  0x03,                                                          0x06,  0x03,  0x07,  0x03,  0x08,  0x03,  0x09,  0x03
    .db     -0x02,  0x04, -0x01,  0x04,  0x00,  0x04,  0x01,  0x04,                                                          0x06,  0x04,  0x07,  0x04,  0x08,  0x04,  0x09,  0x04
    .db     -0x02,  0x05, -0x01,  0x05,  0x00,  0x05,  0x01,  0x05,                                                          0x06,  0x05,  0x07,  0x05,  0x08,  0x05,  0x09,  0x05
    .db     -0x02,  0x06, -0x01,  0x06,  0x00,  0x06,  0x01,  0x06,  0x02,  0x06,  0x03,  0x06,  0x04,  0x06,  0x05,  0x06,  0x06,  0x06,  0x07,  0x06,  0x08,  0x06,  0x09,  0x06
    .db     -0x02,  0x07, -0x01,  0x07,  0x00,  0x07,  0x01,  0x07,  0x02,  0x07,  0x03,  0x07,  0x04,  0x07,  0x05,  0x07,  0x06,  0x07,  0x07,  0x07,  0x08,  0x07,  0x09,  0x07
    .db     -0x02,  0x08, -0x01,  0x08,  0x00,  0x08,  0x01,  0x08,  0x02,  0x08,  0x03,  0x08,  0x04,  0x08,  0x05,  0x08,  0x06,  0x08,  0x07,  0x08,  0x08,  0x08,  0x09,  0x08
    .db     -0x02,  0x09, -0x01,  0x09,  0x00,  0x09,  0x01,  0x09,  0x02,  0x09,  0x03,  0x09,  0x04,  0x09,  0x05,  0x09,  0x06,  0x09,  0x07,  0x09,  0x08,  0x09,  0x09,  0x09

; コリジョン
;
fieldCollision:

    .db     0b00000000  ; 草原
    .db     0b00000000  ; 砂漠
    .db     0b00000000  ; 湿地
    .db     0b00000000  ; 森林
    .db     0b00000000  ; 煉瓦
    .db     0b00000000  ; 穴
    .db     0b11110000  ; 川
    .db     0b00110000  ; 岩
    .db     0b00110000  ; サボテン
    .db     0b00110000  ; 枯木
    .db     0b00110000  ; 木
    .db     0b00110000  ; 宝箱

; レイヤ
;
fieldLayer:

    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b11001100
    .db     0b00000000, 0b00111100
    .db     0b00001100, 0b00111100
    .db     0b00001100, 0b00000000
    .db     0b00000000, 0b00000000
    .db     0b00111100, 0b00000000
    .db     0b00000000, 0b00000000

; マップ
;
fieldMapPatternName:

    .db     0xc0, 0xd0, 0xe0, 0xc1, 0xa4, 0xa5, 0xf0, 0xa8, 0xc2, 0xe1, 0xc3, 0xd1, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; フィールド
;
_field::

    .ds     FIELD_LENGTH

; セル
;
fieldCell:
    
    .ds     FIELD_CELL_SIZE_X * FIELD_CELL_SIZE_Y

; エリア
;
fieldArea:

    .ds     FIELD_AREA_SIZE_X * FIELD_AREA_SIZE_Y

; 作業領域
;
fieldWork:

    .ds     0x0100
