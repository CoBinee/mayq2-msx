; Title.inc : タイトル
;


; マクロの定義
;

; スプライト
TITLE_SPRITE_NULL               =   0x00
TITLE_SPRITE_LOGO               =   0x00
TITLE_SPRITE_EYE                =   0x28

; タイトル
TITLE_STATE                     =   0x00
TITLE_FLAG                      =   0x01
TITLE_FRAME                     =   0x02
TITLE_BLINK                     =   0x03
TITLE_EYE                       =   0x04
TITLE_PASSWORD_0                =   0x05
TITLE_PASSWORD_1                =   0x06
TITLE_PASSWORD_2                =   0x07
TITLE_PASSWORD_3                =   0x08
TITLE_PASSWORD_4                =   0x09
TITLE_PASSWORD_5                =   0x0a
TITLE_PASSWORD_6                =   0x0b
TITLE_PASSWORD_7                =   0x0c
TITLE_PASSWORD_8                =   0x0d
TITLE_PASSWORD_9                =   0x0e
TITLE_CURSOR                    =   0x0f
TITLE_LENGTH                    =   0x10

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_INTRO               =   0x10
TITLE_STATE_LOOP                =   0x20
TITLE_STATE_START               =   0x30
TITLE_STATE_PASSWORD            =   0x40

; フラグ
TITLE_FLAG_NULL                 =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; 点滅
TITLE_BLINK_NULL                =   0x00
TITLE_BLINK_CYCLE               =   0x10

; 目
TITLE_EYE_NULL                  =   0x00
TITLE_EYE_LENGTH                =   0x20

; パスワード
TITLE_PASSWORD_NULL             =   0x00
TITLE_PASSWORD_LETTER_DEFAULT   =   0x2a

; カーソル
TITLE_CURSOR_NULL               =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title
