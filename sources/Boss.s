; Boss.s : ボス
;


; モジュール宣言
;
    .module Boss

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include    "Player.inc"
    .include	"Boss.inc"
    .include    "Magic.inc"
    .include    "Dungeon.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ボスを初期化する
;
_BossInitialize::
    
    ; レジスタの保存
    
    ; ボスの初期化
    ld      hl, #bossDefault
    ld      de, #_boss
    ld      bc, #BOSS_LENGTH
    ldir

    ; スプライトの初期化
    ld      de, #0x0000
    ld      (bossSpriteRotate), de
    
    ; 状態の設定
    ld      a, #BOSS_STATE_NULL
    ld      (_boss + BOSS_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ボスを更新する
;
_BossUpdate::
    
    ; レジスタの保存

    ; ダメージの更新
    ld      hl, #(_boss + BOSS_DAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
10$:

    ; 状態別の処理
    ld      hl, #20$
    push    hl
    ld      a, (_boss + BOSS_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #bossProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
20$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ボスを描画する
;
_BossRender::

    ; レジスタの保存

    ; ボスの存在
    ld      a, (_boss + BOSS_STATE)
    cp      #(BOSS_STATE_HIDE + 0x01)
    jp      c, 90$

    ; 点滅
    ld      a, (_boss + BOSS_BLINK)
    and     #0x01
    jr      nz, 190$

    ; 位置の取得
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, (_boss + BOSS_POSITION_X)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_X
    ld      c, a
    ld      a, (_boss + BOSS_POSITION_Y)
    sub     b
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_Y
    ld      b, a

    ; スプライトの描画
    ld      hl, (_boss + BOSS_SPRITE_L)
    ld      de, (bossSpriteRotate)
    ld      a, #BOSS_SPRITE_LENGTH
    call    110$
    ld      a, (_boss + BOSS_DAMAGE)
    or      a
    jr      nz, 100$
    ld      a, (_boss + BOSS_STATE)
    cp      #BOSS_STATE_DEAD
    jr      z, 100$
    ld      a, (_player + PLAYER_CANDLE)
    or      a
    jr      z, 109$
100$:
    call    110$
    call    110$
    call    110$
    call    110$
109$:
    jr      190$
110$:
    push    af
    push    de
    push    hl
    ld      hl, #(_sprite + GAME_SPRITE_BOSS_BODY)
    add     hl, de
    ex      de, hl
    pop     hl
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
    ld      a, (_boss + BOSS_DAMAGE)
    or      a
    ld      a, (hl)
    jr      z, 111$
    ld      a, #BOSS_COLOR_DAMAGE
111$:
    ld      (de), a
    inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    cp      #(0x04 * BOSS_SPRITE_LENGTH)
    jr      c, 112$
    xor     a
112$:
    ld      e, a
    pop     af
    ret

    ; スプライトの更新
190$:
    ld      a, (bossSpriteRotate)
    add     a, #0x04
    cp      #(0x04 * BOSS_SPRITE_LENGTH)
    jr      c, 191$
    xor     a
191$:
    ld      (bossSpriteRotate), a

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
BossNull:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; ボスは潜んでいる
;
BossHide:

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; ボスが行動する
;
BossPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_boss + BOSS_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 位置の設定
    call    BossSetFarPosition

    ; 点滅の設定
    ld      a, #BOSS_BLINK_MOVE
    ld      (_boss + BOSS_BLINK), a

    ; ヒットの設定
    ld      hl, #(_boss + BOSS_FLAG)
    set     #BOSS_FLAG_HIT_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_boss + BOSS_STATE)
    inc     (hl)
09$:

    ; 0x01 : 移動の完了
    ld      a, (_boss + BOSS_STATE)
    and     #0x0f
    dec     a
    jr      nz, 19$

    ; 点滅の更新
    ld      hl, #(_boss + BOSS_BLINK)
    dec     (hl)
    jr      nz, 90$

    ; 待機の設定
    call    _SystemGetRandom
    and     #BOSS_COUNT_STAY_MASK
    add     a, #BOSS_COUNT_STAY_BASE
    ld      (_boss + BOSS_COUNT), a
    ld      a, #BOSS_FRAME_STAY_LENGTH
    ld      (_boss + BOSS_FRAME), a

    ; 状態の更新
    ld      hl, #(_boss + BOSS_STATE)
    inc     (hl)
    jr      90$
19$:

    ; 0x02 : 待機
    dec     a
    jr      nz, 29$

    ; アニメーションの更新
    ld      hl, #(_boss + BOSS_ANIMATION)
    inc     (hl)

    ; フレームの更新
    ld      hl, #(_boss + BOSS_FRAME)
    dec     (hl)
    jr      nz, 90$
    ld      a, #BOSS_FRAME_STAY_LENGTH
    ld      (hl), a

    ; カウントの更新
    ld      hl, #(_boss + BOSS_COUNT)
    dec     (hl)
    jr      nz, 90$

    ; 状態の更新
    ld      hl, #(_boss + BOSS_STATE)
    inc     (hl)
    jr      90$
29$:

    ; 0x03 : 移動の開始
;   dec     a
;   jr      nz, 39$

    ; 点滅の更新
    ld      hl, #(_boss + BOSS_BLINK)
    inc     (hl)
    ld      a, (hl)
    cp      #BOSS_BLINK_MOVE
    jr      c, 90$

    ; 状態の更新
    ld      hl, #(_boss + BOSS_STATE)
    ld      a, (hl)
    and     #0xf0
    ld      (hl), a
    jr      90$
39$:

    ; 行動の完了
90$:

    ; 呪文を唱える
    call    BossCast

    ; スプライトの設定
    ld      a, (_boss + BOSS_ANIMATION)
    and     #0x0e
    add     a, a
    ld      e, a
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #bossSprite
    add     hl, de
    ld      (_boss + BOSS_SPRITE_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; ボスが死亡する
;
BossDead:

    ; レジスタの保存

    ; 初期化
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    xor     a
    ld      (_boss + BOSS_BLINK), a

    ; ヒットの設定
    ld      hl, #(_boss + BOSS_FLAG)
    res     #BOSS_FLAG_HIT_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_boss + BOSS_STATE)
    inc     (hl)
09$:

    ; ダメージの設定
    ld      a, #BOSS_DAMAGE_LENGTH
    ld      (_boss + BOSS_DAMAGE), a

    ; 点滅の更新
    ld      hl, #(_boss + BOSS_BLINK)
    inc     (hl)
    ld      a, (hl)
    cp      #BOSS_BLINK_DEAD
    jr      c, 19$

    ; 状態の更新
    xor     a
    ld      (_boss + BOSS_STATE), a
;   jr      90$
19$:

    ; 行動の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 呪文を唱える
;
BossCast:

    ; レジスタの保存

    ; 呪文の更新
    ld      hl, #(_boss + BOSS_CAST)
    dec     (hl)
    jp      nz, 190$

    ; ランダムなオフセットの取得
    call    _SystemGetRandom
    and     #0x07
    ld      e, a
    ld      d, #0x00
    ld      hl, #bossCastOffset
    add     hl, de
    ld      c, (hl)
    call    _SystemGetRandom
    ld      b, a

    ; プレイヤの位置による位置と方向の取得
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, d
    cp      #(CAMERA_VIEW_SIZE_Y / 3)
    jr      c, 100$
    cp      #(CAMERA_VIEW_SIZE_Y - CAMERA_VIEW_SIZE_Y / 3)
    jr      nc, 101$
    jr      102$
100$:
    ld      a, e
    cp      #(CAMERA_VIEW_SIZE_X / 3)
    jr      c, 110$
    cp      #(CAMERA_VIEW_SIZE_X - CAMERA_VIEW_SIZE_X / 3)
    jr      nc, 120$
    rl      b
    jr      c, 110$
    jr      120$
101$:
    ld      a, e
    cp      #(CAMERA_VIEW_SIZE_X / 3)
    jr      c, 130$
    cp      #(CAMERA_VIEW_SIZE_X - CAMERA_VIEW_SIZE_X / 3)
    jr      nc, 140$
    rl      b
    jr      c, 130$
    jr      140$
102$:
    ld      a, e
    cp      #(CAMERA_VIEW_SIZE_X / 3)
    jr      nc, 103$
    rl      b
    jr      c, 110$
    jr      130$
103$:
    cp      #(CAMERA_VIEW_SIZE_X - CAMERA_VIEW_SIZE_X / 3)
    jr      c, 104$
    rl      b
    jr      c, 120$
    jr      140$
104$:
    ld      a, b
    and     #0x03
    dec     a
    jr      z, 110$
    dec     a
    jr      z, 120$
    dec     a
    jr      z, 130$
    jr      140$

    ; 左上に向かって撃つ
110$:
    rl      b
    jr      c, 111$
    ld      a, #CAMERA_VIEW_SIZE_X
    sub     c
    ld      e, a
    ld      d, #CAMERA_VIEW_SIZE_Y
    jr      119$
111$:
    ld      e, #CAMERA_VIEW_SIZE_X
    ld      a, #CAMERA_VIEW_SIZE_Y
    sub     c
    ld      d, a
119$:
    ld      a, #MAGIC_DIRECTION_UP_LEFT
    jr      180$

    ; 右上に向かって撃つ
120$:
    rl      b
    jr      c, 121$
    ld      e, c
    ld      d, #CAMERA_VIEW_SIZE_Y
    jr      129$
121$:
    ld      e, #0x00
    ld      a, #CAMERA_VIEW_SIZE_Y
    sub     c
    ld      d, a
129$:
    ld      a, #MAGIC_DIRECTION_UP_RIGHT
    jr      180$

    ; 左下に向かって撃つ
130$:
    rl      b
    jr      c, 131$
    ld      a, #CAMERA_VIEW_SIZE_X
    sub     c
    ld      e, a
    ld      d, #0x00
    jr      139$
131$:
    ld      e, #CAMERA_VIEW_SIZE_X
    ld      d, c
139$:
    ld      a, #MAGIC_DIRECTION_DOWN_LEFT
    jr      180$

    ; 右下に向かって撃つ
140$:
    rl      b
    jr      c, 141$
    ld      e, c
    ld      d, #0x00
    jr      149$
141$:
    ld      e, #0x00
    ld      d, c
149$:
    ld      a, #MAGIC_DIRECTION_DOWN_RIGHT
;   jr      180$

    ; 魔法を撃つ
180$:
    call    _MagicCast
    call    _SystemGetRandom
    and     #BOSS_CAST_MASK
    add     a, #BOSS_CAST_BASE
    ld      (_boss + BOSS_CAST), a
;   jr      190$

    ; 呪文の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; ボスを登録する
;
_BossEntry::

    ; レジスタの保存

    ; ボスの登録
    ld      a, #BOSS_STATE_HIDE
    ld      (_boss + BOSS_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; ボスを削除する
;
_BossKill::

    ; レジスタの保存

    ; ボスの削除
    xor     a
    ld      (_boss + BOSS_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

;  ボスを行動させる
;
_BossSetPlay::

    ; レジスタの保存
    push    hl

    ; 行動の設定
    ld      a, #BOSS_STATE_PLAY
    ld      (_boss + BOSS_STATE), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

;  ボスを死亡させる
;
BossSetDead:

    ; レジスタの保存
    push    hl

    ; 死亡の設定
    xor     a
    ld      (_boss + BOSS_LIFE_L), a
    ld      (_boss + BOSS_LIFE_H), a
    ld      (_boss + BOSS_DAMAGE), a
    ld      a, #BOSS_STATE_DEAD
    ld      (_boss + BOSS_STATE), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret
    
; ボスの体力があるかどうかを判定する
;
_BossIsLife::

    ; レジスタの保存
    push    hl

    ; cf > 1 = ライフがある

    ; ボスの判定
    ld      hl, (_boss + BOSS_LIFE_L)
    ld      a, h
    or      l
    jr      z, 19$
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; ボスが死亡したかどうかを判定する
;
_BossIsDead::

    ; レジスタの保存

    ; cf > 1 = 死亡した

    ; ボスの判定
    ld      a, (_boss + BOSS_STATE)
    or      a
    jr      nz, 19$
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ボスにダメージを与える
;
_BossDamage::

    ; レジスタの保存
    push    hl
    push    de

    ; a  < ダメージ量

    ; ライフの減少
    ld      e, a
    ld      d, #0x00
    ld      hl, (_boss + BOSS_LIFE_L)
    or      a
    sbc     hl, de
    jr      z, 10$
    jr      nc, 11$
10$:
    call    BossSetDead
    jr      19$
11$:
    ld      (_boss + BOSS_LIFE_L), hl
    ld      a, #BOSS_DAMAGE_LENGTH
    ld      (_boss + BOSS_DAMAGE), a
;   jr      19$
19$:

    ; SE の再生
    ld      a, #SOUND_SE_HIT
    call    _SoundPlaySe

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤから離れたランダムな位置を設定する
;
BossSetFarPosition:

    ; レジスタの保存
    push    de

    ; ランダムな位置の取得
    call    _SystemGetRandom
    and     #0x0f
    cp      #0x08
    jr      c, 100$
    add     a, #0x02
100$:
    add     a, #0x02
    ld      e, a
    call    _SystemGetRandom
    and     #0x0f
    srl     a
    ld      d, a
    jr      c, 120$
    
    ; 縦優先の位置の取得
110$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      #(CAMERA_VIEW_SIZE_Y / 2)
    ld      a, d
    jr      nc, 111$
    add     a, #0x0a
111$:
    add     a, #0x02
    ld      d, a
    jr      190$

    ; 横優先の位置の取得
120$:
    ld      a, (_player + PLAYER_POSITION_X)
    cp      #(CAMERA_VIEW_SIZE_X / 2)
    ld      a, d
    ld      d, e
    jr      nc, 121$
    add     a, #0x0a
121$:
    add     a, #0x02
    ld      e, a
    jr      190$

    ; 位置の設定
190$:
    ld      (_boss + BOSS_POSITION_X), de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
bossProc:

    .dw     BossNull
    .dw     BossHide
    .dw     BossPlay
    .dw     BossDead

; ボスの初期値
;
bossDefault:

    .db     BOSS_STATE_NULL
    .db     BOSS_FLAG_NULL
    .db     BOSS_POSITION_NULL
    .db     BOSS_POSITION_NULL
    .db     BOSS_ANIMATION_NULL
    .db     BOSS_BLINK_NULL
    .dw     BOSS_SPRITE_NULL
    .dw     0x01800 ; BOSS_LIFE_NULL
    .db     0x09 ; BOSS_POWER_NULL
    .db     BOSS_DAMAGE_NULL
    .db     BOSS_COUNT_NULL
    .db     BOSS_FRAME_NULL
    .db     0x10 ; BOSS_CAST_NULL

; スプライト
;
bossSprite:

    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0x88, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0x8c, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0xa8, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xac, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0x90, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0x94, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0xb0, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xb4, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01, -0x10, 0x98, VDP_COLOR_LIGHT_BLUE
    .db     -0x10 - 0x01,  0x00, 0x9c, VDP_COLOR_LIGHT_BLUE
    .db      0x00 - 0x01, -0x10, 0xb8, VDP_COLOR_LIGHT_BLUE
    .db      0x00 - 0x01,  0x00, 0xbc, VDP_COLOR_LIGHT_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0xb0, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xb4, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0x90, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0x94, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x08, 0x84, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0xa0, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0xa4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0xa8, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xac, VDP_COLOR_DARK_BLUE

; 呪文
;
bossCastOffset:

    .db     0x00, 0x01, 0x03, 0x05, 0x07, 0x09, 0x0b, 0x0d


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ボス
;
_boss::
    
    .ds     BOSS_LENGTH

; スプライト
;
bossSpriteRotate:

    .ds     0x02

