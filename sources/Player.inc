; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_DIRECTION                =   0x04
PLAYER_ANIMATION                =   0x05
PLAYER_BLINK                    =   0x06
PLAYER_COLOR                    =   0x07
PLAYER_SPRITE_L                 =   0x08
PLAYER_SPRITE_H                 =   0x09
PLAYER_LEVEL                    =   0x0a
PLAYER_LIFE_POINT               =   0x0b
PLAYER_LIFE_MAXIMUM             =   0x0c
PLAYER_POWER                    =   0x0d
PLAYER_RESIST                   =   0x0e
PLAYER_EXPERIENCE_POINT         =   0x0f
PLAYER_EXPERIENCE_STACK         =   0x10
PLAYER_CRYSTAL_RED              =   0x11
PLAYER_CRYSTAL_GREEN            =   0x12
PLAYER_CRYSTAL_BLUE             =   0x13
PLAYER_CRYSTAL_YELLOW           =   0x14
PLAYER_CRYSTAL_WHITE            =   0x15
PLAYER_KEY                      =   0x16
PLAYER_RING                     =   0x17
PLAYER_ROD                      =   0x18
PLAYER_NECKLACE                 =   0x19
PLAYER_CANDLE                   =   0x1a
PLAYER_DAMAGE_POINT             =   0x1b
PLAYER_DAMAGE_FRAME             =   0x1c
PLAYER_DAMAGE_DIRECTION         =   0x1d
PLAYER_DAMAGE_DISTANCE          =   0x1e
PLAYER_REST                     =   0x1f
PLAYER_FRAME                    =   0x20
PLAYER_COUNT                    =   0x21
PLAYER_LENGTH                   =   0x22

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_STAY               =   0x10
PLAYER_STATE_FIELD              =   0x20
PLAYER_STATE_DUNGEON            =   0x30
PLAYER_STATE_DEAD               =   0x40
PLAYER_STATE_CLEAR              =   0x50
PLAYER_STATE_EXIT               =   0x60

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_MOVE_BIT            =   0x00
PLAYER_FLAG_MOVE                =   (1 << PLAYER_FLAG_MOVE_BIT)
PLAYER_FLAG_DEAD_BIT            =   0x07
PLAYER_FLAG_DEAD                =   (1 << PLAYER_FLAG_DEAD_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 向き
PLAYER_DIRECTION_UP             =   0x00
PLAYER_DIRECTION_DOWN           =   0x01
PLAYER_DIRECTION_LEFT           =   0x02
PLAYER_DIRECTION_RIGHT          =   0x03

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00

; 点滅
PLAYER_BLINK_NULL               =   0x00
PLAYER_BLINK_DEAD               =   0x20
PLAYER_BLINK_CYCLE              =   0x01

; 色
PLAYER_COLOR_NULL               =   0x00
PLAYER_COLOR_DAMAGE             =   VDP_COLOR_LIGHT_RED

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; レベル
PLAYER_LEVEL_NULL               =   0x00
PLAYER_LEVEL_DEFAULT            =   0x01
PLAYER_LEVEL_MAXIMUM            =   0x09
PLAYER_LEVEL_HIGH               =   0x05

; ライフ
PLAYER_LIFE_NULL                =   0x00
PLAYER_LIFE_DEFAULT             =   0x08
PLAYER_LIFE_LEVELUP             =   0x06

; パワー
PLAYER_POWER_NULL               =   0x00
PLAYER_POWER_DEFAULT            =   0x08
PLAYER_POWER_MAXIMUM            =   0x38
PLAYER_POWER_LEVELUP            =   0x05

; レジスト
PLAYER_RESIST_NULL              =   0x00
PLAYER_RESIST_MAXIMUM           =   0x38

; 経験値
PLAYER_EXPERIENCE_NULL          =   0x00
PLAYER_EXPERIENCE_MAXIMUM       =   0x38

; アイテム
PLAYER_ITEM_NULL                =   0x00
PLAYER_ITEM_ANIMATION_LENGTH    =   0x1c
PLAYER_ITEM_ANIMATION_CYCLE     =   0x04

; リング
PLAYER_RING_POINT               =   0x08

; ネックレス
PLAYER_NECKLACE_POINT           =   0x04

; ダメージ
PLAYER_DAMAGE_POINT_NULL        =   0x00
PLAYER_DAMAGE_FRAME_NULL        =   0x00
PLAYER_DAMAGE_FRAME_LENGTH      =   0x04
PLAYER_DAMAGE_DIRECTION_NULL    =   0x00
PLAYER_DAMAGE_DISTANCE_NULL     =   0x00
PLAYER_DAMAGE_DISTANCE_NORMAL   =   0x01
PLAYER_DAMAGE_DISTANCE_SHIFT    =   0x03

; 休息
PLAYER_REST_NULL                =   0x00
PLAYER_REST_LENGTH              =   0x10

; フレーム
PLAYER_FRAME_NULL               =   0x00
PLAYER_FRAME_WALK               =   0x0c

; カウント
PLAYER_COUNT_NULL               =   0x00

; カメラ
PLAYER_CAMERA_OFFSET_X          =   0x0b
PLAYER_CAMERA_OFFSET_Y          =   0x0b
PLAYER_CAMERA_DISTANCE_LEFT     =   0x07
PLAYER_CAMERA_DISTANCE_RIGHT    =   0x10
PLAYER_CAMERA_DISTANCE_UP       =   0x07
PLAYER_CAMERA_DISTANCE_DOWN     =   0x10

; パターンテーブル
PLAYER_PATTERN_TABLE            =   0x0600

; 大きさ
PLAYER_SIZE_R                   =   0x01

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerSetStay
    .globl  _PlayerSetField
    .globl  _PlayerSetDungeon
    .globl  _PlayerSetClear
    .globl  _PlayerSetExit
    .globl  _PlayerIsStay
    .globl  _PlayerIsDead
    .globl  _PlayerSetCameraCenter
    .globl  _PlayerIsEntrance
    .globl  _PlayerIsHole
    .globl  _PlayerAddPhysicalDamage
    .globl  _PlayerAddMagicDamage
    .globl  _PlayerSetDamage
    .globl  _PlayerAddExperience
    .globl  _PlayerPickupItem

; 外部変数宣言
;

    .globl  _player
