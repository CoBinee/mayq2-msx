; Field.inc : フィールド
;


; マクロの定義
;

; フィールド
FIELD_STATE                     =   0x00
FIELD_FLAG                      =   0x01
FIELD_RANDOM_L                  =   0x02
FIELD_RANDOM_H                  =   0x03
FIELD_HOLE_L                    =   0x04
FIELD_HOLE_H                    =   0x05
FIELD_HOLE_X                    =   0x06
FIELD_HOLE_Y                    =   0x07
FIELD_ENTRANCE_X                =   0x08
FIELD_ENTRANCE_Y                =   0x09
FIELD_PATH_COUNT                =   0x0a
FIELD_PATH_FRAME                =   0x0b
FIELD_CRYSTAL_RED_L             =   0x0c
FIELD_CRYSTAL_RED_H             =   0x0d
FIELD_CRYSTAL_GREEN_L           =   0x0e
FIELD_CRYSTAL_GREEN_H           =   0x0f
FIELD_CRYSTAL_BLUE_L            =   0x10
FIELD_CRYSTAL_BLUE_H            =   0x11
FIELD_CRYSTAL_YELLOW_L          =   0x12
FIELD_CRYSTAL_YELLOW_H          =   0x13
FIELD_CRYSTAL_WHITE_L           =   0x14
FIELD_CRYSTAL_WHITE_H           =   0x15
FIELD_KEY_L                     =   0x16
FIELD_KEY_H                     =   0x17
FIELD_RING_L                    =   0x18
FIELD_RING_H                    =   0x19
FIELD_ROD_L                     =   0x1a
FIELD_ROD_H                     =   0x1b
FIELD_NECKLACE_L                =   0x1c
FIELD_NECKLACE_H                =   0x1d
FIELD_CANDLE_L                  =   0x1e
FIELD_CANDLE_H                  =   0x1f
FIELD_LENGTH                    =   0x20

; 状態
FIELD_STATE_NULL                =   0x00

; フラグ
FIELD_FLAG_NULL                 =   0x00
FIELD_FLAG_SCROLL_UP_BIT        =   0x00
FIELD_FLAG_SCROLL_UP            =   (1 << FIELD_FLAG_SCROLL_UP_BIT)
FIELD_FLAG_SCROLL_DOWN_BIT      =   0x01
FIELD_FLAG_SCROLL_DOWN          =   (1 << FIELD_FLAG_SCROLL_DOWN_BIT)
FIELD_FLAG_SCROLL_LEFT_BIT      =   0x02
FIELD_FLAG_SCROLL_LEFT          =   (1 << FIELD_FLAG_SCROLL_LEFT_BIT)
FIELD_FLAG_SCROLL_RIGHT_BIT     =   0x03
FIELD_FLAG_SCROLL_RIGHT         =   (1 << FIELD_FLAG_SCROLL_RIGHT_BIT)
FIELD_FLAG_VIEW_BIT             =   0x04
FIELD_FLAG_VIEW                 =   (1 << FIELD_FLAG_VIEW_BIT)
FIELD_FLAG_KEY_BIT              =   0x06
FIELD_FLAG_KEY                  =   (1 << FIELD_FLAG_KEY_BIT)
FIELD_FLAG_ERROR_BIT            =   0x07
FIELD_FLAG_ERROR                =   (1 << FIELD_FLAG_ERROR_BIT)

; 乱数
FIELD_RANDOM_NULL               =   0x00

; 穴
FIELD_HOLE_NULL                 =   0x00

; 入り口
FIELD_ENTRANCE_NULL             =   0x00

; 通り道
FIELD_PATH_COUNT_NULL           =   0x00
FIELD_PATH_COUNT_LENGTH         =   0x03
FIELD_PATH_FRAME_NULL           =   0x00
FIELD_PATH_FRAME_LENGTH         =   0x10

; アイテム
FIELD_ITEM_NULL                 =   0x00

; 種類
FIELD_TYPE_NULL                 =   0x00
FIELD_TYPE_MASK                 =   0xf0
FIELD_TYPE_GRASS                =   0x00
FIELD_TYPE_DESERT               =   0x10
FIELD_TYPE_MARSH                =   0x20
FIELD_TYPE_FOREST               =   0x30
FIELD_TYPE_BRICK                =   0x40
FIELD_TYPE_HOLE                 =   0x50
FIELD_TYPE_WATER                =   0x60
FIELD_TYPE_STONE                =   0x70
FIELD_TYPE_CACTUS               =   0x80
FIELD_TYPE_DEADTREE             =   0x90
FIELD_TYPE_TREE                 =   0xa0
FIELD_TYPE_BOX                  =   0xb0

; パターン
FIELD_PATTERN_NULL              =   0x00
FIELD_PATTERN_MASK              =   0x0f
FIELD_PATTERN_UP_BIT            =   0x00
FIELD_PATTERN_UP                =   (1 << FIELD_PATTERN_UP_BIT)
FIELD_PATTERN_DOWN_BIT          =   0x01
FIELD_PATTERN_DOWN              =   (1 << FIELD_PATTERN_DOWN_BIT)
FIELD_PATTERN_LEFT_BIT          =   0x02
FIELD_PATTERN_LEFT              =   (1 << FIELD_PATTERN_LEFT_BIT)
FIELD_PATTERN_RIGHT_BIT         =   0x03
FIELD_PATTERN_RIGHT             =   (1 << FIELD_PATTERN_RIGHT_BIT)

; イベント
FIELD_EVENT_NULL                =   0x00
FIELD_EVENT_MASK                =   0x07
FIELD_EVENT_START               =   0x01
FIELD_EVENT_CRYSTAL             =   0x02
FIELD_EVENT_BOX                 =   0x03

; エネミー
FIELD_ENEMY_NULL                =   0x00
FIELD_ENEMY_HIGH_BIT            =   0x03
FIELD_ENEMY_HIGH                =   0x08

; 大きさ
FIELD_SIZE_X                    =   0x80
FIELD_SIZE_Y                    =   0x80

; セル
FIELD_CELL_SIZE_X               =   0x40
FIELD_CELL_SIZE_Y               =   0x40

; ネーム
FIELD_NAME_SIZE_X               =   0x02
FIELD_NAME_SIZE_Y               =   0x02

; エリア
FIELD_AREA_NULL                 =   0x00
FIELD_AREA_SIZE_X               =   0x08
FIELD_AREA_SIZE_Y               =   0x08
FIELD_AREA_CELL_SIZE_X          =   0x08
FIELD_AREA_CELL_SIZE_Y          =   0x08

; 外部関数宣言
;

    .globl  _FieldInitialize
    .globl  _FieldUpdate
    .globl  _FieldRender
    .globl  _FieldBuild
    .globl  _FieldIsError
    .globl  _FieldSetKey
    .globl  _FieldGetArea
    .globl  _FieldGetStartPosition
    .globl  _FieldGetFarPosition
    .globl  _FieldIsCollision
    .globl  _FieldIsLayerUpper
    .globl  _FieldIsHole
    .globl  _FieldIsEntrance
    .globl  _FieldIsRest
    .globl  _FieldIsPath
    .globl  _FieldMoveUp
    .globl  _FieldMoveDown
    .globl  _FieldMoveLeft
    .globl  _FieldMoveRight
    .globl  _FieldCorrectUp
    .globl  _FieldCorrectDown
    .globl  _FieldCorrectLeft
    .globl  _FieldCorrectRight
    .globl  _FieldView
    .globl  _FieldScrollUp
    .globl  _FieldScrollDown
    .globl  _FieldScrollLeft
    .globl  _FieldScrollRight
    .globl  _FieldPrintMap

; 外部変数宣言
;

    .globl  _field
