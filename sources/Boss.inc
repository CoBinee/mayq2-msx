; Boss.inc : ボス
;


; マクロの定義
;

; ボス
BOSS_STATE                      =   0x00
BOSS_FLAG                       =   0x01
BOSS_POSITION_X                 =   0x02
BOSS_POSITION_Y                 =   0x03
BOSS_ANIMATION                  =   0x04
BOSS_BLINK                      =   0x05
BOSS_SPRITE_L                   =   0x06
BOSS_SPRITE_H                   =   0x07
BOSS_LIFE_L                     =   0x08
BOSS_LIFE_H                     =   0x09
BOSS_POWER                      =   0x0a
BOSS_DAMAGE                     =   0x0b
BOSS_COUNT                      =   0x0c
BOSS_FRAME                      =   0x0d
BOSS_CAST                       =   0x0e
BOSS_LENGTH                     =   0x0f

; 状態
BOSS_STATE_NULL                 =   0x00
BOSS_STATE_HIDE                 =   0x10
BOSS_STATE_PLAY                 =   0x20
BOSS_STATE_DEAD                 =   0x30

; フラグ
BOSS_FLAG_NULL                  =   0x00
BOSS_FLAG_HIT_BIT               =   0x07
BOSS_FLAG_HIT                   =   (1 << BOSS_FLAG_HIT_BIT)

; 位置
BOSS_POSITION_NULL              =   0x00

; アニメーション
BOSS_ANIMATION_NULL             =   0x00

; 点滅
BOSS_BLINK_NULL                 =   0x00
BOSS_BLINK_MOVE                 =   0x10
BOSS_BLINK_DEAD                 =   0x60
BOSS_BLINK_CYCLE                =   0x01

; スプライト
BOSS_SPRITE_NULL                =   0x00
BOSS_SPRITE_LENGTH              =   0x05

; ライフ
BOSS_LIFE_NULL                  =   0x00

; パワー
BOSS_POWER_NULL                 =   0x00

; ダメージ
BOSS_DAMAGE_NULL                =   0x00
BOSS_DAMAGE_LENGTH              =   0x04

; カウント
BOSS_COUNT_NULL                 =   0x00
BOSS_COUNT_STAY_BASE            =   0x02
BOSS_COUNT_STAY_MASK            =   0x03

; フレーム
BOSS_FRAME_NULL                 =   0x00
BOSS_FRAME_STAY_LENGTH          =   0x10

; 呪文
BOSS_CAST_NULL                  =   0x00
BOSS_CAST_BASE                  =   0x08
BOSS_CAST_MASK                  =   0x07

; 向き
BOSS_DIRECTION_UP               =   0x00
BOSS_DIRECTION_DOWN             =   0x01
BOSS_DIRECTION_LEFT             =   0x02
BOSS_DIRECTION_RIGHT            =   0x03

; 色
BOSS_COLOR_DAMAGE               =   VDP_COLOR_LIGHT_RED

; 大きさ
BOSS_SIZE_R                     =   0x02

; 外部関数宣言
;

    .globl  _BossInitialize
    .globl  _BossUpdate
    .globl  _BossRender
    .globl  _BossEntry
    .globl  _BossKill
    .globl  _BossSetPlay
    .globl  _BossIsLife
    .globl  _BossIsDead
    .globl  _BossDamage

; 外部変数宣言
;

    .globl  _boss
