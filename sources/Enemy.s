; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

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
    .include    "Player.inc"
    .include	"Enemy.inc"
    .include	"EnemyOne.inc"
    .include    "Field.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_ENTRY * ENEMY_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 登録の初期化
    xor     a
    ld      (enemyEntryCount), a
    ld      a, #ENEMY_ENTRY_FRAME_LENGTH
    ld      (enemyEntryFrame), a

    ; スプライトの初期化
    ld      de, #0x0000
    ld      (enemySpriteRotate), de

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの登録
    call    EnemyEntry

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 190$

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      z, 110$
    dec     ENEMY_DAMAGE_FRAME(ix)
110$:

    ; エネミーの生存
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      nz, 120$
    call    EnemyDead
    jr      190$
120$:

    ; 種類別の処理
    ld      hl, #180$
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
180$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      de, (enemySpriteRotate)
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jp      z, 190$

    ; 点滅
    push    de
    ld      a, ENEMY_BLINK(ix)
    and     #ENEMY_BLINK_CYCLE
    jp      nz, 180$

    ; スプライトの作成
    push    de
    bit     #ENEMY_FLAG_4WAY_BIT, ENEMY_FLAG(ix)
    jr      z, 110$
    ld      a, ENEMY_DIRECTION(ix)
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x10
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      l, ENEMY_PATTERN_TABLE_L(ix)
    ld      h, ENEMY_PATTERN_TABLE_H(ix)
    add     hl, de
    jr      111$
110$:
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x10
    ld      e, a
    ld      d, #0x00
    ld      l, ENEMY_PATTERN_TABLE_L(ix)
    ld      h, ENEMY_PATTERN_TABLE_H(ix)
    add     hl, de
;   jr      111$
111$:
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _GameGetSpriteMask
    ld      c, a
    ld      e, ENEMY_SPRITE_GENERATOR_L(ix)
    ld      d, ENEMY_SPRITE_GENERATOR_H(ix)
    call    _GameMakeSpriteGenerator
    inc     h
    push    hl
    ld      hl, #0x0020
    add     hl, de
    ex      de, hl
    pop     hl
    call    _GameMakeSpriteGenerator
    pop     de
    ld      a, c
    or      a
    jr      z, 180$

    ; 位置の取得
120$:
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, ENEMY_POSITION_X(ix)
    sub     c
    and     #(FIELD_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_X
    ld      c, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     b
    and     #(FIELD_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_Y
    ld      b, a

    ; スプライトの描画／ボディ
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY_BODY)
    add     hl, de
    ex      de, hl
    ld      hl, #enemySprite
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
    ld      a, ENEMY_SPRITE_PATTERN(ix)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    ld      a, ENEMY_COLOR(ix)
    jr      z, 130$
    ld      a, #ENEMY_COLOR_DAMAGE
130$:
    ld      (de), a
    inc     hl
;   inc     de
    pop     de

    ; スプライトの描画／エッジ
140$:
    push    hl
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY_EDGE)
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
    ld      a, ENEMY_SPRITE_PATTERN(ix)
    add     a, #0x04
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de

    ; スプライト位置の更新
180$:
    pop     de
    ld      a, e
    add     a, #0x04
    cp      #(0x04 * ENEMY_ENTRY)
    jr      c, 181$
    xor     a
181$:
    ld      e, a

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     b
    jp      nz, 100$

    ;  スプライトの更新
    ld      a, (enemySpriteRotate)
    add     a, #0x04
    cp      #(0x04 * ENEMY_ENTRY)
    jr      c, 20$
    xor     a
20$:
    ld      (enemySpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを登録する
;
EnemyEntry:

    ; レジスタの保存

    ; 登録の更新
    ld      a, (enemyEntryCount)
    cp      #ENEMY_ENTRY
    jr      nc, 90$
    ld      hl, #enemyEntryFrame
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      90$
10$:

    ; エネミーの走査
    ld      ix, #_enemy
    ld      bc, #((ENEMY_ENTRY << 8) | 0x00)
20$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      nz, 29$

    ; 位置の取得
    call    EnemyGetLocatePosition
    jr      nc, 29$

    ; エネミーの種類の取得
    push    de
    ld      de, (_player + PLAYER_POSITION_X)
    call    _FieldGetArea
    push    af
    and     #FIELD_TYPE_MASK
    srl     a
    srl     a
    srl     a
    ld      e, a
    pop     af
    bit     #FIELD_ENEMY_HIGH_BIT, a
    jr      z, 21$
    ld      a, (_player + PLAYER_LEVEL)
    cp      #PLAYER_LEVEL_HIGH
    jr      c, 21$
    call    _SystemGetRandom
    and     #0x01
    add     a, e
    ld      e, a
21$:
    ld      d, #0x00
    ld      hl, #enemyEntryType
    add     hl, de
    ld      a, (hl)
;   ld      a, #ENEMY_TYPE_GREMLIN
    pop     de

    ; エネミーの配置
    call    EnemyLocate

    ; 登録の再設定
    ld      hl, #enemyEntryCount
    inc     (hl)
    ld      a, #ENEMY_ENTRY_FRAME_LENGTH
    ld      (enemyEntryFrame), a
    jr      90$

    ; 次のエネミーの走査
29$:
    ld      de, #ENEMY_LENGTH
    add     ix, de
    ld      a, c
    add     a, #0x08
    ld      c, a
    djnz    20$
    
    ; 登録の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを配置する
;
EnemyLocate:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < エネミー
    ; de < Y/X 位置
    ; a  < エネミーの種類

    ; エネミーの配置
    push    bc
    push    de
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d
    call    _EnemyFacePlayer
    ld      a, c
    add     a, #GAME_SPRITE_PATTERN_ENEMY
    ld      ENEMY_SPRITE_PATTERN(ix), a
    ld      a, c
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #(_gameSpriteGenerator + GAME_SPRITE_GENERATOR_ENEMY)
    add     hl, de
    ld      ENEMY_SPRITE_GENERATOR_L(ix), l
    ld      ENEMY_SPRITE_GENERATOR_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤの周囲に配置する位置を取得する
;
EnemyGetLocatePosition:

    ; レジスタの保存
    push    hl

    ; de > Y/X 位置
    ; cf > 1 = 配置可能

    ; 配置する方向の取得
    ld      de, (_camera + CAMERA_POSITION_X)
    call    _SystemGetRandom
    and     #0x03
    dec     a
    jr      z, 110$
    dec     a
    jr      z, 120$
    dec     a
    jr      z, 130$
;   jr      z, 100$

    ; ↑に配置
100$:
    call    _SystemGetRandom
    and     #0x0f
    add     a, #((CAMERA_VIEW_SIZE_X - 0x10) / 2)
    add     a, e
    or      #0x01
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
;   ld      d, d
    jr      190$

    ; ↓に配置
110$:
    call    _SystemGetRandom
    and     #0x0f
    add     a, #((CAMERA_VIEW_SIZE_X - 0x10) / 2)
    add     a, e
    or      #0x01
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    ld      a, d
    add     a, #CAMERA_VIEW_SIZE_Y
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    jr      190$

    ; ←に配置
120$:
    call    _SystemGetRandom
    and     #0x0f
    add     a, ##((CAMERA_VIEW_SIZE_Y - 0x10) / 2)
    add     a, d
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
;   ld      e, e
    jr      190$

    ; →に配置
130$:
    call    _SystemGetRandom
    and     #0x0f
    add     a, ##((CAMERA_VIEW_SIZE_Y - 0x10) / 2)
    add     a, d
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    ld      a, e
    add     a, #CAMERA_VIEW_SIZE_X
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    jr      190$

    ; 配置の完了
190$:
    call    _FieldIsCollision
    ccf

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; エネミーを常駐させる
;
_EnemyReside::

    ; レジスタの保存
    push    de
    push    ix

    ; キーの所持
    ld      a, (_app + APP_GAME_ITEM)
    bit     #0x04, a
    jr      nz, 19$

    ; エネミーの配置
    ld      ix, #_enemy
    call    _FieldGetStartPosition
    call    _FieldGetFarPosition
    ld      a, #ENEMY_TYPE_GREMLIN
    call    EnemyLocate

    ; 登録の更新
    ld      hl, #enemyEntryCount
    inc     (hl)
19$:

    ; レジスタの復帰
    pop     ix
    pop     de

    ; 終了
    ret

; エネミーを削除する
;
_EnemyKill::

    ; レジスタの保存
    push    hl

    ; ix < エネミー

    ; エネミーの削除
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL

    ; 登録の更新
    ld      hl, #enemyEntryCount
    dec     (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_EnemyKillAll::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; エネミーの削除
    ld      hl, #(_enemy + ENEMY_TYPE)
    ld      de, #ENEMY_LENGTH
    ld      bc, #((ENEMY_ENTRY << 8) | ENEMY_TYPE_NULL)
10$:
    ld      (hl), c
    add     hl, de
    djnz    10$

    ; 登録の更新
    xor     a
    ld      (enemyEntryCount), a

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret
    
_EnemyKillIsDistanceFar::

    ; レジスタの保存

    ; ix < エネミー
    ; cf > 1 = 削除

    ; エネミーの削除
    bit     #ENEMY_FLAG_RESIDE_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    call    _EnemyIsDistanceFar
    jr      nc, 10$
    call    _EnemyKill
    scf
    jr      19$
10$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; エネミーにダメージを与える
;
_EnemyDamage::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; a  < ダメージ量
    ; c  < 吹き飛ばされる向き
    ; b  < 吹き飛ばされる距離

    ; ライフの減少
    ld      e, a
    ld      a, ENEMY_LIFE(ix)
    sub     e
    jr      z, 10$
    jr      nc, 11$
10$:
    call    EnemySetDead
    jr      90$
11$:
    ld      ENEMY_LIFE(ix), a
    ld      ENEMY_DAMAGE_FRAME(ix), #ENEMY_DAMAGE_FRAME_LENGTH

    ; 吹き飛ばし
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    dec     c
    jr      z, 21$
    dec     c
    jr      z, 22$
    dec     c
    jr      z, 23$
;   jr      z, 20$
20$:
    call    _FieldMoveUp
    jr      nc, 29$
    djnz    20$
    jr      29$
21$:
    call    _FieldMoveDown
    jr      nc, 29$
    djnz    21$
    jr      29$
22$:
    call    _FieldMoveLeft
    jr      nc, 29$
    djnz    22$
    jr      29$
23$:
    call    _FieldMoveRight
    jr      nc, 29$
    djnz    23$
;   jr      29$
29$:
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d

    ; ダメージの完了
90$:

    ; SE の再生
    ld      a, #SOUND_SE_HIT
    call    _SoundPlaySe

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; ランダムに向きを変える
;
_EnemyTurnRandom::

    ; レジスタの保存

    ; ix < エネミー

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x03
    ld      ENEMY_DIRECTION(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; 今の方向以外の向きへ曲がる
;
_EnemyTurnBack::

    ; レジスタの保存

    ; ix < エネミー

    ; 向きの設定
10$:
    call    _SystemGetRandom
    and     #0x03
    jr      z, 10$
    add     a, ENEMY_DIRECTION(ix)
    and     #0x03
    ld      ENEMY_DIRECTION(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのいる方向に向きを設定する
;
_EnemyFacePlayer::

    ; レジスタの保存

    ; ix < エネミー

    ; 向きの設定
    call    _EnemyGetFacePlayerDirection
    ld      ENEMY_DIRECTION(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのいる方向を取得する
;
_EnemyGetFacePlayerDirection::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; a  > 向き

    ; 向きの取得
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, e
    sub     ENEMY_POSITION_X(ix)
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    ld      c, a
    cp      #(FIELD_SIZE_X / 2)
    jr      c, 10$
    ld      a, #FIELD_SIZE_X
    sub     c
    ld      c, a
10$:
    ld      a, d
    sub     ENEMY_POSITION_Y(ix)
    and     #(FIELD_SIZE_Y - 0x01)
    ld      d, a
    ld      b, a
    cp      #(FIELD_SIZE_Y / 2)
    jr      c, 11$
    ld      a, #FIELD_SIZE_Y
    sub     b
    ld      b, a
11$:
    ld      a, c
    cp      b
    jr      c, 12$
    ld      a, e
    cp      #(FIELD_SIZE_X / 2)
    ld      a, #ENEMY_DIRECTION_LEFT
    adc     a, #0x00
    jr      13$
12$:
    ld      a, d
    cp      #(FIELD_SIZE_Y / 2)
    ld      a, #ENEMY_DIRECTION_UP
    adc     a, #0x00
;   jr      13$
13$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; プレイヤから離れたかどうかを判定する
;
_EnemyIsDistanceOut::

    ; レジスタの保存
    push    de

    ; ix < エネミー
    ; cf > 1 = 離れた

    ; 距離の判定
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, ENEMY_POSITION_X(ix)
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    cp      #ENEMY_DISTANCE_OUT
    jr      c, 10$
    cp      #(FIELD_SIZE_X - ENEMY_DISTANCE_OUT)
    jr      c, 19$
10$:
    ld      a, ENEMY_POSITION_Y(ix)
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #ENEMY_DISTANCE_OUT
    jr      c, 11$
    cp      #(FIELD_SIZE_X - ENEMY_DISTANCE_OUT)
    jr      c, 19$
11$:
    or      a
;   jr      19$
19$:    

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

_EnemyIsDistanceFar::

    ; レジスタの保存
    push    de

    ; ix < エネミー
    ; cf > 1 = 離れた

    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, ENEMY_POSITION_X(ix)
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    cp      #ENEMY_DISTANCE_FAR
    jr      c, 10$
    cp      #(FIELD_SIZE_X - ENEMY_DISTANCE_FAR)
    jr      c, 19$
10$:
    ld      a, ENEMY_POSITION_Y(ix)
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #ENEMY_DISTANCE_FAR
    jr      c, 11$
    cp      #(FIELD_SIZE_X - ENEMY_DISTANCE_FAR)
    jr      c, 19$
11$:
    or      a
;   jr      19$
19$:    

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; アニメーションを更新する
;
_EnemyUpdateAnimation::

    ; レジスタの保存

    ; ix < エネミー
    ; a  < アニメーションの速度

    ; アニメーションの更新
    add     a, ENEMY_ANIMATION(ix)
    ld      ENEMY_ANIMATION(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; ix < エネミー

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを死亡させる
;
EnemySetDead:

    ; レジスタの保存

    ; ix < エネミー

    ; 死亡の設定
    xor     a
    ld      ENEMY_LIFE(ix), a
    ld      ENEMY_DAMAGE_FRAME(ix), a
    ld      ENEMY_BLINK(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが死亡する
;
EnemyDead:

    ; レジスタの保存

    ; ix < エネミー

    ; 点滅の更新
    inc     ENEMY_BLINK(ix)
    ld      a, ENEMY_BLINK(ix)
    cp      #ENEMY_BLINK_DEAD
    jr      c, 19$

    ; 経験値の加算
    ld      a, ENEMY_EXPERIENCE(ix)
    call    _PlayerAddExperience

    ; アイテムの付与
    ld      a, ENEMY_ITEM(ix)
    or      a
    call    nz, _PlayerPickupItem

    ; エネミーの削除
    call    _EnemyKill
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 種類別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     _EnemySlime
    .dw     _EnemyCyclops
    .dw     _EnemyXorn
    .dw     _EnemyLizard
    .dw     _EnemySkelton
    .dw     _EnemyPhantom
    .dw     _EnemyTroll
    .dw     _EnemyDaemon
    .dw     _EnemyGremlin

; 種類別の初期値
;
enemyDefault:

    .dw     enemyNullDefault
    .dw     _enemySlimeDefault
    .dw     _enemyCyclopsDefault
    .dw     _enemyXornDefault
    .dw     _enemyLizardDefault
    .dw     _enemySkeltonDefault
    .dw     _enemyPhantomDefault
    .dw     _enemyTrollDefault
    .dw     _enemyDaemonDefault
    .dw     _enemyGremlinDefault

enemyNullDefault:

    .db     ENEMY_TYPE_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     ENEMY_PATTERN_TABLE_NULL
    .db     ENEMY_LIFE_NULL
    .db     ENEMY_POWER_NULL
    .db     ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     ENEMY_MOVE_STEP_BASE_NULL
    .db     ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     ENEMY_MOVE_TURN_BASE_NULL
    .db     ENEMY_MOVE_TURN_MASK_NULL
    .db     ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     ENEMY_STAY_BASE_NULL
    .db     ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; 登録
;
enemyEntryType:

    .db     ENEMY_TYPE_SLIME,   ENEMY_TYPE_CYCLOPS
    .db     ENEMY_TYPE_XORN,    ENEMY_TYPE_LIZARD
    .db     ENEMY_TYPE_SKELTON, ENEMY_TYPE_PHANTOM
    .db     ENEMY_TYPE_TROLL,   ENEMY_TYPE_DAEMON

; スプライト
;
enemySprite:

    .db     -0x08 - 0x01, -0x08, 0x00, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x04, VDP_COLOR_BLACK


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_ENTRY * ENEMY_LENGTH

; 登録
;
enemyEntryCount:

    .ds     0x01

enemyEntryFrame:

    .ds     0x01

; スプライト
;
enemySpriteRotate:

    .ds     0x02

