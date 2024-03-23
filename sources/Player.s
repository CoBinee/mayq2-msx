; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

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
    .include	"Player.inc"
    .include    "Field.inc"
    .include    "Dungeon.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; レベルの設定
    ld      a, (_app + APP_GAME_LEVEL)
    cp      #(PLAYER_LEVEL_MAXIMUM + 0x01)
    jr      c, 10$
    ld      a, #PLAYER_LEVEL_DEFAULT
10$:
    sub     #PLAYER_LEVEL_DEFAULT
    jr      c, 19$
    jr      z, 19$
    ld      b, a
11$:
    call    PlayerLevelUp
    djnz    11$
19$:

    ; 経験値の設定
    ld      a, (_app + APP_GAME_EXPERIENCE)
    cp      #(PLAYER_EXPERIENCE_MAXIMUM + 0x01)
    jr      c, 20$
    xor     a
20$:
    ld      (_player + PLAYER_EXPERIENCE_POINT), a

    ; レジストの設定
    ld      a, (_app + APP_GAME_RESIST)
    cp      #(PLAYER_RESIST_MAXIMUM + 0x01)
    jr      c, 30$
    xor     a
30$:
    ld      (_player + PLAYER_RESIST), a
    
    ; クリスタルの設定
    ld      hl, #(_player + PLAYER_CRYSTAL_RED)
    ld      a, (_app + APP_GAME_CRYSTAL)
    add     a, a
    add     a, a
    add     a, a
    ld      c, #ITEM_CRYSTAL_RED
40$:
    add     a, a
    push    af
    jr      nc, 41$
    ld      a, c
    call    PlayerAddItem
    ld      (hl), #PLAYER_ITEM_ANIMATION_LENGTH
41$:
    inc     hl
    inc     c
    pop     af
    jr      nz, 40$

    ; アイテムの設定
    ld      hl, #(_player + PLAYER_KEY)
    ld      a, (_app + APP_GAME_ITEM)
    add     a, a
    add     a, a
    add     a, a
    ld      c, #ITEM_KEY
50$:
    add     a, a
    push    af
    jr      nc, 51$
    ld      a, c
    call    PlayerAddItem
    ld      (hl), #PLAYER_ITEM_ANIMATION_LENGTH
51$:
    inc     hl
    inc     c
    pop     af
    jr      nz, 50$

    ; 状態の設定
    ld      a, #PLAYER_STATE_STAY
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; ダメージの更新
    call    PlayerUpdateDamage

    ; 経験値の更新
    call    PlayerUpdateExperience

    ; アイテムの更新
    call    PlayerUpdateItem

    ; 状態別の処理
    ld      hl, #20$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
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

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; 点滅
    ld      a, (_player + PLAYER_BLINK)
    and     #PLAYER_BLINK_CYCLE
    jp      nz, 90$

    ; スプライトの作成
10$:
    ld      a, (_player + PLAYER_DIRECTION)
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x10
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_patternTable + PLAYER_PATTERN_TABLE)
    add     hl, de
    ld      de, (_player + PLAYER_POSITION_X)
    call    _GameGetSpriteMask
    or      a
    jp      z, 90$
    ld      de, #(_gameSpriteGenerator + GAME_SPRITE_GENERATOR_PLAYER + 0x0000)
    call    _GameMakeSpriteGenerator
    inc     h
    ld      de, #(_gameSpriteGenerator + GAME_SPRITE_GENERATOR_PLAYER + 0x0020)
    call    _GameMakeSpriteGenerator

    ; 位置の取得
20$:
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, (_player + PLAYER_POSITION_X)
    sub     c
    and     #(FIELD_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_X
    ld      c, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     b
    and     #(FIELD_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_Y
    ld      b, a

    ; スプライトの描画／ボディ
    ld      hl, #playerSpriteBody
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_BODY)
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
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    ld      a, (hl)
    jr      z, 30$
    ld      a, #PLAYER_COLOR_DAMAGE
30$:
    ld      (de), a
    inc     hl
;   inc     de

    ; スプライトの描画／エッジ
40$:
;   ld      hl, #playerSpriteEdge
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_EDGE)
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

    ; スプライトの描画／アイテム
    ld      hl, #(_player + PLAYER_CRYSTAL_RED)
    ld      e, #ITEM_CRYSTAL_RED
50$:
    ld      a, (hl)
    or      a
    jr      z, 51$
    cp      #0x08 ; PLAYER_ITEM_ANIMATION_LENGTH
    jr      c, 52$
51$:
    inc     hl
    inc     e
    ld      a, e
    cp      #ITEM_LENGTH
    jr      c, 50$
    jr      59$
52$:
;   ld      a, (hl)
;   srl     a
;   srl     a
    add     a, #0x0c
    ld      d, a
    ld      a, b
    sub     d
    ld      b, a
    ld      a, e
    dec     a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSpriteItem
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_ITEM)
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
;   jr      59$
59$:

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが待機する
;
PlayerStay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 移動の停止
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_MOVE_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; アニメーションの更新
    call    PlayerUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤをフィールド上で操作する
;
PlayerField:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 移動のクリア
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_MOVE_BIT, (hl)

    ; ↑へ移動
200$:
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 210$
    call    _FieldCorrectUp
    jr      nc, 208$
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_POSITION_X), de
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    cp      e
    jr      z, 201$
    call    PlayerMoveCameraHorizon
    jr      209$
201$:
    call    PlayerMoveCameraVertical
    jr      209$
208$:
    call    _PlayerPickupItem
;   jr      209$
209$:
    ld      a, #PLAYER_DIRECTION_UP
    ld      (_player + PLAYER_DIRECTION), a
    jp      290$

    ; ↓へ移動
210$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 220$
    call    _FieldCorrectDown
    jr      nc, 218$
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_POSITION_X), de
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    cp      e
    jr      z, 211$
    call    PlayerMoveCameraHorizon
    jr      219$
211$:
    call    PlayerMoveCameraVertical
    jr      219$
218$:
    call    _PlayerPickupItem
;   jr      219$
219$:
    ld      a, #PLAYER_DIRECTION_DOWN
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$

    ; ←へ移動
220$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 230$
    call    _FieldCorrectLeft
    jr      nc, 229$
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_POSITION_X), de
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    cp      e
    jr      z, 221$
    call    PlayerMoveCameraHorizon
    jr      229$
221$:
    call    PlayerMoveCameraVertical
;   jr      229$
229$:
    ld      a, #PLAYER_DIRECTION_LEFT
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$
    
    ; →へ移動
230$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 290$
    call    _FieldCorrectRight
    jr      nc, 239$
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_POSITION_X), de
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    cp      e
    jr      z, 231$
    call    PlayerMoveCameraHorizon
    jr      239$
231$:
    call    PlayerMoveCameraVertical
;   jr      239$
239$:
    ld      a, #PLAYER_DIRECTION_RIGHT
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$

    ; 移動の完了
290$:

    ; 休息の更新
    call    PlayerUpdateRest

    ; アニメーションの更新
    call    PlayerUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤをダンジョンで操作する
;
PlayerDungeon:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 移動のクリア
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_MOVE_BIT, (hl)

    ; 位置の補正
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, e
    cp      #PLAYER_SIZE_R
    jr      c, 10$
    cp      #0x80
    jr      nc, 10$
    cp      #(CAMERA_VIEW_SIZE_X - PLAYER_SIZE_R + 0x01)
    jr      nc, 11$
    jr      12$
10$:
    ld      e, #PLAYER_SIZE_R
    jr      12$
11$:
    ld      e, #(CAMERA_VIEW_SIZE_X - PLAYER_SIZE_R)
;   jr      12$
12$:
    ld      a, d
    cp      #PLAYER_SIZE_R
    jr      c, 13$
    cp      #0x80
    jr      nc, 13$
    cp      #(CAMERA_VIEW_SIZE_Y - PLAYER_SIZE_R + 0x01)
    jr      nc, 14$
    jr      15$
13$:
    ld      d, #PLAYER_SIZE_R
    jr      15$
14$:
    ld      d, #(CAMERA_VIEW_SIZE_Y - PLAYER_SIZE_R)
;   jr      15$
15$:
    ld      (_player + PLAYER_POSITION_X), de

    ; ↑へ移動
200$:
;   ld      de, (_player + PLAYER_POSITION_X)
    ld      hl, #(_player + PLAYER_FLAG)
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 210$
    ld      a, d
    cp      #(PLAYER_SIZE_R + 0x01)
    jr      c, 209$
    dec     a
    ld      (_player + PLAYER_POSITION_Y), a
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
;   jr      209$
209$:
    ld      a, #PLAYER_DIRECTION_UP
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$

    ; ↓へ移動
210$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 220$
    ld      a, d
    cp      #(CAMERA_VIEW_SIZE_Y - PLAYER_SIZE_R)
    jr      nc, 219$
    inc     a
    ld      (_player + PLAYER_POSITION_Y), a
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
;   jr      219$
219$:
    ld      a, #PLAYER_DIRECTION_DOWN
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$

    ; ←へ移動
220$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 230$
    ld      a, e
    cp      #(PLAYER_SIZE_R + 0x01)
    jr      c, 229$
    dec     a
    ld      (_player + PLAYER_POSITION_X), a
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
;   jr      229$
229$:
    ld      a, #PLAYER_DIRECTION_LEFT
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$
    
    ; →へ移動
230$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 290$
    ld      a, e
    cp      #(CAMERA_VIEW_SIZE_X - PLAYER_SIZE_R)
    jr      nc, 239$
    inc     a
    ld      (_player + PLAYER_POSITION_X), a
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
;   jr      239$
239$:
    ld      a, #PLAYER_DIRECTION_RIGHT
    ld      (_player + PLAYER_DIRECTION), a
    jr      290$

    ; 移動の完了
290$:

    ; アニメーションの更新
    call    PlayerUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが死亡する
;
PlayerDead:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 点滅の更新
    ld      hl, #(_player + PLAYER_BLINK)
    inc     (hl)
    ld      a, (hl)
    cp      #PLAYER_BLINK_DEAD
    jr      c, 19$

    ; 死亡の完了
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_DEAD_BIT, (hl)
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; クリアしてプレイヤが定位置に移動する
;
PlayerClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #PLAYER_FRAME_WALK
    ld      (_player + PLAYER_FRAME), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_player + PLAYER_FRAME)
    dec     (hl)
    jr      nz, 90$
    ld      a, #PLAYER_FRAME_WALK
    ld      (hl), a

    ; 移動
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, d
    cp      #DUNGEON_POSITION_PLAYER_Y
    jr      z, 11$
    jr      nc, 10$
    inc     d
    ld      a, #PLAYER_DIRECTION_DOWN
    jr      19$
10$:
    dec     d
    ld      a, #PLAYER_DIRECTION_UP
    jr      19$
11$:
    ld      a, e
    cp      #DUNGEON_POSITION_PLAYER_X
    jr      z, 13$
    jr      nc, 12$
    inc     e
    ld      a, #PLAYER_DIRECTION_RIGHT
    jr      19$
12$:
    dec     e
    ld      a, #PLAYER_DIRECTION_LEFT
    jr      19$
13$:

    ; 状態の更新
    ld      a, #PLAYER_STATE_STAY
    ld      (_player + PLAYER_STATE), a

    ; 上を向いて待機
    ld      a, #PLAYER_DIRECTION_UP
;   jr      19$

    ; 移動の完了
19$:
    ld      (_player + PLAYER_POSITION_X), de
    ld      (_player + PLAYER_DIRECTION), a

    ; クリアの完了
90$:

    ; アニメーションの更新
    call    PlayerUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが扉から出る
;
PlayerExit:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #PLAYER_FRAME_WALK
    ld      (_player + PLAYER_FRAME), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_player + PLAYER_FRAME)
    dec     (hl)
    jr      nz, 90$
    ld      a, #PLAYER_FRAME_WALK
    ld      (hl), a

    ; 移動
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (hl)
    cp      #DUNGEON_POSITION_GATE_Y
    jr      z, 10$
    dec     (hl)
    jr      19$
10$:

    ; 下を向いて待機
    ld      a, #PLAYER_DIRECTION_DOWN
    ld      (_player + PLAYER_DIRECTION), a

    ; 状態の更新
    ld      a, #PLAYER_STATE_STAY
    ld      (_player + PLAYER_STATE), a
;   jr      19$

    ; 移動の完了
19$:

    ; クリアの完了
90$:

    ; アニメーションの更新
    call    PlayerUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを待機させる
;
_PlayerSetStay::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_STAY
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤをフィールド上で操作させる
;
_PlayerSetField::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_FIELD
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤをダンジョンで操作させる
;
_PlayerSetDungeon::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_DUNGEON
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤをクリア時の定位置に移動させる
;
_PlayerSetClear::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_CLEAR
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤに扉をくぐらせる
;
_PlayerSetExit::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_EXIT
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが待機しているかどうかを判定する
;
_PlayerIsStay::

    ; レジスタの保存

    ; cf > 1 = 待機

    ; 待機の判定
    ld      a, (_player + PLAYER_STATE)
    cp      #PLAYER_STATE_STAY
    jr      nz, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが死亡したかどうかを判定する
;
_PlayerIsDead::

    ; レジスタの保存

    ; cf > 1 = 死亡

    ; 死亡の判定
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_DEAD
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを中心としたカメラを設定する
;
_PlayerSetCameraCenter::

    ; レジスタの保存

    ; カメラの設定
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #PLAYER_CAMERA_OFFSET_X
    and     #(FIELD_SIZE_X - 0x01)
    ld      (_camera + CAMERA_POSITION_X), a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #PLAYER_CAMERA_OFFSET_Y
    and     #(FIELD_SIZE_Y - 0x01)
    ld      (_camera + CAMERA_POSITION_Y), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤに追従してカメラを移動する
;
PlayerMoveCameraHorizon:

    ; レジスタの保存
    push    hl
    push    de

    ; カメラの移動
    ld      a, (_camera + CAMERA_FLAG)
    bit     #CAMERA_FLAG_SCROLL_BIT, a
    jr      z, 19$
    ld      hl, #(_camera + CAMERA_POSITION_X)
    ld      a, (_player + PLAYER_POSITION_X)
    sub     (hl)
    and     #(FIELD_SIZE_X - 0x01)
    cp      #PLAYER_CAMERA_DISTANCE_LEFT
    jr      c, 10$
    cp      #(FIELD_SIZE_X / 2)
    jr      nc, 10$
    cp      #PLAYER_CAMERA_DISTANCE_RIGHT
    jr      nc, 11$
    jr      19$
10$:
    ld      e, a
    ld      a, #PLAYER_CAMERA_DISTANCE_LEFT
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    ld      a, (hl)
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    ld      (hl), a
    dec     e
    jr      nz, 18$
    call    _FieldScrollLeft
    jr      19$
11$:
    sub     #(PLAYER_CAMERA_DISTANCE_RIGHT - 0x01)
    ld      e, a
    add     a, (hl)
    and     #(FIELD_SIZE_X - 0x01)
    ld      (hl), a
    dec     e
    jr      nz, 18$
    call    _FieldScrollRight
    jr      19$
18$:
    call    _FieldView
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

PlayerMoveCameraVertical:

    ; レジスタの保存
    push    hl
    push    de

    ; カメラの移動
    ld      a, (_camera + CAMERA_FLAG)
    bit     #CAMERA_FLAG_SCROLL_BIT, a
    jr      z, 19$
    ld      hl, #(_camera + CAMERA_POSITION_Y)
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     (hl)
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #PLAYER_CAMERA_DISTANCE_UP
    jr      c, 10$
    cp      #(FIELD_SIZE_Y / 2)
    jr      nc, 10$
    cp      #PLAYER_CAMERA_DISTANCE_DOWN
    jr      nc, 11$
    jr      19$
10$:
    ld      e, a
    ld      a, #PLAYER_CAMERA_DISTANCE_UP
    sub     e
    and     #(FIELD_SIZE_Y - 0x01)
    ld      e, a
    ld      a, (hl)
    sub     e
    and     #(FIELD_SIZE_Y - 0x01)
    ld      (hl), a
    dec     e
    jr      nz, 18$
    call    _FieldScrollUp
    jr      19$
11$:
    sub     #(PLAYER_CAMERA_DISTANCE_DOWN - 0x01)
    ld      e, a
    add     a, (hl)
    and     #(FIELD_SIZE_Y - 0x01)
    ld      (hl), a
    dec     e
    jr      nz, 18$
    call    _FieldScrollDown
    jr      19$
18$:
    call    _FieldView
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤが入り口に立っているかどうかを判定する
;
_PlayerIsEntrance::

    ; レジスタの保存
    push    bc
    push    de

    ; cf > 1 = 入り口

    ; 入り口の判定
    ld      de, #(_player + PLAYER_CRYSTAL_RED)
    ld      b, #(ITEM_CRYSTAL_WHITE - ITEM_CRYSTAL_RED + 0x01)
10$:
    ld      a, (de)
    or      a
    jr      z, 18$
    inc     de
    djnz    10$
    ld      de, (_player + PLAYER_POSITION_X)
    call    _FieldIsEntrance
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; プレイヤが穴の上に立っているかどうかを判定する
;
_PlayerIsHole::

    ; レジスタの保存
    push    de

    ; cf > 1 = 入り口

    ; 穴の判定
    ld      de, (_player + PLAYER_POSITION_X)
    call    _FieldIsHole

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ダメージを更新する
;
PlayerUpdateDamage:

    ; レジスタの保存
    push    hl

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
10$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤにダメージを加える
;
PlayerAddDamage:

    ; レジスタの保存
    push    hl

    ; a  < ダメージ量
    ; c  < 吹き飛ばされる向き
    ; b  < 吹き飛ばされる距離

    ; ダメージの加算
    ld      hl, #(_player + PLAYER_DAMAGE_POINT)
    add     a, (hl)
    jr      nc, 10$
    ld      a, #0xff
10$:
    ld      (hl), a

    ; ダメージの設定
    ld      a, c
    ld      (_player + PLAYER_DAMAGE_DIRECTION), a
    ld      a, b
    ld      (_player + PLAYER_DAMAGE_DISTANCE), a

    ; SE の再生
    ld      a, #SOUND_SE_DAMAGE
    call    _SoundPlaySe

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_PlayerAddPhysicalDamage::

    ; レジスタの保存
    push    de

    ; a  < ダメージ量
    ; c  < 吹き飛ばされる向き
    ; b  < 吹き飛ばされる距離

    ; ネックレスによるダメージ料の軽減
    ld      d, a
    ld      a, (_player + PLAYER_NECKLACE)
    or      a
    ld      a, d
    jr      z, 19$
    sub     #PLAYER_NECKLACE_POINT
    jr      z, 10$
    jr      nc, 19$
10$:
    ld      a, #0x01
;   jr      19$
19$:

    ; ダメージの加算
    call    PlayerAddDamage

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

_PlayerAddMagicDamage::

    ; レジスタの保存
    push    hl
    push    de

    ; a  < ダメージ量
    ; c  < 吹き飛ばされる向き
    ; b  < 吹き飛ばされる距離

    ; ロッドによるダメージの軽減
    ld      d, a
    ld      a, (_player + PLAYER_ROD)
    or      a
    ld      a, d
    jr      z, 19$
    ld      hl, #(_player + PLAYER_RESIST)
    ld      a, (hl)
    cp      #PLAYER_RESIST_MAXIMUM
    jr      nc, 10$
    inc     a
    ld      (hl), a
10$:
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      a, d
    sub     e
    jr      z, 11$
    jr      nc, 19$
11$:
    ld      a, #0x01
;   jr      19$
19$:

    ; ダメージの加算
    call    PlayerAddDamage

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤに与えられたダメージを設定する
;
_PlayerSetDamage::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ダメージの更新
    ld      a, (_player + PLAYER_DAMAGE_POINT)
    or      a
    jr      z, 190$
    ld      c, a
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jr      nz, 101$
    ld      hl, #(_player + PLAYER_LIFE_POINT)
    ld      a, (hl)
    sub     c
    jr      nc, 100$
    xor     a
100$:
    ld      (hl), a
    jr      z, 120$
    ld      a, #PLAYER_DAMAGE_FRAME_LENGTH
    ld      (_player + PLAYER_DAMAGE_FRAME), a
101$:
    xor     a
    ld      (_player + PLAYER_DAMAGE_POINT), a

    ; 吹き飛ばし
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, (_player + PLAYER_DAMAGE_DISTANCE)
    or      a
    jr      z, 119$
    ld      b, a
    ld      a, (_player + PLAYER_DAMAGE_DIRECTION)
    dec     a
    jr      z, 111$
    dec     a
    jr      z, 113$
    dec     a
    jr      z, 114$
;   jr      z, 110$
110$:
    call    _FieldMoveUp
    jr      nc, 112$
    djnz    110$
    jr      112$
111$:
    call    _FieldMoveDown
    jr      nc, 112$
    djnz    111$
;   jr      112$
112$:
    ld      (_player + PLAYER_POSITION_X), de
    call    PlayerMoveCameraVertical
    jr      119$
113$:
    call    _FieldMoveLeft
    jr      nc, 115$
    djnz    113$
    jr      115$
114$:
    call    _FieldMoveRight
    jr      nc, 115$
    djnz    114$
;   jr      115$
115$:
    ld      (_player + PLAYER_POSITION_X), de
    call    PlayerMoveCameraHorizon
;   jr      119$
119$:
    jr      190$

    ; 死亡
120$:

    ; ダメージのクリア
    xor     a
    ld      (_player + PLAYER_DAMAGE_POINT), a

    ; 状態の更新
    ld      a, #PLAYER_STATE_DEAD
    ld      (_player + PLAYER_STATE), a
;   jr      190$

    ; ダメージの完了
190$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 休息を更新する
;
PlayerUpdateRest:

    ; レジスタの保存

    ; 休息による体力の回復
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MOVE_BIT, a
    jr      nz, 18$
    ld      de, (_player + PLAYER_POSITION_X)
    call    _FieldIsRest
    jr      nc, 18$
    ld      de, (_player + PLAYER_LIFE_POINT)
    ld      a, e
    cp      d
    jr      nc, 18$
    ld      hl, #(_player + PLAYER_REST)
    ld      a, (hl)
    inc     a
    cp      #PLAYER_REST_LENGTH
    jr      nc, 10$
    ld      (hl), a
    jr      19$
10$:
    xor     a
    ld      (hl), a
    ld      a, e
    inc     a
    ld      (_player + PLAYER_LIFE_POINT), a
    jr      19$
18$:
    xor     a
    ld      (_player + PLAYER_REST), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 経験値を更新する
;
PlayerUpdateExperience:

    ; レジスタの保存

    ; 経験値の更新
    ld      a, (_player + PLAYER_LIFE_POINT)
    or      a
    jr      z, 19$
    ld      a, (_player + PLAYER_EXPERIENCE_STACK)
    or      a
    jr      z, 19$
    ld      hl, #(_player + PLAYER_EXPERIENCE_POINT)
    add     a, (hl)
    jr      c, 10$
    cp      #PLAYER_EXPERIENCE_MAXIMUM
    jr      nc, 10$
    ld      (hl), a
    jr      11$

    ; レベルアップ
10$:
    call    PlayerLevelUp
;   jr      11$

    ; 経験値のクリア
11$:
    xor     a
    ld      (_player + PLAYER_EXPERIENCE_STACK), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤに経験値を加える
;
_PlayerAddExperience:

    ; レジスタの保存
    push    hl

    ; a < 経験値

    ; 経験値の加算
    ld      l, a
    ld      a, (_player + PLAYER_LEVEL)
    cp      #PLAYER_LEVEL_MAXIMUM
    jr      nc, 19$
    ld      h, a
    ld      a, l
    sub     h
    jr      z, 10$
    jr      nc, 11$
10$:
    ld      a, #0x01
11$:
    ld      hl, #(_player + PLAYER_EXPERIENCE_STACK)
    add     a, (hl)
    jr      nc, 12$
    ld      a, #0xff
12$:
    ld      (hl), a
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; レベルアップする
;
PlayerLevelUp:

    ; レジスタの保存
    push    hl

    ; レベルアップ
    xor     a
    ld      (_player + PLAYER_EXPERIENCE_POINT), a
    ld      hl, #(_player + PLAYER_LEVEL)
    inc     (hl)
    ld      hl, #(_player + PLAYER_LIFE_MAXIMUM)
    ld      a, (hl)
    add     a, #PLAYER_LIFE_LEVELUP
    ld      (hl), a
    dec     hl
    ld      (hl), a
    ld      hl, #(_player + PLAYER_POWER)
    ld      a, (hl)
    add     a, #PLAYER_POWER_LEVELUP
    ld      (hl), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; アニメーションを更新する
;
PlayerUpdateAnimation:

    ; レジスタの保存
    push    hl

    ; アイテムの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (hl)
    add     a, #0x04
    ld      (hl), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; アイテムを更新する
;
PlayerUpdateItem:

    ; レジスタの保存
    push    hl
    push    bc

    ; アイテムの更新
    ld      hl, #(_player + PLAYER_CRYSTAL_RED)
    ld      b, #(ITEM_LENGTH - 0x01)
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    cp      #PLAYER_ITEM_ANIMATION_LENGTH
    adc     a, #0x00
    ld      (hl), a
11$:
    inc     hl
    djnz    10$

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; アイテムを加える
;
PlayerAddItem:

    ; レジスタの保存
    push    hl
    push    de

    ; a  < アイテム
    ; cf > 1 = アイテムが加わった
    
    ; アイテムを加える
    or      a
    jr      z, 19$
    dec     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_player + PLAYER_CRYSTAL_RED)
    add     hl, de
    ld      d, a
    ld      a, (hl)
    or      a
    jr      nz, 19$
    inc     (hl)
    ld      a, e
    inc     a
    cp      #ITEM_KEY
    jr      nz, 10$
    call    _FieldSetKey
    jr      18$
10$:
    cp      #ITEM_RING
    jr      nz, 18$
    ld      hl, #(_player + PLAYER_POWER)
    ld      a, (hl)
    add     a, #PLAYER_RING_POINT
    ld      (hl), a
;   jr      18$
18$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; アイテムを拾う
;
_PlayerPickupItem:

    ; レジスタの保存

    ; a < アイテム
    
    ; アイテムを拾う
    call    PlayerAddItem
    jr      nc, 19$
    ld      a, #SOUND_SE_ITEM
    call    _SoundPlaySe
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerStay
    .dw     PlayerField
    .dw     PlayerDungeon
    .dw     PlayerDead
    .dw     PlayerClear
    .dw     PlayerExit

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_DIRECTION_DOWN
    .db     PLAYER_ANIMATION_NULL
    .db     PLAYER_BLINK_NULL
    .db     PLAYER_COLOR_NULL
    .dw     PLAYER_SPRITE_NULL
    .db     PLAYER_LEVEL_DEFAULT ; PLAYER_LEVEL_NULL
    .db     PLAYER_LIFE_DEFAULT ; PLAYER_LIFE_NULL
    .db     PLAYER_LIFE_DEFAULT ; PLAYER_LIFE_NULL
    .db     PLAYER_POWER_DEFAULT ; PLAYER_POWER_NULL
    .db     PLAYER_RESIST_NULL
    .db     PLAYER_EXPERIENCE_NULL
    .db     PLAYER_EXPERIENCE_NULL
    .db     PLAYER_ITEM_NULL ; ITEM_CRYSTAL_RED
    .db     PLAYER_ITEM_NULL ; ITEM_CRYSTAL_GREEN
    .db     PLAYER_ITEM_NULL ; ITEM_CRYSTAL_BLUE
    .db     PLAYER_ITEM_NULL ; ITEM_CRYSTAL_YELLOW
    .db     PLAYER_ITEM_NULL ; ITEM_CRYSTAL_WHITE
    .db     PLAYER_ITEM_NULL ; ITEM_KEY
    .db     PLAYER_ITEM_NULL ; ITEM_RING
    .db     PLAYER_ITEM_NULL ; ITEM_ROD
    .db     PLAYER_ITEM_NULL ; ITEM_NECKLACE
    .db     PLAYER_ITEM_NULL ; ITEM_CANDLE
    .db     PLAYER_DAMAGE_POINT_NULL
    .db     PLAYER_DAMAGE_FRAME_NULL
    .db     PLAYER_DAMAGE_DIRECTION_NULL
    .db     PLAYER_DAMAGE_DISTANCE_NULL
    .db     PLAYER_REST_NULL
    .db     PLAYER_FRAME_NULL
    .db     PLAYER_COUNT_NULL

; スプライト
;
playerSpriteBody:

    .db     -0x08 - 0x01, -0x08, GAME_SPRITE_PATTERN_PLAYER + 0x00, VDP_COLOR_WHITE

playerSpriteEdge:

    .db     -0x08 - 0x01, -0x08, GAME_SPRITE_PATTERN_PLAYER + 0x04, VDP_COLOR_BLACK

playerSpriteItem:

    .db     -0x08 - 0x01, -0x08, 0x08, VDP_COLOR_LIGHT_RED      ; ITEM_CRYSTAL_RED
    .db     -0x08 - 0x01, -0x08, 0x08, VDP_COLOR_LIGHT_GREEN    ; ITEM_CRYSTAL_GREEN
    .db     -0x08 - 0x01, -0x08, 0x08, VDP_COLOR_LIGHT_BLUE     ; ITEM_CRYSTAL_BLUE
    .db     -0x08 - 0x01, -0x08, 0x08, VDP_COLOR_LIGHT_YELLOW   ; ITEM_CRYSTAL_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x08, VDP_COLOR_WHITE          ; ITEM_CRYSTAL_WHITE
    .db     -0x08 - 0x01, -0x08, 0x0c, VDP_COLOR_LIGHT_YELLOW   ; ITEM_KEY
    .db     -0x08 - 0x01, -0x08, 0x10, VDP_COLOR_LIGHT_RED      ; ITEM_RING
    .db     -0x08 - 0x01, -0x08, 0x14, VDP_COLOR_LIGHT_BLUE     ; ITEM_ROD
    .db     -0x08 - 0x01, -0x08, 0x18, VDP_COLOR_LIGHT_GREEN    ; ITEM_NECKLACE
    .db     -0x08 - 0x01, -0x08, 0x1c, VDP_COLOR_LIGHT_RED      ; ITEM_CANDLE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

