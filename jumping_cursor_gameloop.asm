jmp eof_jumping_cursor_gameloop

jumping_cursor_init
  pha
  
  
  pla
  rts

!zone jumping_cursor_loop
jumping_cursor_loop
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
  jmp jumping_cursor_loop
  
  rts
  
eof_jumping_cursor_gameloop