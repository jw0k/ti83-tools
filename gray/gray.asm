.NOLIST
#define equ .equ
#define EQU .equ
#define end .end

#define    b_call(xxxx)        rst 28h    \ .dw xxxx

#include "ti83asm.inc"
#include "tokens.inc"
.LIST

.org 9327h

    di

    call _runIndicOff

    call _ClrLCDFull

    ld A, $07 ;set Y auto-increment
    out ($10), A
    call _lcd_busy

    ;ld A, $03
    ;out ($10), A
    ;call _lcd_busy

mainLoop:
    ld a, $FD ;enter, +, -, x, /, ^, clear
    out (1), A
    nop
    nop
    in A, (1)
    cp $BF ;clear
    jp z, quit

    ld A, $FE ;down, left, right, up
    out (1), A
    nop
    nop
    in A, (1)
    cp $FE ;down
    jp z, decreaseFast
    cp $F7 ;up
    jp z, increaseFast
    cp $FD ;left
    jp z, decreaseSlow
    cp $FB ;right
    jp z, increaseSlow
    jp draw

increaseFast:
    ld HL, (modeTimerStartValueForFast)
    ld (modeTimer), HL

    ld HL, (delayFast)
    ld (quitDelay), HL

    ld BC, (delayValue)
    inc BC
    ld (delayValue), BC
    jp draw

decreaseFast:
    ld HL, (modeTimerStartValueForFast)
    ld (modeTimer), HL

    ld HL, (delayFast)
    ld (quitDelay), HL

    ld BC, (delayValue)
    dec BC
    ld A, B
    or C
    jp nz, storeLoweredDelayFast
    inc BC
storeLoweredDelayFast:
    ld (delayValue), BC
    jp draw

increaseSlow:
    ld HL, (modeTimerStartValueForSlow)
    ld (modeTimer), HL

    ld HL, (delaySlow)
    ld (quitDelay), HL

    ld BC, (delayValue)
    inc BC
    ld (delayValue), BC
    jp draw

decreaseSlow:
    ld HL, (modeTimerStartValueForSlow)
    ld (modeTimer), HL

    ld HL, (delaySlow)
    ld (quitDelay), HL

    ld BC, (delayValue)
    dec BC
    ld A, B
    or C
    jp nz, storeLoweredDelaySlow
    inc BC
storeLoweredDelaySlow:
    ld (delayValue), BC

draw:
    ld HL, (modeTimer)
    ld A, H
    or L
    jp z, drawImage

    dec HL
    ld (modeTimer), HL

    ld A, $05 ;set X auto-increment
    out ($10), A
    call _lcd_busy

    ld A, 3
    ld (CURROW), A
    ld A, 4
    ld (CURCOL), A
    ld HL, (delayValue)
    push HL
    call _dispHL

    ld A, $07 ;set Y auto-increment
    out ($10), A
    call _lcd_busy

    ld HL, (quitDelay)
    ld (delayValue), HL
    call delay

    pop HL
    ld (delayValue), HL

    jp mainLoop

drawImage:
    ld BC, dark
    call display
    call delay

    ld BC, dark
    call display
    call delay

    ld BC, light
    call display
    call delay

    jp mainLoop

    ;call _getkey

quit:
    call _ClrLCDFull

    ei

    ret

display:
    ld E, $80
imageLoop:
    ld D, 0

    ld A, $20 ;set column ($20 = 0, $2E = 14)
    out ($10), A
    ex (SP), HL ;instead of call _lcd_busy (2x ex (SP), HL takes 38 t-states)
    ex (SP), HL

    ld A, E ;set row ($80 = 0, $BF = 63)
    out ($10), A
    ex (SP), HL
    ex (SP), HL

singleRow:
    ld A, (BC) ;7 t-states
    out ($11), A
    ;call _lcd_busy
    inc BC ;6 t-states
    inc D ;4 t-states
    ld A, 12 ;7 t-states
    cp D ;4 t-states
    jp nz, singleRow ;10 t-states
    inc E
    ld A, $C0
    cp E
    jp nz, imageLoop
    ret

delay:
    ld DE, (delayValue)
delayLoop
    dec DE
    ld A, D
    or E
    jp nz, delayLoop
    ret

delayValue:
    .dw 2216

modeTimer:
    .dw 0

modeTimerStartValueForFast:
    .dw 100

modeTimerStartValueForSlow:
    .dw 3

delayFast:
    .dw 1000

delaySlow:
    .dw 40000

quitDelay:
    .dw 0


;an elephant :)
dark:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$21,$5E,$80,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$C2,$0A,$40,$00,$00,$00,$00
    .db $00,$00,$00,$00,$03,$01,$60,$C0,$00,$00,$00,$00
    .db $00,$00,$00,$0C,$07,$A0,$34,$20,$00,$00,$00,$00
    .db $00,$00,$00,$75,$06,$88,$30,$00,$00,$00,$00,$00
    .db $00,$00,$01,$28,$8E,$90,$10,$00,$00,$00,$00,$00
    .db $00,$00,$00,$42,$4C,$40,$18,$1C,$00,$00,$00,$00
    .db $00,$00,$00,$10,$07,$A8,$1A,$37,$00,$00,$00,$00
    .db $00,$00,$07,$84,$8D,$65,$1F,$FF,$40,$00,$00,$00
    .db $00,$00,$2A,$FD,$5F,$D8,$0F,$FB,$80,$00,$00,$00
    .db $00,$00,$7F,$FE,$DC,$E5,$CF,$F9,$C0,$00,$00,$00
    .db $00,$00,$BF,$FF,$DF,$38,$6F,$FA,$20,$00,$00,$00
    .db $00,$01,$FF,$FF,$FF,$E4,$BF,$D0,$A0,$00,$00,$00
    .db $00,$01,$FF,$FF,$FF,$F0,$7F,$F0,$00,$00,$00,$00
    .db $00,$01,$FF,$FF,$FF,$F3,$DF,$FD,$20,$00,$00,$00
    .db $00,$03,$FF,$FF,$FF,$F9,$FF,$FA,$B0,$00,$00,$00
    .db $00,$07,$FF,$FF,$FF,$FE,$0F,$FF,$A0,$00,$00,$00
    .db $00,$07,$FF,$FF,$FF,$BF,$0F,$87,$F8,$00,$00,$00
    .db $00,$07,$FF,$FF,$FF,$FF,$EE,$80,$F8,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FE,$80,$78,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$00,$78,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$18,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$80,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$C0,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$F0,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$F0,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$F0,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FC,$01,$E0,$00,$00,$00
    .db $00,$0F,$FF,$FF,$FF,$FF,$FE,$01,$E0,$00,$00,$00
    .db $00,$1F,$FF,$FF,$FF,$FF,$FE,$01,$E0,$00,$00,$00
    .db $00,$1F,$FF,$FF,$FB,$FF,$FE,$03,$C0,$00,$00,$00
    .db $00,$1F,$FF,$FF,$E3,$FD,$FE,$03,$C0,$00,$00,$00
    .db $00,$1F,$FF,$FE,$01,$FD,$FF,$03,$80,$00,$00,$00
    .db $00,$2F,$F7,$FE,$01,$FC,$FF,$07,$80,$00,$00,$00
    .db $00,$3F,$E3,$FC,$01,$FC,$FF,$07,$80,$00,$00,$00
    .db $00,$3F,$C0,$FC,$00,$FC,$7F,$87,$00,$00,$00,$00
    .db $00,$3F,$80,$FC,$00,$FC,$3F,$8F,$00,$00,$00,$00
    .db $00,$3F,$80,$FC,$00,$FC,$1F,$8E,$00,$00,$00,$00
    .db $00,$3F,$00,$FC,$00,$FC,$0F,$CE,$00,$00,$00,$00
    .db $00,$3F,$00,$FC,$00,$FC,$0F,$DE,$00,$00,$00,$00
    .db $00,$3F,$01,$FF,$80,$FC,$07,$FC,$00,$00,$00,$00
    .db $00,$3F,$01,$FF,$E9,$FE,$07,$FC,$00,$00,$00,$00
    .db $00,$33,$49,$FD,$FB,$FE,$17,$FC,$00,$00,$00,$00
    .db $00,$20,$C0,$FC,$FF,$FD,$1F,$F8,$00,$00,$00,$00
    .db $00,$00,$8C,$D4,$4D,$ED,$7F,$F8,$00,$00,$00,$00
    .db $00,$00,$20,$00,$00,$38,$FF,$F8,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$08,$2F,$FF,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$03,$FF,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$03,$40,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

light:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$1F,$E0,$E0,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$5E,$A1,$7C,$00,$00,$00,$00
    .db $00,$00,$00,$00,$01,$3D,$F5,$BC,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$FE,$9F,$3E,$00,$00,$00,$00
    .db $00,$00,$00,$73,$00,$5F,$EB,$D7,$00,$00,$00,$00
    .db $00,$00,$00,$8A,$F9,$77,$8F,$F3,$00,$00,$00,$00
    .db $00,$00,$06,$D7,$71,$6F,$EF,$FF,$80,$00,$00,$00
    .db $00,$00,$0F,$BD,$B3,$BF,$C7,$E3,$C0,$00,$00,$00
    .db $00,$00,$1F,$EF,$F8,$57,$E5,$F8,$C0,$00,$00,$00
    .db $00,$00,$38,$7B,$72,$9A,$E0,$00,$80,$00,$00,$00
    .db $00,$00,$55,$02,$A8,$27,$F0,$84,$60,$00,$00,$00
    .db $00,$00,$80,$01,$2F,$1A,$30,$66,$20,$00,$00,$00
    .db $00,$00,$40,$00,$2E,$C7,$90,$05,$D0,$00,$00,$00
    .db $00,$00,$00,$00,$07,$9B,$40,$2F,$50,$00,$00,$00
    .db $00,$02,$00,$00,$07,$EF,$80,$0F,$F0,$00,$00,$00
    .db $00,$06,$00,$00,$07,$FC,$2F,$92,$D8,$00,$00,$00
    .db $00,$04,$24,$00,$83,$FE,$0F,$F5,$48,$00,$00,$00
    .db $00,$08,$60,$80,$00,$1D,$FF,$F0,$58,$00,$00,$00
    .db $00,$08,$3A,$00,$00,$5E,$F6,$C8,$00,$00,$00,$00
    .db $00,$08,$34,$00,$00,$1F,$D6,$00,$00,$00,$00,$00
    .db $00,$00,$1E,$00,$40,$0F,$FC,$02,$80,$00,$00,$00
    .db $00,$00,$18,$00,$10,$07,$FE,$00,$00,$00,$00,$00
    .db $00,$00,$1D,$00,$10,$01,$FE,$00,$20,$00,$00,$00
    .db $00,$0C,$1C,$00,$18,$00,$F2,$01,$8C,$00,$00,$00
    .db $00,$08,$DF,$90,$18,$00,$72,$01,$F2,$00,$00,$00
    .db $00,$00,$6F,$E8,$98,$02,$F2,$01,$D8,$80,$00,$00
    .db $00,$00,$9F,$FA,$9A,$03,$F2,$00,$E0,$00,$00,$00
    .db $00,$02,$BF,$FF,$BC,$A7,$F2,$00,$E0,$00,$00,$00
    .db $00,$1D,$5F,$FF,$EC,$03,$C6,$03,$70,$00,$00,$00
    .db $41,$1E,$EF,$FF,$FC,$43,$84,$03,$60,$00,$00,$00
    .db $03,$0B,$5B,$FF,$FC,$8B,$04,$02,$40,$00,$00,$00
    .db $00,$9F,$FF,$FF,$FE,$F5,$CE,$00,$60,$00,$00,$00
    .db $D0,$2F,$FF,$FF,$11,$6E,$EF,$00,$80,$00,$00,$00
    .db $16,$AF,$FF,$FF,$03,$FE,$D6,$04,$C0,$00,$00,$00
    .db $A4,$1F,$FF,$FC,$E1,$EF,$F7,$80,$D2,$00,$04,$00
    .db $8C,$8F,$F1,$FE,$24,$A6,$6D,$B9,$22,$A9,$01,$44
    .db $6D,$4F,$99,$FD,$C5,$AE,$2D,$29,$A1,$14,$A2,$21
    .db $B7,$7F,$BF,$49,$E9,$DE,$15,$C2,$08,$45,$6E,$AE
    .db $AD,$5B,$3E,$4B,$E5,$FE,$B6,$D3,$25,$2A,$2A,$3D
    .db $F3,$48,$AF,$4B,$F5,$FE,$72,$13,$4A,$91,$52,$57
    .db $FB,$1C,$9F,$43,$F7,$7F,$24,$64,$B0,$88,$93,$21
    .db $7E,$90,$FF,$46,$7F,$FB,$CF,$C6,$EB,$B6,$30,$5F
    .db $7F,$10,$FE,$E2,$16,$7D,$FB,$C1,$C7,$61,$57,$D7
    .db $BF,$4C,$B6,$C2,$84,$39,$EB,$CB,$D4,$D7,$76,$2D
    .db $FD,$DF,$3F,$43,$10,$0A,$E3,$EF,$FF,$DB,$F3,$BA
    .db $6F,$EF,$73,$2B,$B2,$1A,$9D,$C7,$EF,$F7,$EB,$B7
    .db $56,$FB,$DF,$FF,$DF,$C7,$0F,$C7,$FF,$AD,$FD,$5D
    .db $8D,$DF,$7F,$F7,$D5,$F7,$D6,$48,$FF,$FF,$DF,$EB
    .db $AF,$D9,$FE,$FA,$3E,$FF,$FC,$04,$FF,$BF,$FF,$7F
    .db $AF,$F5,$7F,$BF,$B2,$EF,$FC,$BF,$D7,$B7,$DF,$FF
    .db $AF,$FA,$FE,$97,$73,$6D,$FF,$FE,$FA,$4D,$BF,$FA
    .db $57,$F8,$3F,$3B,$F4,$6E,$BB,$ED,$63,$8D,$FF,$7F
    .db $B3,$7F,$FE,$BE,$E5,$7B,$DE,$ED,$7B,$D7,$FF,$FF
    .db $E7,$6B,$66,$4F,$77,$7D,$7F,$3F,$3E,$FD,$FF,$7F
