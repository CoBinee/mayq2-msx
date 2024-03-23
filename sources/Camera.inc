; Camera.inc : カメラ
;


; マクロの定義
;

; カメラ
CAMERA_STATE                    =   0x00
CAMERA_FLAG                     =   0x01
CAMERA_POSITION_X               =   0x02
CAMERA_POSITION_Y               =   0x03
CAMERA_LENGTH                   =   0x04

; 状態
CAMERA_STATE_NULL               =   0x00

; フラグ
CAMERA_FLAG_NULL                =   0x00
CAMERA_FLAG_SCROLL_BIT          =   0x00
CAMERA_FLAG_SCROLL              =   (1 << CAMERA_FLAG_SCROLL_BIT)

; 位置
CAMERA_POSITION_NULL            =   0x00

; 視野
CAMERA_VIEW_SIZE_X              =   0x16
CAMERA_VIEW_SIZE_Y              =   0x16
CAMERA_VIEW_SPRITE_X            =   0x08
CAMERA_VIEW_SPRITE_Y            =   0x08
CAMERA_VIEW_PATTERN_NAME_X      =   0x01
CAMERA_VIEW_PATTERN_NAME_Y      =   0x01
CAMERA_VIEW_PATTERN_NAME_OFFSET =   0x0021

; 外部関数宣言
;

    .globl  _CameraInitialize
    .globl  _CameraUpdate
    .globl  _CameraRender

; 外部変数宣言
;

    .globl  _camera
