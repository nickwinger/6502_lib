jmp eof_liner_gameloop

liner_init
  pha
  jsr init_sound

  jsr show_title_screen

  
  ;lda #HEART
  ;sta VICSCREENRAM
  ;jsr wait_for_joystick_selection
  jsr wait_for_fire
  
  jsr init_playfield
  
  lda #UP
  sta PLAYER_DIRECTION
  
  jsr cycle_motor
  ;jsr play_voice1
  pla
  rts

!zone liner_loop
liner_loop
  jsr wait_trace
  
  lda GAME_LOOP_COUNTER
  cmp #4
  bne .continue
  lda #0
  sta GAME_LOOP_COUNTER
  jsr move_player
  
.continue
 
  jsr draw_player
  jsr check_keys
  
  
  inc GAME_LOOP_COUNTER
  jmp liner_loop
  
  rts
  
eof_liner_gameloop