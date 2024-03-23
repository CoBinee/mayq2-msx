; Magic.s : 魔法
;


; モジュール宣言
;
    .module Magic

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include	"Magic.inc"
    .include    "Field.inc"
    .include    "Dungeon.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 魔法を初期化する
;
_MagicInitialize::
    
    ; レジスタの保存
    
    ; 魔法の初期化
    call    _MagicKillAll

    ; スプライトの初期化
    ld      de, #0x0000
    ld      (magicSpriteRotate), de
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 魔法を更新する
;
_MagicUpdate::
    
    ; レジスタの保存

    ; 魔法の走査
    ld      ix, #_magic
    ld      b, #MAGIC_ENTRY
10$:
    push    bc

    ; 魔法の存在
    ld      a, MAGIC_STATE(ix)
    or      a
    jr      z, 19$

    ; 移動
    ld      a, MAGIC_POSITION_X(ix)
    add     a, MAGIC_SPEED_X(ix)
    ld      MAGIC_POSITION_X(ix), a
    ld      e, a
    ld      a, MAGIC_POSITION_Y(ix)
    add     a, MAGIC_SPEED_Y(ix)
    ld      MAGIC_POSITION_Y(ix), a
    ld      d, a
    call    MagicIsView
    jr      nc, 18$

    ; アニメーションの更新
    inc     MAGIC_ANIMATION(ix)

    ; スプライトの設定
    ld      a, MAGIC_ANIMATION(ix)
    and     #0x03
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #magicSprite
    add     hl, de
    ld      MAGIC_SPRITE_L(ix), l
    ld      MAGIC_SPRITE_H(ix), h
    jr      19$
    
    ; 魔法の削除
18$:
    ld      MAGIC_STATE(ix), #MAGIC_STATE_NULL
;   jr      19$

    ; 次の魔法へ
19$:
    ld      bc, #MAGIC_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 魔法を描画する
;
_MagicRender::

    ; レジスタの保存

    ; 魔法の走査
    ld      ix, #_magic
    ld      de, (magicSpriteRotate)
    ld      b, #MAGIC_ENTRY
10$:
    push    bc

    ; 魔法の存在
    ld      a, MAGIC_STATE(ix)
    or      a
    jr      z, 19$

    ; 位置の取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, MAGIC_POSITION_X(ix)
    sub     c
    and     #(FIELD_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_X
    ld      c, a
    ld      a, MAGIC_POSITION_Y(ix)
    sub     b
    and     #(FIELD_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_Y
    ld      b, a

    ; スプライトの描画
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_MAGIC)
    add     hl, de
    ex      de, hl
    ld      l, MAGIC_SPRITE_L(ix)
    ld      h, MAGIC_SPRITE_H(ix)
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
    pop     de

    ; スプライト位置の更新
    ld      a, e
    add     a, #0x04
    cp      #(0x04 * MAGIC_ENTRY)
    jr      c, 18$
    xor     a
18$:
    ld      e, a

    ; 次の魔法へ
19$:
    ld      bc, #MAGIC_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ;  スプライトの更新
    ld      a, (magicSpriteRotate)
    add     a, #0x04
    cp      #(0x04 * MAGIC_ENTRY)
    jr      c, 20$
    xor     a
20$:
    ld      (magicSpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 魔法を撃つ
;
_MagicCast::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; de < Y/X 位置
    ; a  < 向き

    ; 速度の取得
    push    af
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #magicSpeed
    add     hl, bc
    ld      a, (hl)
    inc     hl
    ld      h, (hl)
    ld      l, a
    pop     af
    ld      c, a

    ; 画面内の判定
    ld      a, e
    add     a, l
    ld      e, a
    ld      a, d
    add     a, h
    ld      d, a
    call    MagicIsView
    jr      nc, 90$

    ; 魔法の走査
    ld      ix, #_magic
    ld      b, #MAGIC_ENTRY
10$:
    ld      a, MAGIC_STATE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #MAGIC_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      19$

    ; 魔法の登録
11$:
    ld      MAGIC_STATE(ix), #MAGIC_STATE_CAST
    ld      MAGIC_POSITION_X(ix), e
    ld      MAGIC_POSITION_Y(ix), d
    ld      MAGIC_SPEED_X(ix), l
    ld      MAGIC_SPEED_Y(ix), h
    ld      MAGIC_DIRECTION(ix), c
;   xor     a
    ld      MAGIC_ANIMATION(ix), a
;   jr      19$
19$:

    ; 魔法の完了
90$:
    
    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 魔法を削除する
;
_MagicKill::

    ; レジスタの保存

    ; ix < 魔法
    
    ; 魔法の削除
    ld      MAGIC_STATE(ix), #MAGIC_STATE_NULL

    ; レジスタの復帰

    ; 終了
    ret

_MagicKillAll::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 魔法の削除
    ld      hl, #(_magic + 0x0000)
    ld      de, #(_magic + 0x0001)
    ld      bc, #(MAGIC_ENTRY * MAGIC_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 魔法が画面内にあるかどうかを判定する
;
MagicIsView:

    ; レジスタの保存
    push    bc

    ; de < Y/X 位置
    ; cf > 1 = 画面内にある

    ; 位置の判定
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, e
    sub     c
    and     #(FIELD_SIZE_X - 0x01)
    cp      #(CAMERA_VIEW_SIZE_X + 0x01)
    jr      nc, 18$
    ld      a, d
    sub     b
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #(CAMERA_VIEW_SIZE_Y + 0x01)
    jr      nc, 18$
;   scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; 魔法の初期値
;
magicDefault:

    .db     MAGIC_STATE_NULL
    .db     MAGIC_POSITION_NULL
    .db     MAGIC_POSITION_NULL
    .db     MAGIC_SPEED_NULL
    .db     MAGIC_SPEED_NULL
    .db     MAGIC_DIRECTION_DOWN
    .db     MAGIC_ANIMATION_NULL
    .dw     MAGIC_SPRITE_NULL

; 速度
;
magicSpeed:

    .db       0x00, -0x01
    .db       0x00,  0x01
    .db      -0x01,  0x00
    .db       0x01,  0x00
    .db      -0x01, -0x01
    .db       0x01, -0x01
    .db      -0x01,  0x01
    .db       0x01,  0x01

; スプライト
;
magicSprite:

    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_LIGHT_BLUE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 魔法
;
_magic::
    
    .ds     MAGIC_ENTRY * MAGIC_LENGTH

; スプライト
;
magicSpriteRotate:

    .ds     0x02

