; EnemyOne.s : それぞれのエネミー
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
    .include    "Magic.inc"
    .include    "Field.inc"

; 外部変数宣言
;

    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; スライム
;
_EnemySlime::
    
; サイクロプス
;
_EnemyCyclops::
    
; ゾーン
;
_EnemyXorn::
    
; リザード
;
_EnemyLizard::
    
; スケルトン
;
_EnemySkelton::
    
; ファントム
;
_EnemyPhantom::
    
; トロル
;
_EnemyTroll::
    
; デーモン
;
_EnemyDaemon::
    
; グレムリン
;
_EnemyGremlin::
    
    ; レジスタの保存

    ; ix < エネミー

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 移動の設定
    ld      a, ENEMY_MOVE_SPEED(ix)
    ld      ENEMY_MOVE_FRAME(ix), a
    call    800$
    call    810$

    ; 待機の設定
    xor     a
    ld      ENEMY_STAY_FRAME(ix), a

    ; 状態の更新
    inc     ENEMY_STATE(ix)
09$:

    ; 待機の更新
10$:
    ld      a, ENEMY_STAY_FRAME(ix)
    or      a
    jr      z, 200$
    dec     ENEMY_STAY_FRAME(ix)
    jr      nz, 19$
    call    _EnemyTurnRandom
    jr      200$

    ; 待機のアニメーション
19$:
    ld      a, ENEMY_STAY_SPEED(ix)
    call    _EnemyUpdateAnimation
    jp      90$

    ; 移動の更新
200$:
    dec     ENEMY_MOVE_FRAME(ix)
    jp      nz, 90$
    ld      a, ENEMY_MOVE_SPEED(ix)
    ld      ENEMY_MOVE_FRAME(ix), a

    ; 向いている方向に移動
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    ld      a, ENEMY_DIRECTION(ix)
    dec     a
    jr      z, 211$
    dec     a
    jr      z, 212$
    dec     a
    jr      z, 213$
;   jr      210$
210$:
    call    _FieldMoveUp
    jr      219$
211$:
    call    _FieldMoveDown
    jr      219$
212$:
    call    _FieldMoveLeft
    jr      219$
213$:
    call    _FieldMoveRight
;   jr      219$
219$:
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d

    ; 進めないので曲がる
    jr      c, 220$
    call    _EnemyTurnBack
    call    800$
    jr      290$
220$:

    ; 離れたので削除
    bit     #ENEMY_FLAG_RESIDE_BIT, ENEMY_FLAG(ix)
    jr      nz, 221$
    call    _EnemyKillIsDistanceFar
    jp      c, 90$
221$:

    ; 歩数の更新
    dec     ENEMY_MOVE_STEP_COUNT(ix)
    jr      nz, 290$
    call    800$

    ; 常駐するエネミーはランダムに曲がる
    bit     #ENEMY_FLAG_RESIDE_BIT, ENEMY_FLAG(ix)
    jr      z, 222$
    call    _EnemyTurnRandom
    jr      290$
222$:

    ; 画面外に行った
    call    _EnemyIsDistanceOut
    jr      nc, 223$
    call    _EnemyFacePlayer
    jr      290$
223$:

    ; 前にプレイヤがいたら魔法を撃つ
    bit     #ENEMY_FLAG_CAST_BIT, ENEMY_FLAG(ix)
    jr      z, 224$
    call    _EnemyGetFacePlayerDirection
    cp      ENEMY_DIRECTION(ix)
    jr      z, 30$
224$:

    ; 曲がる回数の更新
    dec     ENEMY_MOVE_TURN_COUNT(ix)
    jr      z, 226$
    call    _SystemGetRandom
    and     #0x18
    jr      nz, 225$
    call    _EnemyFacePlayer
    jr      290$
225$:
    call    _EnemyTurnRandom
    jr      290$
226$:
    call    810$

    ; 待機
    call    _SystemGetRandom
    and     ENEMY_STAY_MASK(ix)
    add     ENEMY_STAY_BASE(ix)
    jr      z, 227$    
    ld      ENEMY_STAY_FRAME(ix), a
    jr      290$
227$:
    call    _EnemyTurnRandom
;   jr      290$

    ; 移動のアニメーション
290$:
    ld      a, #ENEMY_ANIMATION_CYCLE
    call    _EnemyUpdateAnimation
    jr      90$

    ; 魔法を撃つ
30$:
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    ld      a, ENEMY_DIRECTION(ix)
    call    _MagicCast
    ld      ENEMY_STAY_FRAME(ix), #ENEMY_STAY_FRAME_CAST

    ; SE の再生
    ld      a, #SOUND_SE_CAST
    call    _SoundPlaySe
    jr      90$

    ; 歩数の設定
800$:
    call    _SystemGetRandom
    and     ENEMY_MOVE_STEP_MASK(ix)
    add     a, ENEMY_MOVE_STEP_BASE(ix)
    ld      ENEMY_MOVE_STEP_COUNT(ix), a
    ret

    ; 曲がる回数の設定
810$:
    call    _SystemGetRandom
    and     ENEMY_MOVE_TURN_MASK(ix)
    add     a, ENEMY_MOVE_TURN_BASE(ix)
    ld      ENEMY_MOVE_TURN_COUNT(ix), a
    ret

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;

; スライム
_enemySlimeDefault::

    .db     ENEMY_TYPE_SLIME
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_CYAN ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x2600
    .db     0x18 ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_POWER_NULL
    .db     0x04 ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x04 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x03 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x03 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x01 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x01 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x18 ; ENEMY_STAY_BASE_NULL
    .db     0x0f ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; サイクロプス
_enemyCyclopsDefault::

    .db     ENEMY_TYPE_CYCLOPS
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_4WAY | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_LIGHT_BLUE ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x1800
    .db     0x78 ; ENEMY_LIFE_NULL
    .db     0x05 ; ENEMY_POWER_NULL
    .db     0x08 ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x04 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x00 ; ENEMY_STAY_BASE_NULL
    .db     0x00 ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; ゾーン
_enemyXornDefault::

    .db     ENEMY_TYPE_XORN
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_4WAY | ENEMY_FLAG_CAST | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_DARK_RED ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x1e00
    .db     0x60 ; ENEMY_LIFE_NULL
    .db     0x03 ; ENEMY_POWER_NULL
    .db     0x07 ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x04 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x01 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x03 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x18 ; ENEMY_STAY_BASE_NULL
    .db     0x1f ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; リザード
_enemyLizardDefault::

    .db     ENEMY_TYPE_LIZARD
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_4WAY | ENEMY_FLAG_CAST | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_MEDIUM_GREEN ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x2200
    .db     0xa8 ; ENEMY_LIFE_NULL
    .db     0x07 ; ENEMY_POWER_NULL
    .db     0x0a ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x04 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x05 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x03 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x00 ; ENEMY_STAY_BASE_NULL
    .db     0x00 ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; スケルトン
_enemySkeltonDefault::

    .db     ENEMY_TYPE_SKELTON
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_4WAY | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_GRAY ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x1c00
    .db     0x30 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_POWER_NULL
    .db     0x05 ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x04 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x00 ; ENEMY_STAY_BASE_NULL
    .db     0x00 ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; ファントム
_enemyPhantomDefault::

    .db     ENEMY_TYPE_PHANTOM
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_DARK_BLUE ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x2640
    .db     0x90 ; ENEMY_LIFE_NULL
    .db     0x06 ; ENEMY_POWER_NULL
    .db     0x09 ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x03 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x01 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x03 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x18 ; ENEMY_STAY_BASE_NULL
    .db     0x1f ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; トロル
_enemyTrollDefault::

    .db     ENEMY_TYPE_TROLL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_4WAY | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_DARK_YELLOW ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x1a00
    .db     0x48 ; ENEMY_LIFE_NULL
    .db     0x03 ; ENEMY_POWER_NULL
    .db     0x06 ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x04 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x00 ; ENEMY_STAY_BASE_NULL
    .db     0x00 ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; デーモン
_enemyDaemonDefault::

    .db     ENEMY_TYPE_DAEMON
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_4WAY | ENEMY_FLAG_CAST | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_MAGENTA ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x2000
    .db     0xc0 ; ENEMY_LIFE_NULL
    .db     0x08 ; ENEMY_POWER_NULL
    .db     0x0b ; ENEMY_EXPERIENCE_NULL
    .db     ENEMY_ITEM_NULL
    .db     0x03 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x00 ; ENEMY_STAY_BASE_NULL
    .db     0x00 ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL

; グレムリン
_enemyGremlinDefault::

    .db     ENEMY_TYPE_GREMLIN
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_RESIDE | ENEMY_FLAG_4WAY | ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .db     VDP_COLOR_MEDIUM_RED ; ENEMY_COLOR_NULL
    .db     ENEMY_SPRITE_PATTERN_NULL
    .dw     ENEMY_SPRITE_GENERATOR_NULL
    .dw     _patternTable + 0x2400
    .db     0x0078 ; ENEMY_LIFE_NULL
    .db     0x04 ; ENEMY_POWER_NULL
    .db     0x07 ; ENEMY_EXPERIENCE_NULL
    .db     ITEM_KEY ; ENEMY_ITEM_NULL
    .db     0x02 ; ENEMY_MOVE_SPEED_NULL
    .db     ENEMY_MOVE_FRAME_NULL
    .db     ENEMY_MOVE_STEP_COUNT_NULL
    .db     0x04 ; ENEMY_MOVE_STEP_BASE_NULL
    .db     0x07 ; ENEMY_MOVE_STEP_MASK_NULL
    .db     ENEMY_MOVE_TURN_COUNT_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_BASE_NULL
    .db     0x00 ; ENEMY_MOVE_TURN_MASK_NULL
    .db     0x04 ; ENEMY_STAY_SPEED_NULL
    .db     ENEMY_STAY_FRAME_NULL
    .db     0x00 ; ENEMY_STAY_BASE_NULL
    .db     0x00 ; ENEMY_STAY_MASK_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

