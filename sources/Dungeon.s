; Dungeon.s : ダンジョン
;


; モジュール宣言
;
    .module Dungeon

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include	"Dungeon.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ダンジョンを初期化する
;
_DungeonInitialize::
    
    ; レジスタの保存
    
    ; ダンジョンの初期化
    ld      hl, #dungeonDefault
    ld      de, #_dungeon
    ld      bc, #DUNGEON_LENGTH
    ldir

    ; 状態の設定
    ld      a, #DUNGEON_STATE_NULL
    ld      (_dungeon + DUNGEON_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ダンジョンを更新する
;
_DungeonUpdate::
    
    ; レジスタの保存

    ; 扉の更新
    call    DungeonUpdateGate

    ; レジスタの復帰
    
    ; 終了
    ret

; ダンジョンを描画する
;
_DungeonRender::

    ; レジスタの保存

    ; 扉の描画
    call    DungeonPrintGate

    ; レジスタの復帰

    ; 終了
    ret

; 扉を更新する
;
DungeonUpdateGate:

    ; レジスタの保存

    ; 0x01 : 扉の出現
10$:
    ld      a, (_dungeon + DUNGEON_GATE_STATE)
    dec     a
    jr      nz, 20$
    ld      hl, #(_dungeon + DUNGEON_GATE_POSITION_Y)
    ld      a, (hl)
    or      a
    jr      z, 11$
    dec     (hl)
    jr      19$
11$:
    ld      hl, #(_dungeon + DUNGEON_GATE_FRAME)
    dec     (hl)
    jr      nz, 19$
    ld      (hl), #DUNGEON_GATE_FRAME_OPEN
    ld      hl, #(_dungeon + DUNGEON_GATE_STATE)
    inc     (hl)
19$:
    jr      90$

    ; 0x02 : 扉を開く
20$:
;   jr      90$

    ; 扉の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 扉を描画する
;
DungeonPrintGate:

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_dungeon + DUNGEON_GATE_STATE)
    or      a
    jr      z, 90$
    ld      de, #(_sprite + GAME_SPRITE_GATE)
    dec     a
    jr      nz, 10$
    ld      hl, #dungeonSpriteNull
    ld      bc, #0x0010
    ldir
10$:
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #dungeonSpriteGate
    add     hl, bc
    ld      bc, (_dungeon + DUNGEON_GATE_POSITION_X)
    ld      a, b
    cp      #0x10
    ld      a, #0x02
    jr      nc, 11$
    add     a, #0x02
11$:
    push    af
    ld      a, (hl)
    add     a, b
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    pop     af
    dec     a
    jr      nz, 11$

    ; 描画の完了
90$:


    ; レジスタの復帰

    ; 終了
    ret

; 扉を設置する
;
_DungeonSetGate:

    ; レジスタの保存
    push    de

    ; 扉の設定
    ld      a, #DUNGEON_GATE_STATE_CLOSE
    ld      (_dungeon + DUNGEON_GATE_STATE), a
    ld      a, #DUNGEON_GATE_FRAME_CLOSE
    ld      (_dungeon + DUNGEON_GATE_FRAME), a
    ld      de, #((DUNGEON_GATE_HEIGHT << 8) | 0x00)
    ld      (_dungeon + DUNGEON_GATE_POSITION_X), de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 扉が開かれたかどうかを判定する
;
_DungeonIsGateOpen::

    ; レジスタの保存

    ; cf > 1 = 開かれた

    ; 扉の判定
    ld      a, (_dungeon + DUNGEON_GATE_STATE)
    cp      #DUNGEON_GATE_STATE_OPEN
    jr      nz, 18$
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; ダンジョンの初期値
;
dungeonDefault:

    .db     DUNGEON_STATE_NULL
    .db     DUNGEON_FLAG_NULL
    .db     DUNGEON_COUNT_NULL
    .db     DUNGEON_FRAME_NULL
    .db     DUNGEON_GATE_STATE_NULL
    .db     DUNGEON_GATE_FRAME_NULL
    .db     DUNGEON_GATE_POSITION_NULL
    .db     DUNGEON_GATE_POSITION_NULL

; スプライト
;
dungeonSpriteNull:

    .db     0x50 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0x50 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0x50 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0x50 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT

dungeonSpriteGate:

    .db     0x30 - 0x01, 0x50, 0x20, VDP_COLOR_LIGHT_RED
    .db     0x30 - 0x01, 0x60, 0x24, VDP_COLOR_LIGHT_RED
    .db     0x40 - 0x01, 0x50, 0x28, VDP_COLOR_LIGHT_RED
    .db     0x40 - 0x01, 0x60, 0x2c, VDP_COLOR_LIGHT_RED
    .db     0x30 - 0x01, 0x50, 0x30, VDP_COLOR_LIGHT_RED
    .db     0x30 - 0x01, 0x60, 0x34, VDP_COLOR_LIGHT_RED
    .db     0x40 - 0x01, 0x50, 0x38, VDP_COLOR_LIGHT_RED
    .db     0x40 - 0x01, 0x60, 0x3c, VDP_COLOR_LIGHT_RED


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ダンジョン
;
_dungeon::
    
    .ds     DUNGEON_LENGTH
