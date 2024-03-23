; Dungeon.inc : ダンジョン
;


; マクロの定義
;

; ダンジョン
DUNGEON_STATE                   =   0x00
DUNGEON_FLAG                    =   0x01
DUNGEON_COUNT                   =   0x02
DUNGEON_FRAME                   =   0x03
DUNGEON_GATE_STATE              =   0x04
DUNGEON_GATE_FRAME              =   0x05
DUNGEON_GATE_POSITION_X         =   0x06
DUNGEON_GATE_POSITION_Y         =   0x07
DUNGEON_LENGTH                  =   0x08

; 状態
DUNGEON_STATE_NULL              =   0x00

; フラグ
DUNGEON_FLAG_NULL               =   0x00

; カウント
DUNGEON_COUNT_NULL              =   0x00

; フレーム
DUNGEON_FRAME_NULL              =   0x00

; 扉
DUNGEON_GATE_STATE_NULL         =   0x00
DUNGEON_GATE_STATE_CLOSE        =   0x01
DUNGEON_GATE_STATE_OPEN         =   0x02
DUNGEON_GATE_FRAME_NULL         =   0x00
DUNGEON_GATE_FRAME_CLOSE        =   0x20
DUNGEON_GATE_FRAME_OPEN         =   0x20
DUNGEON_GATE_POSITION_NULL      =   0x00
DUNGEON_GATE_HEIGHT             =   0x20

; 位置
DUNGEON_POSITION_PLAYER_X       =   0x0b
DUNGEON_POSITION_PLAYER_Y       =   0x0e
DUNGEON_POSITION_GATE_X         =   0x0b
DUNGEON_POSITION_GATE_Y         =   0x08

; 外部関数宣言
;

    .globl  _DungeonInitialize
    .globl  _DungeonUpdate
    .globl  _DungeonRender
    .globl  _DungeonSetGate
    .globl  _DungeonIsGateOpen

; 外部変数宣言
;

    .globl  _dungeon
