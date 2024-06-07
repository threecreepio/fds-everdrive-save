
DiskIDString:
    .byte $01,$53,$4D,$42,$20,$00,$00,$00,$00,$00

FileNo:
    .byte 7

SaveFileHeader:
    .byte 15                                ; disk ID
    .byte "SM2SAVE "                        ; file name (8 chars)
    .word $D29F                             ; load address
    .word SaveFileDataEnd-SaveFileData      ; length of file
    .byte $00                               ; copy data from ram
    .addr SaveFileData-RuntimeStart         ; ptr to contents
    .byte $00

SaveFileData:
    .byte $04
SaveFileDataEnd:
