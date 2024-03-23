; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Title.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _patternTable


; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; アプリケーションの初期化
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c

    ; ダブルバッファするために 2 回転送
    ld      b, #0x02
10$:
    push    bc
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
11$:
    ld      e, #0x10
12$:
    push    de
    ld      b, #0x08
;   otir
13$:
    outi
    jp      nz, 13$
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
;   otir
14$:
    outi
    jp      nz, 14$
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 12$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 11$
    pop     bc
    djnz    10$
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #APP_PATTERN_GENERATOR_TABLE
    ld      bc, #0x1000
    call    LDIRVM
    
    ; カラーテーブルの初期化
    ld      hl, #(appColorTable + 0x0000)
    ld      de, #(APP_COLOR_TABLE + 0x0000)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(appColorTable + 0x0020)
    ld      de, #(APP_COLOR_TABLE + 0x0040)
    ld      bc, #0x0020
    call    LDIRVM
    
    ; パターンネームの初期化
    ld      hl, #APP_PATTERN_NAME_TABLE
    xor     a
    ld      bc, #0x0600
    call    FILVRM
    
    ; 割り込み禁止の解除
    ei

    ; アプリケーションの初期化
    ld      hl, #appDefault
    ld      de, #_app
    ld      bc, #APP_LENGTH
    ldir

    ; 状態の設定
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_app + APP_STATE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 乱数をまわす
    call    _SystemGetRandom
    
;   ;  フレームの更新
;   ld      hl, #(_app + APP_FRAME)
;   inc     (hl)
;   ld      a, (hl)
;   ld      (_app + APP_DEBUG_7), a

;   ; デバッグ表示
;   call    AppPrintDebug

    ; 更新の終了
90$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 処理なし
;
_AppNull::

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームの初期状態を設定する
;
_AppSetGameInitial::

    ; レジスタの保存

    ; ゲームの設定
    ld      hl, #(_app + APP_GAME_RANDOM_L)

    ; 乱数の設定
    call    _SystemGetRandom
    ld      (hl), a
    inc     hl
    call    _SystemGetRandom
    ld      (hl), a
    inc     hl

    ; レベルの設定
    ld      (hl), #0x01
    inc     hl

    ; 経験値の設定
    ld      (hl), #0x00
    inc     hl

    ; レジストの設定
    ld      (hl), #0x00
    inc     hl

    ; クリスタルの設定
    ld      (hl), #0b00000000
    inc     hl

    ; アイテムの設定
    ld      (hl), #0b00000000
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; パスワードを取得する
;
_AppGetPassword::

    ; レジスタの保存
    push    bc
    push    de

    ; hl > パスワード

    ; 乱数　　　 : 16 bits
    ; レベル　　 :  4 bits
    ; 経験値　　 :  6 bits
    ; レジスト　 :  6 bits
    ; クリスタル :  5 bits
    ; アイテム　 :  5 bits
    ; ＣＲＣ　　 :  8 bits
    ; 計　　　　 : 50 bits / 5 = 10 文字
    ; 文字種　　 : 0123456789ACDEFGHJKLMNPQRSTUVWXY = 32 種

    ; CRC の計算
    ld      hl, #(_app + APP_GAME_RANDOM_L)
    ld      bc, #APP_GAME_LENGTH
    call    _SystemCalcCrc
    ld      (_app + APP_CRC), a

    ; ビットの展開
;   ld      hl, #(_app + APP_GAME_RANDOM_L)
    ld      de, #(_app + APP_PASSWORD_0)
    ld      b, #0b00011111

    ; 0 = APP_GAME_RANDOM_L:11111000
    ld      a, (hl)
;   inc     hl
    rrca
    rrca
    rrca
    and     b
    ld      (de), a
    inc     de

    ; 1 = APP_GAME_RANDOM_L:00000111 + APP_GAME_RANDOM_H:11000000
    ld      a, (hl)
    inc     hl
    ld      c, (hl)
;   inc     hl
    sla     c
    rla
    sla     c
    rla
    and     b
    ld      (de), a
    inc     de

    ; 2 = APP_GAME_RANDOM_H:00111110
    ld      a, (hl)
;   inc     hl
    rrca
    and     b
    ld      (de), a
    inc     de

    ; 3 = APP_GAME_RANDOM_H:00000001 + APP_GAME_LEVEL:00001111
    ld      a, (hl)
    inc     hl
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    or      (hl)
    inc     hl
    and     b
    ld      (de), a
    inc     de

    ; 4 = APP_GAME_EXPERIENCE:00100000 + APP_CRC:11110000
    ld      a, (_app + APP_CRC)
    rrca
    rrca
    rrca
    rrca
    and     #0b00001111
    ld      c, a
    ld      a, (hl)
;   inc     hl
    rrca
    and     #0b00010000
    or      c
    ld      (de), a
    inc     de

    ; 5 = APP_GAME_EXPERIENCE:00011111
    ld      a, (hl)
    inc     hl
    and     b
    and     b
    ld      (de), a
    inc     de

    ; 6 = APP_GAME_RESIST:00100000 + APP_CRC:00001111
    ld      a, (_app + APP_CRC)
    and     #0b00001111
    ld      c, a
    ld      a, (hl)
;   inc     hl
    rrca
    and     #0b00010000
    or      c
    ld      (de), a
    inc     de

    ; 7 = APP_GAME_RESIST:00011111
    ld      a, (hl)
    inc     hl
    and     b
    ld      (de), a
    inc     de

    ; 8 = APP_GAME_CRYSTAL:00011111
    ld      a, (hl)
    inc     hl
    and     b
    ld      (de), a
    inc     de

    ; 9 = APP_GAME_ITEM:00011111
    ld      a, (hl)
;   inc     hl
    and     b
    ld      (de), a
;   inc     de

    ; パスワードへの変換
    ld      de, #(_app + APP_PASSWORD_0)
    ld      b, #APP_PASSWORD_LENGTH
10$:
    push    bc
    ld      a, (de)
    ld      c, a
    ld      b, #0x00
    ld      hl, #appPasswordLetter
    add     hl, bc
    ld      a, (hl)
    ld      (de), a
    inc     de
    pop     bc
    djnz    10$

    ; パスワードを返す
    ld      hl, #(_app + APP_PASSWORD_0)

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; パスワードを設定する
;
_AppSetPassword::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < パスワード
    ; cf > 1 = パスワードが正しい

    ; ビットの展開
    ex      de, hl
    ld      hl, #(_app + APP_GAME_RANDOM_L)
    ld      b, #0b00011111

    ; 0 = APP_GAME_RANDOM_L:11111000
    ld      a, (de)
    inc     de
    call    80$
    jp      nc, 10$
    add     a, a
    add     a, a
    add     a, a
    ld      (hl), a
;   inc     hl

    ; 1 = APP_GAME_RANDOM_L:00000111 + APP_GAME_RANDOM_H:11000000
    ld      a, (de)
    inc     de
    call    80$
    jp      nc, 10$
    rrca
    rrca
    ld      c, a
    and     #0b00000111
    or      (hl)
    ld      (hl), a
    inc     hl
    ld      a, c
    and     #0b11000000
    ld      (hl), a
;   inc     hl

    ; 2 = APP_GAME_RANDOM_H:00111110
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    add     a, a
    or      (hl)
    ld      (hl), a
;   inc     hl

    ; 3 = APP_GAME_RANDOM_H:00000001 + APP_GAME_LEVEL:00001111
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    ld      c, a
    rrca
    rrca
    rrca
    rrca
    and     #0b00000001
    or      (hl)
    ld      (hl), a
    inc     hl
    ld      a, c
    and     #0b00001111
    ld      (hl), a
    inc     hl

    ; 4 = APP_GAME_EXPERIENCE:00100000 + APP_CRC:11110000
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    add     a, a
    ld      c, a
    and     #0b00100000
    ld      (hl), a
;   inc     hl
    ld      a, c
    add     a, a
    add     a, a
    add     a, a
    ld      (_app + APP_CRC), a

    ; 5 = APP_GAME_EXPERIENCE:00011111
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    or      (hl)
    ld      (hl), a
    inc     hl

    ; 6 = APP_GAME_RESIST:00100000 + APP_CRC:00001111
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    ld      c, a
    add     a, a
    and     #0b00100000
    ld      (hl), a
;   inc     hl
    push    hl
    ld      hl, #(_app + APP_CRC)
    ld      a, c
    and     #0b00001111
    or      (hl)
    ld      (hl), a
    pop     hl

    ; 7 = APP_GAME_RESIST:00011111
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    or      (hl)
    ld      (hl), a
    inc     hl

    ; 8 = APP_GAME_CRYSTAL:00011111
    ld      a, (de)
    inc     de
    call    80$
    jr      nc, 10$
    ld      (hl), a
    inc     hl

    ; 9 = APP_GAME_ITEM:00011111
    ld      a, (de)
;   inc     de
    call    80$
    jr      nc, 10$
    ld      (hl), a
;   inc     hl

    ; CRC の計算
    ld      hl, #(_app + APP_GAME_RANDOM_L)
    ld      bc, #APP_GAME_LENGTH
    call    _SystemCalcCrc
    ld      hl, #(_app + APP_CRC)
    cp      (hl)
    jr      nz, 10$
    scf
    jr      90$
10$:
    or      a
    jr      90$

    ; パスワードからビットを取得
80$:
    push    hl
    push    bc
    ld      hl, #appPasswordLetter
    ld      bc, #((APP_PASSWORD_LETTER_LENGTH << 8) | 0x00)
81$:
    cp      (hl)
    jr      z, 82$
    inc     hl
    inc     c
    djnz    81$
    or      a
    jr      89$
82$:
    ld      a, c
    scf
;   jr      89$
89$:
    pop     bc
    pop     hl
    ret

    ; 設定の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; キーバッファをクリアする
;
_AppClearKeyBuffer::

    ; レジスタの保存

    ; キーバッファのクリア
    call    KILBUF
    
    ; レジスタの復帰

    ; 終了
    ret

; 入力されたキーを取得する
;
_AppGetKey::

    ; レジスタの保存

    ; a  > 押されたキー
    ; cf > 1 = 押された

    ; キーの監視
    call    CHSNS
    ld      a, #0x00
    jr      z, 18$
    call    CHGET
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; キーが押されたかどうかを判定する
;
_AppIsHitSpace::

    ; レジスタの保存

    ; cf > 1 = 押された

    ; SPACE の監視
10$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      z, 11$
    call    CHSNS
    ld      a, #0x00
    jr      z, 18$
    call    CHGET
    cp      #0x20
    jr      nz, 10$
11$:
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

_AppIsHitEsc::

    ; レジスタの保存

    ; cf > 1 = 押された

    ; ESC の監視
10$:
    call    CHSNS
    ld      a, #0x00
    jr      z, 18$
    call    CHGET
    cp      #0x1b
    jr      nz, 10$
11$:
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 圧縮されたパターンネームを描画する
;
_AppUncompressPatternName::

    ; レジスタの保存
    push    hl
    push    de

    ; hl < パターンネーム
    ; de < 描画先

    ; パターンネームの描画
10$:
    ld      a, (hl)
    inc     hl
    cp      #0xff
    jr      z, 19$
    or      a
    jr      z, 11$
    ld      (de), a
    inc     de
    jr      10$
11$:
    ld      b, (hl)
    inc     hl
12$:
    ld      (de), a
    inc     de
    djnz    12$
    jr      10$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; デバッグ情報を表示する
;
AppPrintDebug:

    ; レジスタの保存

    ; SP の表示
    ld      de, #(_patternName + 0x02e0)
    ld      hl, #appDebugStringSp
    call    70$
    ld      hl, #0x0000
    add     hl, sp
    ld      a, h
    call    80$
    ld      a, l
    call    80$
19$:

    ; デバッグの表示
    ld      de, #(_patternName + 0x02f0)
    ld      hl, #(_app + APP_DEBUG_0)
    ld      b, #APP_DEBUG_LENGTH
20$:
    ld      a, (hl)
    call    80$
    inc     hl
    djnz    20$
29$:
    jr      90$

    ; 文字列の表示
70$:
    ld      a, (hl)
    sub     #0x20
    ret     c
    ld      (de), a
    inc     hl
    inc     de
    jr      70$

    ; 16 進数の表示
80$:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    81$
    pop     af
    call    81$
    ret
81$:
    and     #0x0f
    cp      #0x0a
    jr      c, 82$
    add     a, #0x07
82$:
    add     a, #0x10
    ld      (de), a
    inc     de
    ret

    ; デバッグ表示の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000000

; カラーテーブル
;
appColorTable:

    ; ゲーム
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_MEDIUM_GREEN, (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_MEDIUM_GREEN
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_MEDIUM_GREEN
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_MEDIUM_GREEN
    ; タイトル
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,        (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK

; 状態別の処理
;
appProc:
    
    .dw     _AppNull
    .dw     _TitleInitialize
    .dw     _TitleUpdate
    .dw     _GameInitialize
    .dw     _GameUpdate

; アプリケーションの初期値
;
appDefault:

    .db     APP_STATE_NULL
    .db     APP_FRAME_NULL
    .dw     APP_GAME_RANDOM_NULL
    .db     APP_GAME_LEVEL_NULL
    .db     APP_GAME_EXPERIENCE_NULL
    .db     APP_GAME_RESIST_NULL
    .db     APP_GAME_CRYSTAL_NULL
    .db     APP_GAME_ITEM_NULL
    .db     APP_CRC_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_PASSWORD_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL
    .db     APP_DEBUG_NULL

; パスワード
;
appPasswordLetter:

;   .ascii  "0123456789ACDEFGHJKLMNPQRSTUVWXY"
    .ascii  "FDEG3210XWYV8C9ATURSKLHJ6457MNPQ"

; デバッグ
;
appDebugStringSp:

    .ascii  "SP="
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; アプリケーション
;
_app::

    .ds     APP_LENGTH
