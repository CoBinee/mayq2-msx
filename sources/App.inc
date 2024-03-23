; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_COLOR_TABLE                 =   0x2000
APP_PATTERN_NAME_TABLE          =   0x1800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3000

; アプリケーション
APP_STATE                       =   0x00
APP_FRAME                       =   0x01
APP_GAME_RANDOM_L               =   0x02
APP_GAME_RANDOM_H               =   0x03
APP_GAME_LEVEL                  =   0x04
APP_GAME_EXPERIENCE             =   0x05
APP_GAME_RESIST                 =   0x06
APP_GAME_CRYSTAL                =   0x07
APP_GAME_ITEM                   =   0x08
APP_CRC                         =   0x09
APP_PASSWORD_0                  =   0x0a
APP_PASSWORD_1                  =   0x0b
APP_PASSWORD_2                  =   0x0c
APP_PASSWORD_3                  =   0x0d
APP_PASSWORD_4                  =   0x0e
APP_PASSWORD_5                  =   0x0f
APP_PASSWORD_6                  =   0x10
APP_PASSWORD_7                  =   0x11
APP_PASSWORD_8                  =   0x12
APP_PASSWORD_9                  =   0x13
APP_DEBUG_0                     =   0x14
APP_DEBUG_1                     =   0x15
APP_DEBUG_2                     =   0x16
APP_DEBUG_3                     =   0x17
APP_DEBUG_4                     =   0x18
APP_DEBUG_5                     =   0x19
APP_DEBUG_6                     =   0x1a
APP_DEBUG_7                     =   0x1b
APP_LENGTH                      =   0x1c

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04

; フレーム
APP_FRAME_NULL                  =   0x00

; ゲーム
APP_GAME_NULL                   =   0x00
APP_GAME_LENGTH                 =   0x07

; ゲーム／乱数
APP_GAME_RANDOM_NULL            =   0x00

; ゲーム／レベル
APP_GAME_LEVEL_NULL             =   0x00

; ゲーム／経験値
APP_GAME_EXPERIENCE_NULL        =   0x00

; ゲーム／レジスト
APP_GAME_RESIST_NULL            =   0x00

; ゲーム／クリスタル
APP_GAME_CRYSTAL_NULL           =   0x00

; ゲーム／アイテム
APP_GAME_ITEM_NULL              =   0x00

; CRC
APP_CRC_NULL                    =   0x00

; パスワード
APP_PASSWORD_NULL               =   0x00
APP_PASSWORD_LENGTH             =   0x0a
APP_PASSWORD_LETTER_LENGTH      =   0x20

; デバッグ
APP_DEBUG_NULL                  =   0x00
APP_DEBUG_LENGTH                =   0x08

; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppSetGameInitial
    .globl  _AppGetPassword
    .globl  _AppSetPassword
    .globl  _AppClearKeyBuffer
    .globl  _AppGetKey
    .globl  _AppIsHitSpace
    .globl  _AppIsHitEsc
    .globl  _AppUncompressPatternName

; 外部変数宣言
;

    .globl  _app
    