; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_X                =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_DIRECTION                 =   0x05
ENEMY_ANIMATION                 =   0x06
ENEMY_BLINK                     =   0x07
ENEMY_COLOR                     =   0x08
ENEMY_SPRITE_PATTERN            =   0x09
ENEMY_SPRITE_GENERATOR_L        =   0x0a
ENEMY_SPRITE_GENERATOR_H        =   0x0b
ENEMY_PATTERN_TABLE_L           =   0x0c
ENEMY_PATTERN_TABLE_H           =   0x0d
ENEMY_LIFE                      =   0x0e
ENEMY_POWER                     =   0x0f
ENEMY_EXPERIENCE                =   0x10
ENEMY_ITEM                      =   0x11
ENEMY_MOVE_SPEED                =   0x12
ENEMY_MOVE_FRAME                =   0x13
ENEMY_MOVE_STEP_COUNT           =   0x14
ENEMY_MOVE_STEP_BASE            =   0x15
ENEMY_MOVE_STEP_MASK            =   0x16
ENEMY_MOVE_TURN_COUNT           =   0x17
ENEMY_MOVE_TURN_BASE            =   0x18
ENEMY_MOVE_TURN_MASK            =   0x19
ENEMY_STAY_SPEED                =   0x1a
ENEMY_STAY_FRAME                =   0x1b
ENEMY_STAY_BASE                 =   0x1c
ENEMY_STAY_MASK                 =   0x1d
ENEMY_DAMAGE_POINT              =   0x1e
ENEMY_DAMAGE_FRAME              =   0x1f
ENEMY_LENGTH                    =   0x20

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_SLIME                =   0x01
ENEMY_TYPE_CYCLOPS              =   0x02
ENEMY_TYPE_XORN                 =   0x03
ENEMY_TYPE_LIZARD               =   0x04
ENEMY_TYPE_SKELTON              =   0x05
ENEMY_TYPE_PHANTOM              =   0x06
ENEMY_TYPE_TROLL                =   0x07
ENEMY_TYPE_DAEMON               =   0x08
ENEMY_TYPE_GREMLIN              =   0x09

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_CAST_BIT             =   0x05
ENEMY_FLAG_CAST                 =   (1 << ENEMY_FLAG_CAST_BIT)
ENEMY_FLAG_4WAY_BIT             =   0x06
ENEMY_FLAG_4WAY                 =   (1 << ENEMY_FLAG_4WAY_BIT)
ENEMY_FLAG_RESIDE_BIT           =   0x07
ENEMY_FLAG_RESIDE               =   (1 << ENEMY_FLAG_RESIDE_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 向き
ENEMY_DIRECTION_UP              =   0x00
ENEMY_DIRECTION_DOWN            =   0x01
ENEMY_DIRECTION_LEFT            =   0x02
ENEMY_DIRECTION_RIGHT           =   0x03

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00
ENEMY_ANIMATION_CYCLE           =   0x10

; 点滅
ENEMY_BLINK_NULL                =   0x00
ENEMY_BLINK_DEAD                =   0x10
ENEMY_BLINK_CYCLE               =   0x01

; 色
ENEMY_COLOR_NULL                =   0x00
ENEMY_COLOR_DAMAGE              =   VDP_COLOR_LIGHT_RED

; スプライト
ENEMY_SPRITE_PATTERN_NULL       =   0x00
ENEMY_SPRITE_GENERATOR_NULL     =   0x00

; パターンテーブル
ENEMY_PATTERN_TABLE_NULL        =   0x00

; ライフ
ENEMY_LIFE_NULL                 =   0x00

; パワー
ENEMY_POWER_NULL                =   0x00

; 経験値
ENEMY_EXPERIENCE_NULL           =   0x00

; アイテム
ENEMY_ITEM_NULL                 =   0x00

; 移動
ENEMY_MOVE_SPEED_NULL           =   0x00
ENEMY_MOVE_FRAME_NULL           =   0x00
ENEMY_MOVE_STEP_COUNT_NULL      =   0x00
ENEMY_MOVE_STEP_BASE_NULL       =   0x00
ENEMY_MOVE_STEP_MASK_NULL       =   0x00
ENEMY_MOVE_TURN_COUNT_NULL      =   0x00
ENEMY_MOVE_TURN_BASE_NULL       =   0x00
ENEMY_MOVE_TURN_MASK_NULL       =   0x00

; 待機
ENEMY_STAY_SPEED_NULL           =   0x00
ENEMY_STAY_FRAME_NULL           =   0x00
ENEMY_STAY_FRAME_CAST           =   0x20
ENEMY_STAY_BASE_NULL            =   0x00
ENEMY_STAY_MASK_NULL            =   0x00

; ダメージ
ENEMY_DAMAGE_POINT_NULL         =   0x00
ENEMY_DAMAGE_FRAME_NULL         =   0x00
ENEMY_DAMAGE_FRAME_LENGTH       =   0x04
ENEMY_DAMAGE_DISTANCE_NULL      =   0x00
ENEMY_DAMAGE_DISTANCE_NORMAL    =   0x01
ENEMY_DAMAGE_DISTANCE_SHIFT     =   0x03

; 登録
ENEMY_ENTRY                     =   0x05
ENEMY_ENTRY_FRAME_LENGTH        =   0x14

; 距離
ENEMY_DISTANCE_OUT              =   0x0c
ENEMY_DISTANCE_FAR              =   0x10

; 大きさ
ENEMY_SIZE_R                    =   0x01

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyReside
    .globl  _EnemyKill
    .globl  _EnemyKillAll
    .globl  _EnemyKillIsDistanceFar
    .globl  _EnemyDamage
    .globl  _EnemyTurnRandom
    .globl  _EnemyTurnBack
    .globl  _EnemyFacePlayer
    .globl  _EnemyGetFacePlayerDirection
    .globl  _EnemyIsDistanceOut
    .globl  _EnemyIsDistanceFar
    .globl  _EnemyUpdateAnimation

; 外部変数宣言
;

    .globl  _enemy
