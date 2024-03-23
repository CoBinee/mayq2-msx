; Sound.inc : サウンド
;


; マクロの定義
;

; BGM
SOUND_BGM_NULL                  =   0x00
SOUND_BGM_INTRO                 =   0x01
SOUND_BGM_TITLE                 =   0x02
SOUND_BGM_START                 =   0x03
SOUND_BGM_FIELD                 =   0x04
SOUND_BGM_DUNGEON               =   0x05
SOUND_BGM_MISS                  =   0x06
SOUND_BGM_OVER                  =   0x07
SOUND_BGM_KILL                  =   0x08
SOUND_BGM_CLEAR                 =   0x09

; SE
SOUND_SE_NULL                   =   0x00
SOUND_SE_BOOT                   =   0x01
SOUND_SE_CLICK                  =   0x02
SOUND_SE_HIT                    =   0x03
SOUND_SE_CAST                   =   0x04
SOUND_SE_DAMAGE                 =   0x05
SOUND_SE_PATH                   =   0x06
SOUND_SE_ITEM                   =   0x07

; 外部関数宣言
;

    .globl  _SoundPlayBgm
    .globl  _SoundPlaySe
    .globl  _SoundStop
    .globl  _SoundIsPlayBgm
    .globl  _SoundIsPlaySe

; 外部変数宣言
;
