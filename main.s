.segment "INES"
.byte "NES",26;
.byte 1 ; 1 prg bank
.byte 0 ; 0 chr banks

.segment "PRG"
TestState             = $10
TestPhase             = $11
TestIRQFail           = $12
PPUCTRL               = $2000
PPUMASK               = $2001
PPUSTATUS             = $2002
PPUSCROLL             = $2005
PPUADDR               = $2006
PPUDATA               = $2007
SNDCHN                = $4015
JOYPAD_PORT           = $4016

FDS_LoadFiles            = $E1F8
FDS_AppendFile           = $E237
FDS_WriteFile            = $E239
FDS_CheckFileCount       = $E2B7
FDS_AdjustFileCount      = $E2BB
FDS_SetFileCount1        = $E301
FDS_SetFileCount         = $E305
FDS_GetDiskInfo          = $E32A
FDS_CheckDiskHeader      = $E445
FDS_GetNumFiles          = $E484
FDS_SetNumFiles          = $E492
FDS_FileMatchTest        = $E4A0
FDS_SkipFiles            = $E4DA
FDS_Delay132             = $E149
FDS_Delayms              = $E153
FDS_DisPFObj             = $E161
FDS_EnPFObj              = $E16B
FDS_DisObj               = $E171
FDS_EnObj                = $E178
FDS_DisPF                = $E17E
FDS_EnPF                 = $E185
FDS_VINTWait             = $E1B2
FDS_VRAMStructWrite      = $E7BB
FDS_FetchDirectPtr       = $E844
FDS_WriteVRAMBuffer      = $E86A
FDS_ReadVRAMBuffer       = $E8B3
FDS_PrepareVRAMString    = $E8D2
FDS_PrepareVRAMStrings   = $E8E1
FDS_GetVRAMBufferByte    = $E94F
FDS_Pixel2NamConv        = $E97D
FDS_Nam2PixelConv        = $E997
FDS_Random               = $E9B1
FDS_SpriteDMA            = $E9C8
FDS_CounterLogic         = $E9D3
FDS_ReadPads             = $E9EB
FDS_OrPads               = $EA0D
FDS_ReadDownPads         = $EA1A
FDS_ReadOrDownPads       = $EA1F
FDS_ReadDownVerifyPads   = $EA36
FDS_ReadOrDownVerifyPads = $EA4C
FDS_ReadDownExpPads      = $EA68
FDS_VRAMFill             = $EA84
FDS_MemFill              = $EAD2
FDS_SetScroll            = $EAEA
FDS_JumpEngine           = $EAFD
FDS_ReadKeyboard         = $EB13
FDS_LoadTileset          = $EBAF
FDS_UploadObject         = $EC22
FDS_Reset                = $EE24

FDSReg_DiskStatus        = $4032
FDSReg_Control           = $4025
FDSReg_IO                = $4023
FDSReg_TimerCtl          = $4022



.org $8000

RuntimeLocation = $300
RuntimeStart = Runtime - RuntimeLocation

V_REBOOT:
    sei                                     ; basic startup
    ldx #$FF                                ;
    txs                                     ;
    
    lda #%01000000
    sta $4017                               ; disable APU IRQ
    stx $4010                               ; disable DPCM
    inx
    stx $4015                               ; set sound channels

    ldx #0                                  ; disable ppu
	stx PPUCTRL                             ;
	stx PPUMASK                             ;
    ldy #0                                  ; clear out ram
    lda #0                                  ;
:   sta $000,y                              ;
    sta $100,y                              ;
    sta $200,y                              ;
    sta $300,y                              ;
    sta $400,y                              ;
    sta $500,y                              ;
    sta $600,y                              ;
    sta $700,y                              ;
    iny                                     ;
    bne :-                                  ;
    ldx #0                                  ; copy runtime code to ram
:   lda Runtime,x                           ;
    sta RuntimeLocation,x                   ;
    inx                                     ;
    bne :-                                  ;
:   lda Runtime+$100,x                      ;
    sta RuntimeLocation+$100,x              ;
    inx                                     ;
    bne :-                                  ;
:   lda Runtime+$200,x                      ;
    sta RuntimeLocation+$200,x              ;
    inx                                     ;
    bne :-                                  ;

    lda #%01000000
    sta $4017                               ; disable APU IRQ
    ldx #$00
    stx $2000                               ; disable PPU output
    stx $2001
    stx $4010                               ; disable DPCM
    inx
    stx $4015                               ; set sound channels

    jmp Runtime-RuntimeStart                ; then jump to runtime code

V_IRQ:
    bit $4015
V_NMI:
    rti

Runtime:
@Start:
    ldx #1                         ;
    stx $FF                        ;
    stx JOYPAD_PORT                ; read joypad into $FF
    dex                            ;
    stx JOYPAD_PORT                ;
    clc                            ;
:   lda JOYPAD_PORT                ;
    lsr a                          ;
    rol $FF                        ;
    bcc :-                         ;
    lda $FF                        ;
    beq @Start                     ; loop until a button is pressed

    lda #%10011111                 ; produce a beep so you know something happened
    sta $4000                      ;
    lda #%00000000                 ;
    sta $4001                      ;
    lda #%11111011                 ;
    sta $4002                      ;
    lda #%11111011                 ;
    sta $4003                      ;

    lda #0
    sta FDSReg_TimerCtl            ; disable IRQ timer
    sta FDSReg_IO                  ; disable FDS sound/disk IRQ
    lda #$83
    sta FDSReg_IO                  ; reenable FDS sound/disk IRQ
    lda #$2E
    sta FDSReg_Control             ; stop disk and set read mode

:   lda FDSReg_DiskStatus
    and #$01
    bne :-
    lda FileNo-RuntimeStart             ; write file slot
    jsr FDS_WriteFile                   ; call FDS BIOS WriteFile
    .addr DiskIDString-RuntimeStart     ; ptr to disk security string 
    .addr SaveFileHeader-RuntimeStart   ; ptr to file data
    jmp ($FFFC)

.include "patch.s"


.segment "VEC"
.word V_NMI
.word V_REBOOT
.word V_IRQ
