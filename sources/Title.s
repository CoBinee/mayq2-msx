; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

;   ; パターンネームのクリア
;   xor     a
;   call    _SystemClearPatternName

    ; タイトル画面の描画
    call    TitlePrintScreen

    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir
    
    ; スプライトジェネレータの設定
    ld      a, #(APP_SPRITE_GENERATOR_TABLE >> 11)
    ld      (_videoRegister + VDP_R6), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0040) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; サウンドの停止
    call    _SoundStop

    ; 状態の設定
    ld      a, #TITLE_STATE_INTRO
    ld      (_title + TITLE_STATE), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_title + TITLE_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルの導入を開始する
;
TitleIntro:

    ; レジスタの保存

    ; 初期化
00$:
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; キーバッファのクリア
    call    _AppClearKeyBuffer

    ; フレームの設定
    ld      a, #0x30
    ld      (_title + TITLE_FRAME), a

    ; 導入の描画
    call    TitlePrintIntro

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; 状態の取得
    ld      a, (_title + TITLE_STATE)
    and     #0x0f

    ; 目の更新と描画
    cp      #0x02
    jr      c, 10$
    push    af
    call    TitleUpdateEye
    call    TitlePrintEye
    pop     af

    ; 0x01 : But...
10$:
    dec     a
    jr      nz, 20$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 90$

    ; 目の設定
    xor     a
    ld      (_title + TITLE_EYE), a

    ; BGM の再生
    ld      a, #SOUND_BGM_INTRO
    call    _SoundPlayBgm

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
    jr      90$

    ; 0x02 : 目
20$:
    dec     a
    jr      nz, 30$

    ; 導入の消去
    ld      a, (_title + TITLE_EYE)
    cp      #(TITLE_EYE_LENGTH / 2)
    call    z, TitleEraseIntro

    ; 目の監視
    ld      hl, #(_title + TITLE_EYE)
    ld      a, (hl)
    cp      #TITLE_EYE_LENGTH
    jr      c, 90$
    ld      (hl), #0x00

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
    jr      90$

    ; 0x03 : シャドウ
30$:
    dec     a
    jr      nz, 40$

    ; シャドウの描画
    ld      a, (_title + TITLE_EYE)
    cp      #(TITLE_EYE_LENGTH / 2)
    call    z, TitlePrintShadow

    ; 目の監視
    ld      hl, #(_title + TITLE_EYE)
    ld      a, (hl)
    cp      #TITLE_EYE_LENGTH
    jr      c, 90$
    ld      (hl), #0x00

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
    jr      90$

    ; 0x04 : ロゴ
40$:
    dec     a
    jr      nz, 90$

    ; 目の監視
    ld      a, (_title + TITLE_EYE)
    cp      #(TITLE_EYE_LENGTH / 2)
    jr      c, 90$

    ; 状態の更新
    ld      a, #TITLE_STATE_LOOP
    ld      (_title + TITLE_STATE), a
;   jr      90$

    ; 導入の完了
90$:

    ; SPACE キーの入力
    call    _AppIsHitSpace
    jr      nc, 91$

;   ; SE の再生
;   ld      a, #SOUND_SE_CLICK
;   call    _SoundPlaySe

    ; 状態の更新
    ld      a, #TITLE_STATE_LOOP
    ld      (_title + TITLE_STATE), a
;   jr      91$
91$:

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleLoop:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; キーバッファのクリア
    call    _AppClearKeyBuffer

    ; 点滅の設定
    xor     a
    ld      (_title + TITLE_BLINK), a

    ; ロゴのパターンネームの描画
    call    TitlePrintLogoPatternName

    ; OPLL の描画
    call    TitlePrintOpll

    ; BGM の再生
    ld      a, #SOUND_BGM_TITLE
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      z, 10$
    call    _AppGetKey
    jr      nc, 19$
    cp      #0x20
    jr      z, 10$
    cp      #0x1b
    jr      z, 11$
    jr      19$

    ; SPACE キーの入力
10$:

    ; サウンドの停止
    call    _SoundStop

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 状態の設定
    ld      a, #TITLE_STATE_START
    ld      (_title + TITLE_STATE), a
    jr      19$

    ; ESC キーの入力
11$:

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の設定
    ld      a, #TITLE_STATE_PASSWORD
    ld      (_title + TITLE_STATE), a
;   jr      19$
19$:

    ; 目の更新
    call    TitleUpdateEye

    ; 点滅の更新
    ld      hl, #(_title + TITLE_BLINK)
    inc     (hl)

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; 目の描画
    call    TitlePrintEye

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
TitleStart:

    ; レジスタの保存

    ; 初期化
00$:
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    xor     a
    ld      (_title + TITLE_BLINK), a

    ; フレームの設定
    ld      a, #0x20
    ld      (_title + TITLE_FRAME), a

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; 目の更新
    call    TitleUpdateEye

    ; 点滅の更新
    ld      hl, #(_title + TITLE_BLINK)
    ld      a, (hl)
    add     a, #TITLE_BLINK_CYCLE
    and     #(TITLE_BLINK_CYCLE * 0x02 - 0x01)
    ld      (hl), a

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; 目の描画
    call    TitlePrintEye

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; ゲームの初期状態の設定
    call    _AppSetGameInitial

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; パスワードを入力する
;
TitlePassword:

    ; レジスタの保存

    ; 初期化
00$:
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    ld      a, #TITLE_BLINK_CYCLE
    ld      (_title + TITLE_BLINK), a

    ; フレームの設定
    ld      a, #0x20
    ld      (_title + TITLE_FRAME), a

    ; パスワードの初期化
    ld      hl, #(_title + TITLE_PASSWORD_0 + 0x0000)
    ld      de, #(_title + TITLE_PASSWORD_0 + 0x0001)
    ld      bc, #(APP_PASSWORD_LENGTH - 0x0001)
    ld      (hl), #TITLE_PASSWORD_LETTER_DEFAULT
    ldir

    ; カーソルの初期化
    xor     a
    ld      (_title + TITLE_CURSOR), a

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; 0x01 : パスワードの入力
100$:
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    dec     a
    jp      nz, 20$

    ; キー入力の監視
    ld      a, (_title + TITLE_CURSOR)
    ld      c, a
    ld      b, #0x00
    ld      hl, #(_title + TITLE_PASSWORD_0)
    add     hl, bc
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      z, 130$
    ld      a, (_input + INPUT_KEY_LEFT)
    dec     a
    jr      z, 113$
    ld      a, (_input + INPUT_KEY_RIGHT)
    dec     a
    jr      z, 114$
110$:
    call    _AppGetKey
    jr      nc, 190$
    cp      #0x1b
    jr      z, 120$
    cp      #0x0d
    jr      z, 130$
    cp      #0x1d
    jr      z, 113$
    cp      #0x1c
    jr      z, 114$
    cp      #0x30
    jr      c, 110$
    cp      #0x3a
    jr      c, 112$
    cp      #0x41
    jr      c, 110$
    cp      #0x5b
    jr      c, 112$
    cp      #0x61
    jr      c, 110$
    cp      #0x7b
    jr      c, 111$
    jr      110$

    ; 文字の入力
111$:
    sub     #0x20
112$:
    ld      (hl), a
    ld      a, c
    cp      #(APP_PASSWORD_LENGTH - 0x01)
    jr      nc, 110$
    inc     c
    inc     hl
    jr      110$

    ; ←
113$:
    ld      a, c
    or      a
    jr      z, 110$
    dec     c
    dec     hl
    jr      190$

    ; →
114$:
    ld      a, c
    cp      #(APP_PASSWORD_LENGTH - 0x01)
    jr      nc, 110$
    inc     c
    inc     hl
    jr      190$

    ; タイトルに戻る
120$:

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #TITLE_STATE_LOOP
    ld      (_title + TITLE_STATE), a
    jr      190$

    ; 決定
130$:

    ; パスワードの設定
    ld      hl, #(_title + TITLE_PASSWORD_0)
    call    _AppSetPassword
    jr      c, 131$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #(TITLE_STATE_PASSWORD + 0x02)
    ld      (_title + TITLE_STATE), a
    jr      190$

    ; サウンドの停止
131$:
    call    _SoundStop

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #(TITLE_STATE_PASSWORD + 0x03)
    ld      (_title + TITLE_STATE), a
;   jr      190$

    ; キー入力の完了
190$:
    call    _AppClearKeyBuffer

    ; カーソルの保存
    ld      a, c
    ld      (_title + TITLE_CURSOR), a

    ; パスワードの描画
    call    TitlePrintPassword
    jr      90$

    ; 0x02 : エラー
20$:
    dec     a
    jr      nz, 30$

    ; キー入力の監視
    call    _AppGetKey
    jr      nc, 29$

    ; 状態の更新
    ld      a, #(TITLE_STATE_PASSWORD + 0x01)
    ld      (_title + TITLE_STATE), a
;   jr      29$

    ; エラーの完了
29$:

    ; エラーの描画
    call    TitlePrintError
    jr      90$

    ; 0x03 : コンティニュー
30$:
;   dec     a
;   jr      nz, 90$

    ; 点滅の更新
    ld      hl, #(_title + TITLE_BLINK)
    ld      a, (hl)
    add     a, #TITLE_BLINK_CYCLE
    ld      (hl), a

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 39$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      39$

    ; コンティニューの完了
39$:

    ; パスワードの描画
    call    TitlePrintPassword
;   jr      90$

    ; 処理の完了
90$:

    ; 目の更新
    call    TitleUpdateEye

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; 目の描画
    call    TitlePrintEye

    ; レジスタの復帰

    ; 終了
    ret

; 目を更新する
;
TitleUpdateEye:

    ; レジスタの保存

    ; 目の更新
    ld      hl, #(_title + TITLE_EYE)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; タイトル画面を描画する
;
TitlePrintScreen:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleScreenPatternName
    ld      de, #_patternName
    call    _AppUncompressPatternName

    ; レジスタの復帰

    ; 終了
    ret

; 導入を描画する
;
TitlePrintIntro:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleIntroPatternName
    ld      de, #(_patternName + 0x0162)
    ld      bc, #0x001d
    ldir

    ; レジスタの復帰

    ; 終了
    ret

TitleEraseIntro:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #(_patternName + 0x0162)
    ld      de, #(_patternName + 0x0163)
    ld      bc, #(0x001d - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; シャドウを描画する
;
TitlePrintShadow:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleShadowPatternName
    ld      de, #(_patternName + 0x0080)
    call    _AppUncompressPatternName

    ; レジスタの復帰

    ; 終了
    ret

; ロゴを描画する
;
TitlePrintLogoPatternName:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleLogoPatternName
    ld      de, #(_patternName + 0x0080)
    call    _AppUncompressPatternName

    ; レジスタの復帰

    ; 終了
    ret

TitlePrintLogoSprite:

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #titleLogoSprite
    ld      de, #(_sprite + TITLE_SPRITE_LOGO)
    ld      bc, #(0x000a * 0x0004)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 目を描画する
;
TitlePrintEye:

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_title + TITLE_EYE)
    and     #0x1c
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleEyeSprite
    add     hl, de
    ld      de, #(_sprite + TITLE_SPRITE_EYE)
    ld      bc, #0x0004
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を描画する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; 告知領域の消去
    call    TitleEraseAnnounce

    ; パターンネームの描画
    ld      a, (_title + TITLE_BLINK)
    bit     #0x04, a
    jr      z, 19$
    rrca
    and     #0x10
    ld      e, a
    rrca
    rrca
    rrca
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleHitSpaceBarPatternName
    add     hl, de
    ld      de, #(_patternName + 0x0227)
    ld      bc, #0x0012
    ldir
19$:

    ; レジスタの復帰

    ; 終了
    ret

; OPLL を描画する
;
TitlePrintOpll:

    ; レジスタの保存

    ; パターンネームの描画
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 10$
    ld      hl, #titleOpllPatternName
    ld      de, #(_patternName + 0x282)
    ld      bc, #0x0002
    ldir
    ld      de, #(_patternName + 0x2a2)
    ld      bc, #0x0002
    ldir
10$:

    ; レジスタの復帰

    ; 終了
    ret

; パスワードを描画する
;
TitlePrintPassword:

    ; レジスタの保存

    ; 告知領域の消去
    call    TitleEraseAnnounce

    ; INPUT PASSWORD の描画
    ld      hl, #titlePasswordPatternName
    ld      de, #(_patternName + 0x0209)
    ld      bc, #0x000e
    ldir

    ; パスワードの描画
    ld      a, (_title + TITLE_BLINK)
    bit     #0x04, a
    jr      z, 19$
    ld      hl, #(_title + TITLE_PASSWORD_0)
    ld      de, #(_patternName + 0x024b)
    ld      b, #APP_PASSWORD_LENGTH
10$:
    ld      a, (hl)
    sub     #0x20
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
19$:

    ; カーソルの描画
    ld      hl, #(_patternName + 0x026b)
    ld      a, (_title + TITLE_CURSOR)
    ld      c, a
    xor     a
20$:
    push    af
    cp      c
    ld      a, #0xe8
    jr      z, 21$
    inc     a
21$:
    ld      (hl), a
    inc     hl
    pop     af
    inc     a
    cp      #APP_PASSWORD_LENGTH
    jr      c, 20$

    ; レジスタの復帰

    ; 終了
    ret

; エラーを描画する
;
TitlePrintError:

    ; レジスタの保存

    ; 告知領域の消去
    call    TitleEraseAnnounce

    ; エラーの描画
    ld      hl, #titleErrorPatternName
    ld      de, #(_patternName + 0x0227)
    ld      bc, #0x0012
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 告知領域を消去する
;
TitleEraseAnnounce:

    ; レジスタの保存

    ; HIT SPACE やパスワード入力領域の消去
    ld      hl, #(_patternName + 0x0200)
    ld      de, #(_patternName + 0x0201)
    ld      bc, #(0x0080 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitleIntro
    .dw     TitleLoop
    .dw     TitleStart
    .dw     TitlePassword

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .db     TITLE_FRAME_NULL
    .db     TITLE_BLINK_NULL
    .db     TITLE_EYE_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_PASSWORD_NULL
    .db     TITLE_CURSOR_NULL

; スクリーン
;
titleScreenPatternName:

    .db     0x50, 0x40, 0x41, 0x00, 0x1a,                                     0x42, 0x43, 0x51
    .db     0x48,             0x00, 0x1e,                                                 0x4a
    .db     0x49,             0x00, 0x1e,                                                 0x4b
    .db     0x00, 0x40
    .db     0x00, 0x00
    .db     0x00, 0x00
    .db     0x4d,             0x00, 0x1e,                                                 0x4f
    .db     0x4c,             0x00, 0x1e,                                                 0x4e
    .db     0x52, 0x44, 0x45, 0x00, 0x1a,                                     0x46, 0x47, 0x53
    .db     0xff

; 導入
;
titleIntroPatternName:

    .db     0x39, 0x2f, 0x35, 0x00, 0x32, 0x25, 0x34, 0x35, 0x32, 0x2e, 0x25, 0x24, 0x00, 0x26, 0x32, 0x2f, 0x2d, 0x00, 0x8c, 0x8d, 0x8e, 0x8f, 0x0c, 0x22, 0x35, 0x34, 0x0e, 0x0e, 0x0e

; シャドウ
;
titleShadowPatternName:

    .db     0x00, 0x0e,                   0x60, 0x61, 0x62, 0x63,                   0x00, 0x0e
    .db     0x00, 0x0e,                   0x64, 0x65, 0x66, 0x67,                   0x00, 0x0e
    .db     0x00, 0x0e,                   0x68, 0x69, 0x6a, 0x6b,                   0x00, 0x0e
    .db     0x00, 0x0d,             0x6c, 0x6d, 0x00, 0x02, 0x6e, 0x6f,             0x00, 0x0d
    .db     0x00, 0x0c,       0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,       0x00, 0x0c
    .db     0x00, 0x0c, 0x78, 0x79, 0x00, 0x01, 0x7a, 0x7b, 0x00, 0x01, 0x7c, 0x7d, 0x00, 0x0c
    .db     0x00, 0x0f,                         0x7e, 0x7f,                         0x00, 0x0f
    .db     0x00, 0x0f,                         0x58, 0x59,                         0x00, 0x0f
    .db     0xff

; ロゴ
;
titleLogoPatternName:

    .db     0x00, 0x0e,                                           0x60, 0x61, 0x62, 0x63,                                           0x00, 0x0e
    .db     0x00, 0x0e,                                           0x64, 0x65, 0x66, 0x67,                                           0x00, 0x0e
    .db     0x00, 0x0e,                                           0x68, 0x69, 0x6a, 0x6b,                                           0x00, 0x0e
    .db     0x00, 0x0d,                                     0x6c, 0x6d, 0x00, 0x02, 0x6e, 0x6f, 0xd2, 0xd3, 0x80, 0x81, 0x80, 0x81, 0x00, 0x07
    .db     0x00, 0x07, 0x90, 0x91, 0x92, 0x93, 0x94, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x9d, 0x82, 0x83, 0x82, 0x83, 0x00, 0x07
    .db     0x00, 0x07, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0x78, 0x79, 0xa7, 0x7a, 0x7b, 0xaa, 0x7c, 0x7d, 0xad, 0x84, 0x85, 0x84, 0x85, 0x00, 0x07
    .db     0x00, 0x07, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0x7e, 0x7f, 0xba, 0xbb, 0xbc, 0xbd, 0x86, 0x87, 0x86, 0x87, 0x00, 0x07
    .db     0x00, 0x07, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0x58, 0x59, 0xca, 0xcb, 0xcc, 0xcd, 0x88, 0x89, 0x88, 0x89, 0x00, 0x07
    .db     0x00, 0x0e,                                           0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd,                         0x00, 0x0b
    .db     0xff

titleLogoSprite:

    .db     0x38 - 0x01, 0x60, 0x4c, VDP_COLOR_LIGHT_YELLOW
    .db     0x38 - 0x01, 0x70, 0x50, VDP_COLOR_LIGHT_YELLOW
    .db     0x38 - 0x01, 0x80, 0x54, VDP_COLOR_LIGHT_YELLOW
    .db     0x40 - 0x01, 0x90, 0x58, VDP_COLOR_LIGHT_YELLOW
    .db     0x38 - 0x01, 0x88, 0x48, VDP_COLOR_DARK_YELLOW
    .db     0x48 - 0x01, 0x60, 0x5c, VDP_COLOR_WHITE
    .db     0x48 - 0x01, 0x78, 0x60, VDP_COLOR_WHITE
    .db     0x48 - 0x01, 0x90, 0x64, VDP_COLOR_WHITE
    .db     0x50 - 0x01, 0x78, 0x68, VDP_COLOR_LIGHT_YELLOW
    .db     0x58 - 0x01, 0x78, 0x6c, VDP_COLOR_DARK_YELLOW

; 目
;
titleEyeSprite:

    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_TRANSPARENT
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_DARK_RED
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_MEDIUM_RED
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_LIGHT_RED
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_LIGHT_RED
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_MEDIUM_RED
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_DARK_RED
    .db     0x28 - 0x01, 0x78, 0x70, VDP_COLOR_TRANSPARENT

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    .db     0x28, 0x29, 0x34, 0x00, 0x33, 0x30, 0x21, 0x23, 0x25, 0x00, 0x34, 0x2f, 0x00, 0x33, 0x34, 0x21, 0x32, 0x34
    .db     0x00, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff, 0x00

; OPLL
;
titleOpllPatternName:

    .db     0xe0, 0xe1, 0xe2, 0xe3

; パスワード
;
titlePasswordPatternName:

    .db     0x29, 0x2e, 0x30, 0x35, 0x34, 0x00, 0x30, 0x21, 0x33, 0x33, 0x37, 0x2f, 0x32, 0x24

; エラー
;
titleErrorPatternName:

    .db     0x29, 0x2e, 0x23, 0x2f, 0x32, 0x32, 0x25, 0x23, 0x34, 0x00, 0x30, 0x21, 0x33, 0x33, 0x37, 0x2f, 0x32, 0x24


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::
    
    .ds     TITLE_LENGTH
