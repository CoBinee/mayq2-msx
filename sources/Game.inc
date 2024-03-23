; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER_BODY         =   0x04
GAME_SPRITE_PLAYER_EDGE         =   0x30
GAME_SPRITE_PLAYER_ITEM         =   0x00
GAME_SPRITE_ENEMY_BODY          =   0x18
GAME_SPRITE_ENEMY_EDGE          =   0x34
GAME_SPRITE_BOSS_BODY           =   0x18
GAME_SPRITE_BOSS_CAST           =   0x2c
GAME_SPRITE_MAGIC               =   0x08
GAME_SPRITE_GATE                =   0x4c

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_FRAME                      =   0x02
GAME_FADE                       =   0x03
GAME_SPRITE_MASK                =   0x04
GAME_SPRITE_GENERATOR_L         =   0x05
GAME_SPRITE_GENERATOR_H         =   0x06
GAME_RANDOM_L                   =   0x07
GAME_RANDOM_H                   =   0x08
GAME_LENGTH                     =   0x09

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_BUILD                =   0x10
GAME_STATE_START                =   0x20
GAME_STATE_FIELD                =   0x30
GAME_STATE_ENTRANCE             =   0x40
GAME_STATE_HOLE                 =   0x50
GAME_STATE_DUNGEON              =   0x60
GAME_STATE_OVER                 =   0x70
GAME_STATE_CLEAR                =   0x80
GAME_STATE_PASSWORD             =   0x90
GAME_STATE_DEBUG                =   0xa0

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_ENTRANCE_BIT          =   0x00
GAME_FLAG_ENTRANCE              =   (1 << GAME_FLAG_ENTRANCE_BIT)
GAME_FLAG_HIT_BIT               =   0x07
GAME_FLAG_HIT                   =   (1 << GAME_FLAG_HIT_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00
GAME_FRAME_BOSS                 =   0x20
GAME_FRAME_OPEN                 =   0x20

; フェード
GAME_FADE_NULL                  =   0x00
GAME_FADE_LENGTH                =   0x10

; スプライトパターン
GAME_SPRITE_PATTERN_PLAYER      =   0xc0
GAME_SPRITE_PATTERN_ENEMY       =   0xc8

; スプライトジェネレータ
GAME_SPRITE_GENERATOR_NULL      =   0x0000
GAME_SPRITE_GENERATOR_OFFSET    =   0x0600
GAME_SPRITE_GENERATOR_PLAYER    =   0x0000
GAME_SPRITE_GENERATOR_ENEMY     =   0x0040
GAME_SPRITE_GENERATOR_LENGTH    =   0x0200

; スプライトマスク
GAME_SPRITE_MASK_NULL           =   0x00
GAME_SPRITE_MASK_LEFT_UP_BIT    =   0x00
GAME_SPRITE_MASK_LEFT_UP        =   (1 << GAME_SPRITE_MASK_LEFT_UP_BIT)
GAME_SPRITE_MASK_LEFT_DOWN_BIT  =   0x01
GAME_SPRITE_MASK_LEFT_DOWN      =   (1 << GAME_SPRITE_MASK_LEFT_DOWN_BIT)
GAME_SPRITE_MASK_RIGHT_UP_BIT   =   0x02
GAME_SPRITE_MASK_RIGHT_UP       =   (1 << GAME_SPRITE_MASK_RIGHT_UP_BIT)
GAME_SPRITE_MASK_RIGHT_DOWN_BIT =   0x03
GAME_SPRITE_MASK_RIGHT_DOWN     =   (1 << GAME_SPRITE_MASK_RIGHT_DOWN_BIT)

; 乱数
GAME_RANDOM_NULL                =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameGetSpriteMask
    .globl  _GameMakeSpriteGenerator

; 外部変数宣言
;

    .globl  _game
    .globl  _gameSpriteGenerator
