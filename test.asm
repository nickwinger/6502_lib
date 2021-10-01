


SCREEN    = $0400
CHAR      = $53
FARBRAM   = $d800
FARBNR    = $00

*=$0801
!byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00

!source "graphics.asm"
!source "control.asm"

loop
  txa
  sta SCREEN-1,x
  dex
  bne loop
  
  
  lda #<farbadr
  sta $fb
  lda #>farbadr
  sta $fc
  
  ldy #$00
  lda ($fb),y
  
  ldx #$ff
farbloop
  sta FARBRAM-1,x
  dex
  bne farbloop
  rts
  
farbadr
  !byte $07,$0e,FARBNR,$01,$0a,$0f
  