; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Item.inc"
    .include    "Camera.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Boss.inc"
    .include    "Magic.inc"
    .include    "Field.inc"
    .include    "Dungeon.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

;   ; パターンネームのクリア
;   xor     a
;   call    _SystemClearPatternName

    ; ゲーム画面の描画
    call    GamePrintScreen

    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir
    
    ; カメラの初期化
    call    _CameraInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; ボスの初期化
    call    _BossInitialize

    ; 魔法の初期化
    call    _MagicInitialize

    ; フィールドの初期化
    call    _FieldInitialize

    ; ダンジョンの初期化
    call    _DungeonInitialize
    
    ; スプライトジェネレータの設定
    ld      a, #(APP_SPRITE_GENERATOR_TABLE >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      hl, #(APP_SPRITE_GENERATOR_TABLE + 0x0800 + GAME_SPRITE_GENERATOR_OFFSET)
    ld      (_game + GAME_SPRITE_GENERATOR_L), hl

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; サウンドの停止
    call    _SoundStop

    ; 状態の設定
    ld      a, #GAME_STATE_BUILD
    ld      (_game + GAME_STATE), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトジェネレータの転送
    call    GameTransferSpriteGenerator

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを作成する
;
GameBuild:

    ; レジスタの保存

    ; 0x00 : 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ゲーム画面の描画
    call    GamePrintStatus
    call    GamePrintStart

    ; BGM の再生
    ld      a, #SOUND_BGM_START
    call    _SoundPlayBgm

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
    jr      90$
09$:

    ; 0x01 : フィールドの作成
    dec     a
    jr      nz, 19$

    ; フィールドの作成
    call    _FieldBuild
    call    _FieldIsError
    jr      c, 90$

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
    jr      19$
19$:

    ; 0x02 : 待機
;   dec     a
;   jr      nz, 29$

    ; BGM の監視
    call    _SoundIsPlayBgm
    jr      c, 29$

    ; エネミーの常駐
    call    _EnemyReside

    ; 状態の更新
    ld      a, #GAME_STATE_START
;   ld      a, #GAME_STATE_DEBUG
    ld      (_game + GAME_STATE), a
;   jr      90$
29$:

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    call    _FieldGetStartPosition
    ld      (_player + PLAYER_POSITION_X), de
;   call    _PlayerSetStay

    ; カメラの設定
    call    _PlayerSetCameraCenter

    ; フェードの設定
    xor     a
    ld      (_game + GAME_FADE), a

    ; BGM の再生
    ld      a, #SOUND_BGM_FIELD
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

;   ; エネミーの更新
;   call    _EnemyUpdate

;   ; 魔法の更新
;   call    _MagicUpdate

    ; フィールドの更新
    call    _FieldUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

;   ; エネミーの描画
;   call    _EnemyRender

;   ; 魔法の描画
;   call    _MagicRender

    ; フィールドの描画
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_VIEW_BIT, (hl)
    call    _FieldRender

    ; ステータスの描画
    call    GamePrintStatus

    ; フェードの描画
    ld      hl, #(_game + GAME_FADE)
    inc     (hl)
    call    GamePrintFade

    ; フェードの監視
    ld      a, (_game + GAME_FADE)
    cp      #GAME_FADE_LENGTH
    jr      c, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_FIELD
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; フィールドをプレイする
;
GameField:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    call    _PlayerSetField

    ; ヒットのクリア
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_HIT_BIT, (hl)

    ; スクロールの開始
    ld      hl, #(_camera + CAMERA_FLAG)
    set     #CAMERA_FLAG_SCROLL_BIT, (hl)

    ; BGM の再生
    ld      a, #SOUND_BGM_FIELD
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット判定
    ld      hl, #(_game + GAME_FLAG)
    bit     #GAME_FLAG_HIT_BIT, (hl)
    call    nz, GameHitField
    set     #GAME_FLAG_HIT_BIT, (hl)

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 魔法の更新
    call    _MagicUpdate

    ; フィールドの更新
    call    _FieldUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 魔法の描画
    call    _MagicRender

    ; フィールドの描画
    call    _FieldRender

    ; ステータスの描画
    call    GamePrintStatus

    ; 更新と描画の完了
90$:

    ; プレイヤの死亡
    call    _PlayerIsDead
    jr      nc, 91$

    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
    jr      99$
91$:

    ; 穴に入る
    call    _PlayerIsHole
    jr      nc, 92$

    ; 状態の更新
    ld      a, #GAME_STATE_HOLE
    ld      (_game + GAME_STATE), a
    jr      99$
92$:

    ; 入り口に立つ
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_ENTRANCE_BIT, a
    jr      nz, 93$
    call    _PlayerIsEntrance
    jr      nc, 93$

    ; 状態の更新
    ld      a, #GAME_STATE_ENTRANCE
    ld      (_game + GAME_STATE), a
93$:

    ; ESC キーの入力
    call    _AppIsHitEsc
    jr      nc, 99$

    ; 状態の更新
    ld      a, #GAME_STATE_PASSWORD
    ld      (_game + GAME_STATE), a
;   jr      99$
99$:

    ; レジスタの復帰

    ; 終了
    ret

; 入り口に立つ
;
GameEntrance:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    call    _PlayerSetStay

    ; 入り口の設定
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_ENTRANCE_BIT, (hl)

    ; サウンドの停止
    call    _SoundStop

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

;   ; エネミーの更新
;   call    _EnemyUpdate

;   ; 魔法の更新
;   call    _MagicUpdate

    ; フィールドの更新
    call    _FieldUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 魔法の描画
    call    _MagicRender

    ; フィールドの描画
    call    _FieldRender

    ; ステータスの描画
    call    GamePrintStatus

    ; 更新と描画の完了
90$:

    ; 通路の出現
    call    _FieldIsPath
    jr      nc, 99$

    ; 状態の更新
    ld      a, #GAME_STATE_FIELD
    ld      (_game + GAME_STATE), a
;   jr      99$
99$:

    ; レジスタの復帰

    ; 終了
    ret

; 穴に入る
;
GameHole:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    call    _PlayerSetStay

    ; エネミーの削除
    call    _EnemyKillAll

    ; 魔法の削除
    call    _MagicKillAll

    ; フェードの設定
    ld      a, #GAME_FADE_LENGTH
    ld      (_game + GAME_FADE), a

    ; BGM の再生
    ld      a, #SOUND_BGM_DUNGEON
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

;   ; エネミーの更新
;   call    _EnemyUpdate

;   ; 魔法の更新
;   call    _MagicUpdate

    ; フィールドの更新
    call    _FieldUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

;   ; エネミーの描画
;   call    _EnemyRender

;   ; 魔法の描画
;   call    _MagicRender

    ; フィールドの描画
    ld      hl, #(_field + FIELD_FLAG)
    set     #FIELD_FLAG_VIEW_BIT, (hl)
    call    _FieldRender

    ; ステータスの描画
    call    GamePrintStatus

    ; フェードの描画
    ld      hl, #(_game + GAME_FADE)
    dec     (hl)
    call    GamePrintFade

    ; フェードの監視
    ld      a, (_game + GAME_FADE)
    or      a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_DUNGEON
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ダンジョンをプレイする
;
GameDungeon:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    ld      hl, (_player + PLAYER_POSITION_X)
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      a, l
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    ld      l, a
    ld      a, h
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    ld      h, a
    ld      (_player + PLAYER_POSITION_X), hl
    call    _PlayerSetDungeon

    ; ボスの設定
    call    _BossEntry

    ; カメラの設定
    ld      de, #0x0000
    ld      (_camera + CAMERA_POSITION_X), de

    ; スプライトの設定
    ld      a, #(GAME_SPRITE_MASK_LEFT_UP | GAME_SPRITE_MASK_LEFT_DOWN | GAME_SPRITE_MASK_RIGHT_UP | GAME_SPRITE_MASK_RIGHT_DOWN)
    ld      (_game + GAME_SPRITE_MASK), a

    ; ヒットのクリア
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_HIT_BIT, (hl)

    ; スクロールの停止
    ld      hl, #(_camera + CAMERA_FLAG)
    res     #CAMERA_FLAG_SCROLL_BIT, (hl)

    ; フレームの設定
    ld      a, #GAME_FRAME_BOSS
    ld      (_game + GAME_FRAME), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)

    ; ボスの登場
    call    z, _BossSetPlay
10$:

    ; ヒット判定
    ld      hl, #(_game + GAME_FLAG)
    bit     #GAME_FLAG_HIT_BIT, (hl)
    call    nz, GameHitDungeon
    set     #GAME_FLAG_HIT_BIT, (hl)

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _BossIsLife
    call    c, _PlayerUpdate

    ; ボスの更新
    call    _BossUpdate

    ; 魔法の更新
    call    _MagicUpdate

    ; ダンジョンの更新
    call    _DungeonUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ボスの描画
    call    _BossRender

    ; 魔法の描画
    call    _MagicRender

    ; ダンジョンの描画
    call    _DungeonRender

    ; ステータスの描画
    call    GamePrintStatus

    ; 更新と描画の完了
90$:

    ; サウンドの監視
    call    _BossIsLife
    ld      a, #SOUND_BGM_KILL
    call    nc, _SoundPlayBgm

    ; プレイヤの死亡
    call    _PlayerIsDead
    jr      nc, 91$

    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
    jr      99$
91$:

    ; ボスの死亡
    call    _BossIsDead
    jr      nc, 99$

    ; 状態の更新
    ld      a, #GAME_STATE_CLEAR
    ld      (_game + GAME_STATE), a
;   jr      99$
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; エネミーの削除
    call    _EnemyKillAll

    ; ボスの削除
    call    _BossKill

    ; フェードの設定
    ld      a, #GAME_FADE_LENGTH
    ld      (_game + GAME_FADE), a

    ; フレームの設定
    ld      a, #(GAME_FADE_LENGTH + 0x10)
    ld      (_game + GAME_FRAME), a

    ; サウンドの停止
    call    _SoundStop

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フェードの更新
    ld      hl, #(_game + GAME_FADE)
    ld      a, (hl)
    or      a
    jr      z, 109$
    dec     (hl)

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender
109$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 119$
    dec     (hl)

    ; ステータスの描画
    call    GamePrintStatus

    ; フェードの描画
    call    GamePrintFade

    ; フレームの監視
    ld      a, (_game + GAME_FRAME)
    or      a
    jr      nz, 190$

    ; ゲームオーバーの描画
    call    GamePrintOver

    ; キーバッファのクリア
    call    _AppClearKeyBuffer

    ; BGM の再生
    ld      a, #SOUND_BGM_OVER
    call    _SoundPlayBgm
    jr      190$
119$:

    ; SPACE キーの入力
    call    _AppIsHitSpace
    jr      nc, 129$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      190$
129$:

    ; ゲームオーバーの完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    call    _PlayerSetClear

    ; フェードの設定
    xor     a
    ld      (_game + GAME_FADE), a

    ; BGM の再生
    ld      a, #SOUND_BGM_CLEAR
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 0x01 : 定位置へ移動
10$:
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    dec     a
    jr      nz, 20$

    ; プレイヤの監視
    call    _PlayerIsStay
    jr      nc, 19$

    ; 扉を開く
    call    _DungeonSetGate

    ; フレームの設定
    ld      a, #GAME_FRAME_OPEN
    ld      (_game + GAME_FRAME), a

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
;   jr      19$
19$:
    jr      80$

    ; 0x02 : 扉を開く
20$:
    dec     a
    jr      nz, 30$

    ; 扉の監視
    call    _DungeonIsGateOpen
    jr      nc, 29$

    ; クリア画面の描画
    call    GamePrintClearOpen

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 29$

    ; プレイヤの更新
    call    _PlayerSetExit

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
;   jr      29$
29$:
    jr      80$

    ; 0x03 : 扉に入る
30$:
    dec     a
    jr      nz, 40$

    ; プレイヤの監視
    call    _PlayerIsStay
    jr      nc, 39$

    ; フェードの設定
    ld      a, #GAME_FADE_LENGTH
    ld      (_game + GAME_FADE), a

    ; フレームの設定
    ld      a, #(GAME_FADE_LENGTH + 0x10)
    ld      (_game + GAME_FRAME), a

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
;   jr      39$
39$:
    jr      80$

    ; 0x04 : フェード
40$:
    dec     a
    jr      nz, 50$

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 49$

    ; キーバッファのクリア
    call    _AppClearKeyBuffer

    ; クリア画面の描画
    call    GamePrintClearContinue

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
;   jr      49$
49$:
    jr      80$

    ; 0x05 : キー入力待ち
50$:
    dec     a
    jr      nz, 80$

    ; SPACE キーの入力
    call    _AppIsHitSpace
    jr      nc, 59$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      59$
59$:
;   jr      80$

    ; クリアの完了
80$:

;   ; カメラの更新
;   call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ダンジョンの更新
    call    _DungeonUpdate

;   ; カメラの描画
;   call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ダンジョンの描画
    call    _DungeonRender

    ; ステータスの描画
    call    GamePrintStatus

    ; フェードの更新
    ld      hl, #(_game + GAME_FADE)
    ld      a, (hl)
    or      a
    jr      z, 81$
    dec     (hl)

    ; フェードの描画
    call    GamePrintFade
81$:

    ; レジスタの復帰

    ; 終了
    ret

; パスワードを表示する
;
GamePassword:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; パスワードの取得
    call    GameGetPassword

    ; パスワードの描画
    call    GamePrintPassword

    ; キーバッファのクリア
    call    _AppClearKeyBuffer

    ; サウンドの停止
    call    _SoundStop
    
    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ESC キーの入力
    call    _AppIsHitEsc
    jr      nc, 19$

    ; フィールドの再描画
    call    _FieldView

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #GAME_STATE_FIELD
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをデバッグする
;
GameDebug:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; カメラの設定
    ld      hl, #0x0000
    ld      (_camera + CAMERA_POSITION_X), hl

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; カメラの移動
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 10$
    ld      a, d
    or      a
    jr      z, 13$
    sub     #FIELD_NAME_SIZE_Y
    ld      d, a
    jr      13$
10$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 11$
    ld      a, d
    cp      #(FIELD_SIZE_Y - (0x18 * FIELD_NAME_SIZE_Y))
    jr      nc, 13$
    add     a, #FIELD_NAME_SIZE_Y
    ld      d, a
    jr      13$
11$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 12$
    ld      a, e
    or      a
    jr      z, 13$
    sub     #FIELD_NAME_SIZE_X
    ld      e, a
    jr      13$
12$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 13$
    ld      a, e
    cp      #(FIELD_SIZE_X - (0x20 * FIELD_NAME_SIZE_X))
    jr      nc, 13$
    add     a, #FIELD_NAME_SIZE_X
    ld      e, a
    jr      13$
13$:
    ld      (_camera + CAMERA_POSITION_X), de

    ; マップの描画
    call    _FieldPrintMap

    ; 再作成
    call    _AppIsHitSpace
    jr      nc, 29$

    ; 状態の更新
    ld      a, #GAME_STATE_START
    ld      (_game + GAME_STATE), a
29$:

    ; レジスタの復帰

    ; 終了
    ret

; フィールドでのヒット処理を行う
;
GameHitField:

    ; レジスタの保存

    ; プレイヤの生存
    ld      a, (_player + PLAYER_LIFE_POINT)
    or      a
    jr      z, 90$

    ; プレイヤとエネミーの判定
    call    GameHitEnemy

    ; プレイヤと魔法の判定
    call    GameHitMagic

    ; プレイヤのダメージの設定
    call    _PlayerSetDamage

    ; 判定の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ダンジョンでのヒット処理を行う
;
GameHitDungeon:

    ; レジスタの保存

    ; プレイヤの生存
    ld      a, (_player + PLAYER_LIFE_POINT)
    or      a
    jr      z, 90$

    ; プレイヤとボスの判定
    call    GameHitBoss

    ; プレイヤと魔法の判定
    call    GameHitMagic

    ; プレイヤのダメージの設定
    call    _PlayerSetDamage

    ; 判定の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤとエネミーのヒット処理を行う
;
GameHitEnemy:

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    
    ; プレイヤの位置の取得
    ld      de, (_player + PLAYER_POSITION_X)

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jp      z, 190$

    ; エネミーの生存
    ld      a, ENEMY_LIFE(ix)
    or      a
    jp      z, 190$

    ; 重なったかどうか
    ld      a, ENEMY_POSITION_X(ix)
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    cp      #(ENEMY_SIZE_R + 0x01)
    jr      c, 110$
    cp      #(FIELD_SIZE_X - ENEMY_SIZE_R)
    jp      c, 190$
110$:
    ld      l, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #(ENEMY_SIZE_R + 0x01)
    jr      c, 111$
    cp      #(FIELD_SIZE_Y - ENEMY_SIZE_R)
    jr      c, 190$
111$:
    ld      h, a

    ; 吹き飛ばす方向の取得
    ld      a, (_player + PLAYER_DIRECTION)
    ld      c, a
    dec     a
    jr      z, 121$
    dec     a
    jr      z, 122$
    dec     a
    jr      z, 123$
;   jr      z, 120$
120$:
    ld      a, h
    cp      #ENEMY_SIZE_R
    jr      nz, 129$
    ld      c, #PLAYER_DIRECTION_DOWN
    jr      129$
121$:
    ld      a, h
    cp      #(FIELD_SIZE_Y - ENEMY_SIZE_R)
    jr      nz, 129$
    ld      c, #PLAYER_DIRECTION_UP
    jr      129$
122$:
    ld      a, l
    cp      #ENEMY_SIZE_R
    jr      nz, 129$
    ld      c, #PLAYER_DIRECTION_RIGHT
    jr      129$
123$:
    ld      a, l
    cp      #(FIELD_SIZE_X - ENEMY_SIZE_R)
    jr      nz, 129$
    ld      c, #PLAYER_DIRECTION_LEFT
;   jr      129$
129$:

    ; 半キャラずらしかどうか
    ld      b, #ENEMY_DAMAGE_DISTANCE_NORMAL
    ld      a, (_player + PLAYER_DIRECTION)
    and     #0x02
    jr      nz, 130$
    ld      a, l
    or      a
    jr      z, 139$
    ld      b, #ENEMY_DAMAGE_DISTANCE_SHIFT
    jr      139$
130$:
    ld      a, h
    or      a
    jr      z, 139$
    ld      b, #ENEMY_DAMAGE_DISTANCE_SHIFT
;   jr      139$
139$:

    ; エネミーへのダメージ
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MOVE_BIT, a
    jr      z, 149$
    ld      a, (_player + PLAYER_POWER)
    call    _EnemyDamage
149$:

    ; プレイヤへのダメージ
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MOVE_BIT, a
    jr      z, 150$
    ld      a, b
    cp      #ENEMY_DAMAGE_DISTANCE_SHIFT
    jr      nc, 159$
    ld      a, c
    xor     #0x01
    ld      c, a
    ld      b, #PLAYER_DAMAGE_DISTANCE_NORMAL
    jr      151$
150$:    
    ld      c, ENEMY_DIRECTION(ix)
    ld      b, #PLAYER_DAMAGE_DISTANCE_SHIFT
;   jr      151$
151$:
    ld      a, ENEMY_POWER(ix)
    call    _PlayerAddPhysicalDamage
159$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     b
    jp      nz, 100$

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤとボスのヒット処理を行う
;
GameHitBoss:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; プレイヤの位置の取得
    ld      de, (_player + PLAYER_POSITION_X)

    ; ボスの存在
    ld      a, (_boss+ BOSS_STATE)
    or      a
    jr      z, 190$

    ; ボスの生存
    ld      hl, (_boss + BOSS_LIFE_L)
    ld      a, h
    or      l
    jr      z, 190$

    ; ボスが待機中
    ld      a, (_boss + BOSS_BLINK)
    or      a
    jr      nz, 190$

    ; ヒット可能
    ld      a, (_boss + BOSS_FLAG)
    bit     #BOSS_FLAG_HIT_BIT, a
    jr      z, 190$

    ; 重なったかどうか
    ld      a, (_boss + BOSS_POSITION_X)
    sub     e
    cp      #(BOSS_SIZE_R + 0x01)
    jr      c, 100$
    cp      #-BOSS_SIZE_R
    jr      c, 190$
100$:
    ld      l, a
    ld      a, (_boss + BOSS_POSITION_Y)
    sub     d
    cp      #(BOSS_SIZE_R + 0x01)
    jr      c, 101$
    cp      #-BOSS_SIZE_R
    jr      c, 190$
101$:
    ld      h, a

    ; 半キャラずらしかどうか
    ld      b, #0x00
    ld      a, (_player + PLAYER_DIRECTION)
    and     #0x02
    ld      a, l
    jr      z, 110$
    ld      a, h
110$:
    cp      #BOSS_SIZE_R
    jr      c, 119$
    cp      #(-BOSS_SIZE_R + 0x01)
    jr      nc, 119$
    inc     b
;   jr      119$
119$:

    ; ボスへのダメージ
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MOVE_BIT, a
    jr      z, 120$
    ld      a, (_player + PLAYER_POWER)
    call    _BossDamage
120$:

    ; プレイヤへのダメージ
    dec     b
    jr      z, 130$
    ld      a, (_player + PLAYER_DIRECTION)
    xor     #0x01
    ld      c, a
    ld      b, #PLAYER_DAMAGE_DISTANCE_NORMAL
    ld      a, (_boss + BOSS_POWER)
    call    _PlayerAddPhysicalDamage
130$:

    ; 判定の完了
190$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤと魔法のヒット処理を行う
;
GameHitMagic:

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; プレイヤと魔法の判定
    ld      de, (_player + PLAYER_POSITION_X)
    ld      ix, #_magic
    ld      b, #MAGIC_ENTRY
100$:
    push    bc

    ; 魔法の存在
    ld      a, MAGIC_STATE(ix)
    or      a
    jr      z, 190$

    ; 重なったかどうか
    ld      a, MAGIC_POSITION_X(ix)
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    cp      #(MAGIC_SIZE_R + 0x01)
    jr      c, 110$
    cp      #(FIELD_SIZE_X - MAGIC_SIZE_R)
    jr      c, 190$
110$:
    ld      l, a
    ld      a, MAGIC_POSITION_Y(ix)
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #(MAGIC_SIZE_R + 0x01)
    jr      c, 111$
    cp      #(FIELD_SIZE_Y - MAGIC_SIZE_R)
    jr      c, 190$
111$:
    ld      h, a

    ; プレイヤへのダメージ
    ld      a, MAGIC_DIRECTION(ix)
    bit     #0x02, a
    jr      z, 120$
    and     #0x01
    or      #0x02
120$:
    ld      c, a
    ld      b, #PLAYER_DAMAGE_DISTANCE_NORMAL
    ld      a, #MAGIC_POWER
    call    _PlayerAddMagicDamage

    ; 魔法の削除
    call    _MagicKill

    ; 次の魔法へ
190$:
    ld      bc, #MAGIC_LENGTH
    add     ix, bc
    pop     bc
    dec     b
    jr      nz, 100$

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; パスワードを取得する
;
GameGetPassword:

    ; レジスタの保存
    push    bc

    ; hl > パスワード

    ; レベルの設定
    ld      a, (_player + PLAYER_LEVEL)
    ld      (_app + APP_GAME_LEVEL), a

    ; 経験値の設定
    ld      a, (_player + PLAYER_EXPERIENCE_POINT)
    ld      (_app + APP_GAME_EXPERIENCE), a

    ; レジストの設定
    ld      a, (_player + PLAYER_RESIST)
    ld      (_app + APP_GAME_RESIST), a

    ; クリスタルの設定
    ld      hl, #(_player + PLAYER_CRYSTAL_RED)
    ld      bc, #0x0500
10$:
    sla     c
    ld      a, (hl)
    or      a
    jr      z, 11$
    inc     c
11$:
    inc     hl
    djnz    10$
    ld      a, c
    ld      (_app + APP_GAME_CRYSTAL), a

    ; アイテムの設定
    ld      hl, #(_player + PLAYER_KEY)
    ld      bc, #0x0500
20$:
    sla     c
    ld      a, (hl)
    or      a
    jr      z, 21$
    inc     c
21$:
    inc     hl
    djnz    20$
    ld      a, c
    ld      (_app + APP_GAME_ITEM), a

    ; パスワードの取得
    call    _AppGetPassword

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; スプライトのマスク値を取得する
;
_GameGetSpriteMask::

    ; レジスタの保存
    push    bc
    push    de

    ; de < Y/X 位置
    ; a  > マスク値

    ; 地形によるマスクの作成
    push    de
    ld      a, (_game + GAME_SPRITE_MASK)
    ld      c, a
    or      a
    jr      nz, 10$
    call    _FieldIsLayerUpper
    ccf
    rl      c
    scf
    rl      c
    ld      a, e
    dec     a
    and     #(FIELD_SIZE_X - 0x01)
    ld      e, a
    call    _FieldIsLayerUpper
    ccf
    rl      c
    scf
    rl      c
10$:
    pop     de

    ; 位置によるマスクの作成
    ld      a, (_camera + CAMERA_POSITION_Y)
    ld      b, a
    ld      a, d
    sub     b
    and     #(FIELD_SIZE_Y - 0x01)
    jr      nz, 20$
    ld      a, c
    and     #~(GAME_SPRITE_MASK_LEFT_UP | GAME_SPRITE_MASK_RIGHT_UP)
    ld      c, a
    jr      21$
20$:
    cp      #CAMERA_VIEW_SIZE_Y
    jr      c, 21$
    jr      nz, 28$
    ld      a, c
    and     #~(GAME_SPRITE_MASK_LEFT_DOWN | GAME_SPRITE_MASK_RIGHT_DOWN)
    ld      c, a
;   jr      21$
21$:
    ld      a, (_camera + CAMERA_POSITION_X)
    ld      b, a
    ld      a, e
    sub     b
    and     #(FIELD_SIZE_X - 0x01)
    jr      nz, 22$
    ld      a, c
    and     #~(GAME_SPRITE_MASK_LEFT_UP | GAME_SPRITE_MASK_LEFT_DOWN)
    ld      c, a
    jr      29$
22$:
    cp      #CAMERA_VIEW_SIZE_X
    jr      c, 29$
    jr      nz, 28$
    ld      a, c
    and     #~(GAME_SPRITE_MASK_RIGHT_UP | GAME_SPRITE_MASK_RIGHT_DOWN)
    ld      c, a
    jr      29$
28$:
    ld      c, #0x00
;   jr      29$
29$:
    ld      a, c

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; スプライトジェネレータを作成する
;
_GameMakeSpriteGenerator::

    ; レジスタの保存
    push    af
    push    hl
    push    bc
    push    de

    ; hl < パターンテーブル
    ; de < スプライトジェネレータ
    ; a  < マスク値

    ; スプライトジェネレータの作成
    ld      bc, #0x0008
    rrca
    jr      nc, 10$
    ldir
    jr      11$
10$:
    add     hl, bc
    ld      c, a
    xor     a
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      a, c
;   jr      11$
11$:
    ld      bc, #(0x0080 - 0x0008)
    add     hl, bc
    ld      bc, #0x0008
    rrca
    jr      nc, 12$
    ldir
    jr      13$
12$:
    add     hl, bc
    ld      c, a
    xor     a
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      a, c
;   jr      13$
13$:
    ld      bc, #-0x0080
    add     hl, bc
    ld      bc, #0x0008
    rrca
    jr      nc, 14$
    ldir
    jr      15$
14$:
    add     hl, bc
    ld      c, a
    xor     a
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      a, c
;   jr      15$
15$:
    ld      bc, #(0x0080 - 0x0008)
    add     hl, bc
    ld      bc, #0x0008
    rrca
    jr      nc, 16$
    ldir
    jr      17$
16$:
    add     hl, bc
    ld      c, a
    xor     a
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
    ld      (de), a
    inc     de
;   ld      a, c
;   jr      17$
17$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    pop     af

    ; 終了
    ret

; スプライトジェネレータを転送する
;
GameTransferSpriteGenerator:

    ; レジスタの保存

;   ; BIOS による転送
;   ld      hl, #_gameSpriteGenerator
;   ld      de, (_game + GAME_SPRITE_GENERATOR_L)
;   ld      bc, #GAME_SPRITE_GENERATOR_LENGTH
;   call    LDIRVM

    ; 割り込みの禁止
;   di

    ; ポートの取得
    ld      a, (_videoPort + 1)
    ld      d, a
    inc     a
    ld      e, a

    ; VRAM アドレスの設定
    ld      hl, (_game + GAME_SPRITE_GENERATOR_L)
    ld      c, e
    out     (c), l
    ld      a, h
    or      #0b01000000
    out     (c), a

    ; スプライトジェネレータの転送
    ld      hl, #_gameSpriteGenerator
    ld      c, d
    ld      b, #0x80
10$:
    outi
    jp      nz, 10$
11$:
    outi
    jp      nz, 11$

    ; 割り込み禁止の解除
;   ei

    ; スプライトジェネレータの設定
    ld      a, (_game + GAME_SPRITE_GENERATOR_H)
    srl     a
    srl     a
    srl     a
    ld      (_videoRegister + VDP_R6), a

    ; スプライトジェネレータの切り替え
    ld      a, (_game + GAME_SPRITE_GENERATOR_H)
    xor     #0b00001000
    ld      (_game + GAME_SPRITE_GENERATOR_H), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲーム画面を描画する
;
GamePrintScreen:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameScreenPatternName
    ld      de, #_patternName
    call    _AppUncompressPatternName

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存

    ; ライフの描画
    ld      hl, #(_patternName + 0x0078)
    ld      a, (_player + PLAYER_LIFE_POINT)
    ld      b, a
    ld      c, #0x58
    call    GamePrintMeter
    ld      hl, #(_patternName + 0x0098)
    ld      a, (_player + PLAYER_LIFE_MAXIMUM)
    ld      b, a
    ld      c, #0x70
    call    GamePrintMeter

    ; パワーの描画
    ld      hl, #(_patternName + 0x00d8)
    ld      a, (_player + PLAYER_POWER)
    ld      b, a
    ld      c, #0x60
    call    GamePrintMeter

    ; レジストの描画
    ld      hl, #(_patternName + 0x00f8)
    ld      a, (_player + PLAYER_RESIST)
    ld      b, a
    ld      c, #0x70
    call    GamePrintMeter

    ; 経験値の描画
    ld      hl, #(_patternName + 0x0138)
    ld      a, (_player + PLAYER_EXPERIENCE_POINT)
    ld      b, a
    ld      c, #0x68
    call    GamePrintMeter
    ld      hl, #(_patternName + 0x0158)
    ld      b, #PLAYER_EXPERIENCE_MAXIMUM
    ld      c, #0x70
    call    GamePrintMeter

    ; アイテムの描画
    ld      hl, #(_player + PLAYER_KEY)
    ld      de, #(gameStatusItemPatternName + ITEM_KEY)
    ld      bc, #(_patternName + 0x01f8)
    ld      a, #(ITEM_CANDLE - ITEM_KEY + 0x01)
40$:
    push    af
    ld      a, (hl)
    or      a
    jr      z, 42$
    and     #PLAYER_ITEM_ANIMATION_CYCLE
    jr      z, 41$
    ld      a, (de)
41$:
    ld      (bc), a
    inc     bc
42$:
    inc     hl
    inc     de
    pop     af
    dec     a
    jr      nz, 40$

    ; クリスタルの描画
    ld      hl, #(_player + PLAYER_CRYSTAL_RED)
    ld      de, #(gameStatusItemPatternName + ITEM_CRYSTAL_RED)
    ld      bc, #(_patternName + 0x0258)
    ld      a, #(ITEM_CRYSTAL_WHITE - ITEM_CRYSTAL_RED + 0x01)
50$:
    push    af
    ld      a, (hl)
    or      a
    jr      z, 52$
    and     #PLAYER_ITEM_ANIMATION_CYCLE
    jr      z, 51$
    ld      a, (de)
51$:
    ld      (bc), a
    inc     bc
52$:
    inc     hl
    inc     de
    pop     af
    dec     a
    jr      nz, 50$

    ; レジスタの復帰

    ; 終了
    ret

; メータを描画する
;
GamePrintMeter:

    ; レジスタの保存
    push    hl

    ; hl < 描画位置
    ; c  < メータのパターンネーム
    ; b  < メータの長さ

    ; パターンネームの描画
    push    bc
10$:
    ld      a, b
    sub     #0x08
    jr      c, 11$
    ld      b, a
    ld      a, c
    add     a, #0x07
    ld      (hl), a
    inc     hl
    jr      10$
11$:
    ld      a, b
    or      a
    jr      z, 12$
    add     a, c
    dec     a
    ld      (hl), a
    inc     hl
12$:
    pop     bc
    ld      a, #0x38
    sub     b
    srl     a
    srl     a
    srl     a
    jr      z, 19$
13$:
    ld      (hl), #0x00
    inc     hl
    dec     a
    jr      nz, 13$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 開始画面を描画する
;
GamePrintStart:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameStartPatternName
    ld      de, #(_patternName + 0x0183)
    ld      bc, #0x0012
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームオーバー画面を描画する
;
GamePrintOver:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameOverPatternName
    ld      de, #(_patternName + 0x0187)
    ld      bc, #0x000a
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; クリア画面を描画する
;
GamePrintClearOpen:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameClearPatternNameOpen
    ld      de, #(_patternName + 0x0183)
    ld      bc, #0x0013
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

GamePrintClearContinue:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameClearPatternNameContinue
    ld      de, #(_patternName + 0x0184)
    ld      bc, #0x0012
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; フェードを描画する
;
GamePrintFade:

    ; レジスタの保存

    ; フェードの取得
    ld      a, (_game + GAME_FADE)
    ld      c, a

    ; 上辺の塗りつぶし
    ld      a, (_camera + CAMERA_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    sub     c
    jr      c, 19$
    jr      z, 19$
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)
    ld      b, a
    xor     a
10$:
    push    bc
    ld      b, #CAMERA_VIEW_SIZE_X
11$:
    ld      (hl), a
    inc     hl
    djnz    11$
    ld      bc, #(0x0020 - CAMERA_VIEW_SIZE_X)
    add     hl, bc
    pop     bc
    djnz    10$
;   jr      19$
19$:

    ; 下辺の塗りつぶし
    ld      a, (_camera + CAMERA_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, c
    sub     d
    and     #(FIELD_SIZE_Y - 0x01)
    cp      #CAMERA_VIEW_SIZE_Y
    jr      nc, 29$
    ld      b, a
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)
    add     hl, de
    ld      a, #CAMERA_VIEW_SIZE_Y
    sub     b
    ld      b, a
    xor     a
20$:
    push    bc
    ld      b, #CAMERA_VIEW_SIZE_X
21$:
    ld      (hl), a
    inc     hl
    djnz    21$
    ld      bc, #(0x0020 - CAMERA_VIEW_SIZE_X)
    add     hl, bc
    pop     bc
    djnz    20$
;   jr      29$
29$:

    ; 左辺の塗りつぶし
    ld      a, (_camera + CAMERA_POSITION_X)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_X)
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    sub     c
    jr      c, 39$
    jr      z, 39$
    push    bc
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)
    ld      c, a
    ld      b, #CAMERA_VIEW_SIZE_Y
    xor     a
30$:
    push    bc
    push    hl
    ld      b, c
31$:
    ld      (hl), a
    inc     hl
    djnz    31$
    pop     hl
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    djnz    30$
    pop     bc
;   jr      39$
39$:

    ; 右辺の塗りつぶし
    ld      a, (_camera + CAMERA_POSITION_X)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, c
    sub     e
    and     #(FIELD_SIZE_X - 0x01)
    cp      #CAMERA_VIEW_SIZE_X
    jr      nc, 49$
    push    bc
    ld      b, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_patternName + CAMERA_VIEW_PATTERN_NAME_OFFSET)
    add     hl, de
    ld      a, #CAMERA_VIEW_SIZE_X
    sub     b
    ld      c, a
    ld      b, #CAMERA_VIEW_SIZE_Y
    xor     a
40$:
    push    bc
    push    hl
    ld      b, c
41$:
    ld      (hl), a
    inc     hl
    djnz    41$
    pop     hl
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    djnz    40$
    pop     bc
;   jr      49$
49$:

    ; レジスタの復帰

    ; 終了
    ret

; パスワードを描画する
;
GamePrintPassword:

    ; レジスタの保存

    ; hl < パスワード

    ; ウィンドウの描画
    push    hl
    ld      hl, #gamePasswordPatternName
    ld      de, #(_patternName + 0x0125)
    ld      bc, #0x000e
    ldir
    ld      de, #(_patternName + 0x0145)
    ld      bc, #0x000e
    ldir
    ld      de, #(_patternName + 0x0165)
    ld      bc, #0x000e
    ldir
    ld      de, #(_patternName + 0x0185)
    ld      bc, #0x000e
    ldir
    ld      de, #(_patternName + 0x01a5)
    ld      bc, #0x000e
    ldir
    pop     hl

    ; パスワードの描画
    ld      de, #(_patternName + 0x0167)
    ld      b, #APP_PASSWORD_LENGTH
10$:
    ld      a, (hl)
    sub     #0x20
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameBuild
    .dw     GameStart
    .dw     GameField
    .dw     GameEntrance
    .dw     GameHole
    .dw     GameDungeon
    .dw     GameOver
    .dw     GameClear
    .dw     GamePassword
    .dw     GameDebug

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_FADE_NULL
    .db     GAME_SPRITE_MASK_NULL
    .dw     GAME_SPRITE_GENERATOR_NULL
    .dw     GAME_RANDOM_NULL

; スクリーン
;
gameScreenPatternName:

    .db     0x50, 0x40, 0x41, 0x00, 0x12, 0x42, 0x43, 0x54, 0x40, 0x41, 0x00, 0x03, 0x42, 0x43, 0x51
    .db     0x48,             0x00, 0x16,             0x56,             0x00, 0x07,             0x4a
    .db     0x49,             0x00, 0x16,             0x4b, 0x2c, 0x29, 0x26, 0x25, 0x00, 0x03, 0x4b
;   .db     0x49,             0x00, 0x1e,                                                       0x4b
    .db     0x00, 0x40
    .db     0x00, 0x18,                                     0x30, 0x2f, 0x37, 0x25, 0x32, 0x00, 0x03
    .db     0x00, 0x40
    .db     0x00, 0x18,                                     0x25, 0x38, 0x30, 0x00, 0x05
    .db     0x00, 0x60
    .db     0x00, 0x19,                                     0x42, 0x43, 0x54, 0x40, 0x41, 0x00, 0x02
    .db     0x00, 0x20
    .db     0x00, 0x18,                                     0x29, 0x34, 0x25, 0x2d, 0x00, 0x04
    .db     0x00, 0x40
    .db     0x00, 0x18,                                     0x23, 0x32, 0x39, 0x33, 0x34, 0x21, 0x2c, 0x00, 0x01
    .db     0x00, 0x60
    .db     0x4d,             0x00, 0x16,             0x4f,             0x00, 0x07,             0x4f
;   .db     0x4d,             0x00, 0x1e,                                                       0x4f
    .db     0x4c,             0x00, 0x16,             0x57,             0x00, 0x07,             0x4e
    .db     0x52, 0x44, 0x45, 0x00, 0x12, 0x46, 0x47, 0x55, 0x44, 0x45, 0x00, 0x03, 0x46, 0x47, 0x53
    .db     0xff

; ステータス
;
gameStatusItemPatternName:

    .db     0x00
    .db     0x90, 0xb8, 0xf1, 0xd2, 0xa9
    .db     0xd3, 0x91, 0xf2, 0xb9, 0x92

; 開始
;
gameStartPatternName:

    .db     0x33, 0x34, 0x32, 0x29, 0x2b, 0x25, 0x00, 0x21, 0x34, 0x00, 0x24, 0x21, 0x32, 0x2b, 0x2e, 0x25, 0x33, 0x33

; ゲームオーバー
;
gameOverPatternName:

    .db     0x27, 0x21, 0x2d, 0x25, 0x00, 0x00, 0x2f, 0x36, 0x25, 0x32

; クリア
;
gameClearPatternNameOpen:

    .db     0x34, 0x28, 0x25, 0x00, 0x27, 0x21, 0x34, 0x25, 0x00, 0x37, 0x21, 0x33, 0x00, 0x2f, 0x30, 0x25, 0x2e, 0x25, 0x24
    
gameClearPatternNameContinue:

    .db     0x34, 0x2f, 0x00, 0x22, 0x25, 0x00, 0x23, 0x2f, 0x2e, 0x34, 0x29, 0x2e, 0x35, 0x25, 0x24, 0x78, 0x79, 0x7a

; パスワード
;
gamePasswordPatternName:

    .db     0x88, 0x8e, 0x30, 0x21, 0x33, 0x33, 0x37, 0x2f, 0x32, 0x24, 0x8f, 0x8c, 0x8c, 0x89
    .db     0x8d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8d
    .db     0x8d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8d
    .db     0x8d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8d
    .db     0x8a, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8b


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::
    
    .ds     GAME_LENGTH

; スプライト
;
_gameSpriteGenerator::

    .ds     GAME_SPRITE_GENERATOR_LENGTH
