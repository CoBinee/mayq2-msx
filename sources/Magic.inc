; Magic.inc : 魔法
;


; マクロの定義
;

; 魔法
MAGIC_STATE                     =   0x00
MAGIC_POSITION_X                =   0x01
MAGIC_POSITION_Y                =   0x02
MAGIC_SPEED_X                   =   0x03
MAGIC_SPEED_Y                   =   0x04
MAGIC_DIRECTION                 =   0x05
MAGIC_ANIMATION                 =   0x06
MAGIC_SPRITE_L                  =   0x07
MAGIC_SPRITE_H                  =   0x08
MAGIC_LENGTH                    =   0x09
MAGIC_ENTRY                     =   0x04

; 状態
MAGIC_STATE_NULL                =   0x00
MAGIC_STATE_CAST                =   0x10

; 位置
MAGIC_POSITION_NULL             =   0x00

; 速度
MAGIC_SPEED_NULL                =   0x00

; 向き
MAGIC_DIRECTION_UP              =   0x00
MAGIC_DIRECTION_DOWN            =   0x01
MAGIC_DIRECTION_LEFT            =   0x02
MAGIC_DIRECTION_RIGHT           =   0x03
MAGIC_DIRECTION_UP_LEFT         =   0x04
MAGIC_DIRECTION_UP_RIGHT        =   0x05
MAGIC_DIRECTION_DOWN_LEFT       =   0x06
MAGIC_DIRECTION_DOWN_RIGHT      =   0x07

; アニメーション
MAGIC_ANIMATION_NULL            =   0x00

; スプライト
MAGIC_SPRITE_NULL               =   0x00

; パワー
MAGIC_POWER                     =   0x08

; 大きさ
MAGIC_SIZE_R                    =   0x01

; 外部関数宣言
;

    .globl  _MagicInitialize
    .globl  _MagicUpdate
    .globl  _MagicRender
    .globl  _MagicCast
    .globl  _MagicKill
    .globl  _MagicKillAll

; 外部変数宣言
;

    .globl  _magic
