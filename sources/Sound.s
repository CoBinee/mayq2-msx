; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmIntro0, soundNull, soundNull
    .dw     soundBgmTitle0, soundBgmTitle1, soundBgmTitle2
    .dw     soundBgmStart0, soundBgmStart1, soundBgmStart2
    .dw     soundBgmField0, soundBgmField1, soundBgmField2
    .dw     soundBgmDungeon0, soundBgmDungeon1, soundBgmDungeon2
    .dw     soundBgmMiss0, soundNull, soundNull
    .dw     soundBgmOver0, soundBgmOver1, soundBgmOver2
    .dw     soundBgmKill0, soundNull, soundNull
    .dw     soundBgmClear0, soundBgmClear1, soundBgmClear2

; 導入
soundBgmIntro0:

    .ascii  "T2@0V16S4M5N7X5X5X5X5X5X5X5X5"
    .db     0xff

; タイトル
soundBgmTitle0:

    .ascii  "T3@7V15,4"
    .ascii  "L3O4E4F1GO5C7RO4D4E1F8G4A1BO5F7RO4A4B1O5C5D5E5"
    .ascii  "L3O4E4F1GO5C7RD4E1F8O4G4G1O5E5D4O4G1O5E5D4O4G1O5E5D4O4G1O5ED"
    .db     0xff

soundBgmTitle1:

    .ascii  "T3@3V13,3"
    .ascii  "L3O3R5CRRG1G1GRR5CRRG1G1G1G1GR5CRRG1G1GRR5CRRG1G1G1G1G"
    .ascii  "L3O3R5CRRG1G1GRR5D-RRA-1A-1A-1A-1AR5R5GRR5GRR5GRRG"
    .db     0xff

soundBgmTitle2:

    .ascii  "T3@3V13,3"
    .ascii  "L3O3R5RRRE1E1ERR5RRRF1F1F1F1FR5RRRF1F1FRR5RRRE1E1E1E1E"
    .ascii  "L3O3R5RRRE1E1ERR5RRRF1F1F1F1FR5O5C5O4G4R1O5C5O4G4R1O5C5O4G4R1O5CR"
    .db     0xff

; スタート
soundBgmStart0:

    .ascii  "T3@11V15,5"
    .ascii  "L7O5DF+EA"
    .ascii  "L7O5F+D3E3F+5EO4A6R3"
;   .ascii  "L7O5F+D3E3F+5EO4A"
    .db     0x00

soundBgmStart1:

    .ascii  "T3@3V13,5"
    .ascii  "L5O4DDF+F+EEAA"
    .ascii  "L5O4F+F+DDEEC+C+4"
;   .ascii  "L5O4F+F+DDEEC+C+"
;   .ascii  "T3V16S0N2"
;   .ascii  "L5M4XX3X3XXXX3X3XX"
;   .ascii  "L5M4XX3X3XXXX3X3XX"
    .db     0x00

soundBgmStart2:

    .ascii  "T3@3V13,5"
    .ascii  "L7O4F+O5DO4AO5C+"
    .ascii  "L7O4BF+AC+6R3"
;   .ascii  "L7O4BF+AC+"
    .db     0x00

; フィールド
soundBgmField0:

    .ascii  "T3@15V15,4"
    .ascii  "L3O5E"
    .ascii  "L3O5F+8AE9R"
    .ascii  "L3R7O5DO4BO5DF+5E5D5E5E"
    .ascii  "L3O5F+8AE9R"
    .ascii  "L3R7O5DO4BO5DF+5E5D5E5R"
    .ascii  "L3O5G8F+GAG5F+5E5D"
    .ascii  "L3O5D7DO4BO5DE7O4B7R"
    .ascii  "L3O5G6F+6G5AG5F+5E5D7RDO4BO5DE9R"
    .ascii  "L3R8R"
    .db     0xff

soundBgmField1:

    .ascii  "T3V16S0N2"
    .ascii  "L3R"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L3M3XXXXXXM5XM3XM3XXXXXXM5XM3XL3M3XXXXXXM5XM3XM3XXXXXXM5XM3X"
    .ascii  "L1M5X5X5XXXRXX"
    .db     0xff

soundBgmField2:

    .ascii  "T3@2V14,3"
    .ascii  "L3R"
    .ascii  "L3O4DF+AF+DF+AF+O3AO4C+EC+O3AO4C+EC+"
    .ascii  "L3O3BO4DF+DO3BO4DF+DO3AO4C+EC+O3AO4C+EC+"
    .ascii  "L3O4DF+AF+DF+AF+O3AO4C+EC+O3AO4C+EC+"
    .ascii  "L3O3BO4DF+DO3BO4DF+DO3AO4C+EC+O3AO4C+EC+"
    .ascii  "L3O4EGBGEGBGO4C+F+AF+C+F+AF+"
    .ascii  "L3O4DF+AF+DF+AF+O3BO4EGEO3BO4EGE"
    .ascii  "L3O4EGBGEGBEC+F+AF+C+F+AF+DGBGDGBGC+EAEC+EAE"
    .ascii  "C+EAEC+EA"
    .db     0xff

; ダンジョン
soundBgmDungeon0:

    .ascii  "T4@7V15,3"
    .ascii  "L3O5CCC1O4B-1G1O5C4CC1O4B-1G1O5C4CC1O4B-1G1O5C4CDD"
    .ascii  "L3O5CCC1O4B-1G1O5C4CC1O4B-1G1O5C4CC1O4B-1G1O5C4CDD"
    .ascii  "L3O5E-E-E-1D1C1E-4E-E-1D1C1E-4E-E-1D1C1E-4E-FF"
    .ascii  "L3O5E-E-E-1D1C1E-4E-E-1D1C1E-4E-E-1D1C1E-4E-FF"
    .db     0xff

soundBgmDungeon1:

    .ascii  "T4@15V15,1"
    .ascii  "L1O2CCO3CO2CCCO3CO2CDDB-DDDB-DCCA-CCCA-CFFO3FO2FGGO3GO2G"
    .ascii  "L1O2CCO3CO2CCCO3CO2CDDB-DDDB-DCCA-CCCA-CFFO3FO2FGGO3GO2G"
    .ascii  "L1O2CCO3CO2CCCO3CO2CDDB-DDDB-DCCA-CCCA-CFFO3FO2FGGO3GO2G"
    .ascii  "L1O2CCO3CO2CCCO3CO2CDDB-DDDB-DCCA-CCCA-CFFO3FO2FGGO3GO2G"
    .db     0xff

soundBgmDungeon2:

    .ascii  "T4@7V13,3"
    .ascii  "L3O4GGG1F1D1G4GG1F1D1G4GG1F1D1A-4A-B-B-"
    .ascii  "L3O4GGG1F1D1G4GG1F1D1G4GG1F1D1A-4A-B-B-"
    .ascii  "L3O5CCC1O4B-1G1O5C4CC1O4B-1G1O5C4CC1O4B-1G1O5C4CDD"
    .ascii  "L3O5CCC1O4B-1G1O5C4CC1O4B-1G1O5C4CC1O4B-1G1O5C4CDD"
    .db     0xff

; ミス
soundBgmMiss0:

    .ascii  "T1@0V15"
    .ascii  "L4O6ER2CR2ER2CR2ER2CR2ER2CR2"
    .ascii  "L4O6CEGEC"
    .db     0x00

; ゲームオーバー
soundBgmOver0:

    .ascii  "T4@14V15,9L9"
    .ascii  "O4ADDR"
    .db     0x00

soundBgmOver1:

    .ascii  "T4@14V15,9L9"
    .ascii  "O4DO3BBR"
    .db     0x00

soundBgmOver2:

    .ascii  "T4@14V15,9L9"
    .ascii  "O3GDO2AR"
    .db     0x00

; キル
soundBgmKill0:

    .ascii  "T1@0V13L0O1C+CC+CC+CC+CC+CC+CC+CC+CC+CC+CC+CC+CC+CC+CC+CC+C"
    .db     0xff

; クリア
soundBgmClear0:

    .ascii  "T3@5V15,4"
    .ascii  "L3O4D5A5A5AB-GEDCD5E5D5A5A5AB-O5CO4B-AGA5R5"
    .ascii  "L3O4D5A5A5AB-O5CO4AGFG5O5C5DCO4B-O5CEDE5D9"
    .db     0xff

soundBgmClear1:

    .ascii  "T3@6V13,6"
    .ascii  "L9O4AGAO5C5C5O4A7"
    .ascii  "L9O4AO5CO4F7G7A"
    .db     0xff

soundBgmClear2:

    .ascii  "T3@6V13,6"
    .ascii  "L9O4DCDF+5D5C+7"
    .ascii  "L9O4DFO3B-7O4C7D"
    .db     0xff

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeHit
    .dw     soundSeCast
    .dw     soundSeDamage
    .dw     soundSePath
    .dw     soundSeItem

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; ヒット
soundSeHit:

    .ascii  "T1@0V13L0O4G+O5CO4EG+CG+"
    .db     0x00

; キャスト
soundSeCast:

    .ascii  "T1@0V13L0O4BB-AA+V12BB-AA+V11BB-AA+V10BB-AA+"
    .db     0x00

; ダメージ
soundSeDamage:

    .ascii  "T1@0L0O2V13EV12EV11EV10E"
    .db     0x00

; 通り道
soundSePath:

    .ascii  "T1@0L1O2V13CV12CV11CV10C"
    .db     0x00

; アイテム
soundSeItem:

    .ascii  "T1@0V13L3O5EE-G-FA"
    .db 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
