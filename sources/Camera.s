; Camera.s : カメラ
;


; モジュール宣言
;
    .module Camera

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include	"Camera.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; カメラを初期化する
;
_CameraInitialize::
    
    ; レジスタの保存
    
    ; カメラの初期化
    ld      hl, #cameraDefault
    ld      de, #_camera
    ld      bc, #CAMERA_LENGTH
    ldir

    ; 状態の設定
    ld      a, #CAMERA_STATE_NULL
    ld      (_camera + CAMERA_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; カメラを更新する
;
_CameraUpdate::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; カメラを描画する
;
_CameraRender::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; カメラの初期値
;
cameraDefault:

    .db     CAMERA_STATE_NULL
    .db     CAMERA_FLAG_NULL
    .db     CAMERA_POSITION_NULL
    .db     CAMERA_POSITION_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; カメラ
;
_camera::
    
    .ds     CAMERA_LENGTH
