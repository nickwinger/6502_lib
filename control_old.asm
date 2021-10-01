!source "vars.asm"

jmp eof_control

; KEYS
KEY_REG_A = $dc00
KEY_REG_B = $dc01
JOY_UP    = %00000001
JOY_DOWN  = %00000010
JOY_LEFT  = %00000100
JOY_RIGHT = %00001000

check_movement
  sei
  
  lda KEY_REG_B
  and #JOY_UP
  bne loop2_ct1
  jsr MOVE_UP
loop2_ct1
  lda KEY_REG_B
  and #JOY_DOWN
  bne loop2_ct2
  jsr MOVE_DOWN
loop2_ct2
  lda KEY_REG_B
  and #JOY_LEFT
  bne loop2_ct3
  jsr MOVE_LEFT
loop2_ct3
  lda KEY_REG_B
  and #JOY_RIGHT
  bne loop2_ct4
  jsr MOVE_RIGHT
loop2_ct4

  cli
  rts
  
MOVE_DOWN
  pha
  tya
  pha
  ldy #$2
  lda #$b2
  ;sta SCREEN, y
  
  clc
  lda #<SCREEN_WIDTH
  adc PLAYER_POS
  sta PLAYER_POS
  lda #>SCREEN_WIDTH
  adc PLAYER_POS+1
  sta PLAYER_POS+1
  pla
  tay
  pla
  rts
MOVE_UP
  pha
  tya
  pha
  ldy #$1
  lda #$b1
  ; SCREEN, y
  
  sec
  lda PLAYER_POS
  sbc #<SCREEN_WIDTH
  sta PLAYER_POS
  lda PLAYER_POS+1
  sbc #>SCREEN_WIDTH
  sta PLAYER_POS+1
  pla
  tay
  pla
  rts
MOVE_LEFT
  pha
  tya
  pha
  ldy #$3
  lda #$b3
  ;sta SCREEN, y
  
  clc
  dec PLAYER_POS
  
  pla
  tay
  pla
  rts
MOVE_RIGHT
  pha
  tya
  pha
  ldy #$3
  lda #$b3
  ;sta SCREEN, y
  
  clc
  inc PLAYER_POS
  
  pla
  tay
  pla
  rts  
  
  lda #CHAR
  ldx #$ff

eof_control