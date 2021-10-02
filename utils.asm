!ifndef UTILS {
  UTILS = 1
 
!macro push_axy
  pha
  tya
  pha
  txa
  pha
!end

!macro exchange_xy ; use all registers including accu, exchanges the x and y reg values
  tya
  pha ; y is now on the stack
  txa ; move x to a, and y to y, so move x to y
  tay
  pla ; pull y and move to x
  tax
!end

!macro pop_axy
  pla
  tax
  pla
  tay
  pla
!end

!macro push_ay
  pha
  tya
  pha
!end

!macro pop_ay
  pla
  tay
  pla
!end

!macro pop_func_params
  sta FUNC_pop_push_STACK_A
  
  pla
  sta FUNC_PARAM_9
  pla
  sta FUNC_PARAM_8
  pla
  sta FUNC_PARAM_7
  pla
  sta FUNC_PARAM_6
  pla
  sta FUNC_PARAM_5
  pla
  sta FUNC_PARAM_4
  pla
  sta FUNC_PARAM_3
  pla
  sta FUNC_PARAM_2
  pla
  sta FUNC_PARAM_1
  
  lda FUNC_pop_push_STACK_A
!end

!macro push_func_params
  sta FUNC_pop_push_STACK_A
  
  lda FUNC_PARAM_1
  pha
  lda FUNC_PARAM_2
  pha
  lda FUNC_PARAM_3
  pha
  lda FUNC_PARAM_4
  pha
  lda FUNC_PARAM_5
  pha
  lda FUNC_PARAM_6
  pha
  lda FUNC_PARAM_7
  pha
  lda FUNC_PARAM_8
  pha
  lda FUNC_PARAM_9
  pha
  
  lda FUNC_pop_push_STACK_A
!end

!macro push_xy
  sta FUNC_pop_push_STACK_A
  tya
  pha
  txa
  pha
  lda FUNC_pop_push_STACK_A
!end

!macro pop_xy
  sta FUNC_pop_push_STACK_A
  pla
  tax
  pla
  tay
  lda FUNC_pop_push_STACK_A
!end

jmp eof_utils

wait_trace
  lda #$ff
  cmp $d012 
  bne wait_trace
  rts
  
wait_trace_times
  jsr wait_trace
  dey
  bne wait_trace_times
  rts
 
reset_seconds_timer
  pha
  lda #0
  sta CIA1_CLOCK_SECONDS
  pla
  rts
  
reset_10th_timer
  pha
  lda #0
  sta CIA1_CLOCK_TENTH
  pla
  rts
  
!macro inc_a
  clc
  adc #1
!end

!macro dec_a
  sec
  sbc #1
!end

!zone inc_clamp_AV
!macro inc_clamp_AV aIncValueToClamp, vClamp
  pha
  inc aIncValueToClamp
  lda aIncValueToClamp
  cmp #vClamp
  bne .end
  lda #0
  sta aIncValueToClamp
.end
  pla
!end

!zone loop_clamp_AVA
!macro loop_clamp_AVA aIncValueToClamp, vClamp, aDirection
  pha
  lda aDirection
  bmi .doMinus ; on minus decrease
  ; do plus
.doPlus
  inc aIncValueToClamp
  lda aIncValueToClamp
  cmp #vClamp
  bne .end
  lda #-1
  sta aDirection ; when reaching the end, loop backwards
  ; as we exceed the clamp value -> immediately decrease
  ; but decrease twice, so we stay in the smooth anim,
  ; else the vClamp -1 max value would stay 2 cycles
  dec aIncValueToClamp
.doMinus
  dec aIncValueToClamp
  lda aIncValueToClamp
  cmp #0
  bne .end
  lda #1
  sta aDirection
.end
  pla
!end


!zone loop_clamp_RegBZPBRegC
loop_clamp_RegBZPBRegC ; RegB: aIncValueToClamp, ZeroPageByte: vClamp, RegC: aDirection
  pha
  +lda_P REGISTER_16_C
  bmi .doMinus ; on minus decrease
  ; do plus
.doPlus
  ; increase the value at the adress regB points to
  +lda_P REGISTER_16_B
  clc
  adc #1
  sta (POINTER),y
  ;inc aIncValueToClamp
  cmp ZERO_PAGE_BYTE
  bne .end
  lda #-1
  +sta_P REGISTER_16_C
  ;sta aDirection ; when reaching the end, loop backwards
  ; as we exceed the clamp value -> immediately decrease
  ; but decrease twice, so we stay in the smooth anim,
  ; else the vClamp -1 max value would stay 2 cycles
  ;dec aIncValueToClamp
  +lda_P REGISTER_16_B
  sec
  sbc #1
  sta (POINTER),y
.doMinus
  ; decrease the value at the adress regB points to
  +lda_P REGISTER_16_B
  sec
  sbc #1
  sta (POINTER),y
  ;dec aIncValueToClamp
  cmp #0
  bne .end
  lda #1
  ;sta aDirection
  +sta_P REGISTER_16_C
.end
  pla
  rts

eof_utils
}
