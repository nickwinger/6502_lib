!source "vars.asm"
!source "utils.asm"
!source "graphics.asm"
!source "input.asm"

jmp eof_control

!zone move_player
move_player
  pha
  
  lda PLAYER_DIRECTION
  cmp #UP
  bne .next1
  lda #$15
  sta SCREEN+10
  jsr MOVE_UP
.next1
  lda PLAYER_DIRECTION
  cmp #DOWN
  bne .next2
  lda #$4
  sta SCREEN+10
  jsr MOVE_DOWN
.next2
  lda PLAYER_DIRECTION
  cmp #LEFT
  bne .next3
  lda #$c
  sta SCREEN+10
  jsr MOVE_LEFT
.next3
  lda PLAYER_DIRECTION
  cmp #RIGHT
  bne .next4
  lda #$12
  sta SCREEN+10
  jsr MOVE_RIGHT
.next4
  pla
  rts
  
player_direction_changed
  pha
  LDA $D404
  jsr print_a
  pla
  ;jsr stop_voice1
  ;nop
  ;jsr cycle_motor
  ;jsr play_voice1
  rts

!zone check_keys
check_keys
  sei
  pha
  
  lda KEY_REG_B
  and #JOY_UP
  bne .loop1
  lda #UP
  cmp PLAYER_DIRECTION
  beq .loop1
  jsr player_direction_changed
  sta PLAYER_DIRECTION
.loop1
  lda KEY_REG_B
  and #JOY_DOWN
  bne .loop2
  lda #DOWN
  cmp PLAYER_DIRECTION
  beq .loop2
  jsr player_direction_changed
  sta PLAYER_DIRECTION
.loop2
  lda KEY_REG_B
  and #JOY_LEFT
  bne .loop3
  lda #LEFT
  cmp PLAYER_DIRECTION
  beq .loop3
  jsr player_direction_changed
  sta PLAYER_DIRECTION
.loop3
  lda KEY_REG_B
  and #JOY_RIGHT
  bne .loop4
  lda #RIGHT
  cmp PLAYER_DIRECTION
  beq .loop4
  jsr player_direction_changed
  sta PLAYER_DIRECTION
.loop4

  cli
  pla
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