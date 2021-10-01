;!ifndef POINTER {
;  POINTER = 1

POINTER = $fd  ; 16bit adress pointer
POINTER2 = $fb ; 16bit

  jmp eof_pointer

; loads the pointer by the value relative to the x register
!macro set_pointer_XA aValue
  pha
  lda aValue, x
  sta POINTER
  lda aValue+1,x
  sta POINTER+1
  pla
!end

!macro set_pointer adr    ; point pointer2 to adress
  pha
  lda #<adr
  sta POINTER
  lda #>adr
  sta POINTER+1
  pla
!end

!macro set_pointer_P pAdr    ; point pointer2 to adress where another pointer points to
  pha
  lda pAdr
  sta POINTER
  lda pAdr+1
  sta POINTER+1
  pla
!end

!macro set_pointer2 adr    ; point pointer2 to adress
  pha
  lda #<adr
  sta POINTER2
  lda #>adr
  sta POINTER2+1
  pla
!end

!zone cmp_b_pointer
cmp_b_pointer
  tya
  pha
  ; y starts at 0 (and stays there if LSB and MSB is equal), else it will be increased
  ldy #$0
  ; test if LSB is equal
  lda REGISTER_16_B
  cmp POINTER
  ; store the z flag
  beq .continue
  iny
.continue
  ; test if MSB is equal
  lda REGISTER_16_B+1
  cmp POINTER+1
  beq .continue2
  iny
.continue2
  ; in the end check if y is still zero
  tya
  sty FUNC_RETURN_VALUE
  ; the status registers are now correct set and stay there after the routine exists

  pla
  tay
  lda FUNC_RETURN_VALUE
  rts

!zone cmp_c_pointer
cmp_c_pointer
  pha
  tya
  pha
  ; y starts at 0 (and stays there if LSB and MSB is equal), else it will be increased
  ldy #$0
  ; test if LSB is equal
  lda POINTER
  cmp REGISTER_16_C
  ; store the z flag
  beq .continue
  iny
.continue
  ; test if MSB is equal
  lda POINTER+1
  cmp REGISTER_16_C+1
  beq .continue2
  iny
.continue2
  ; in the end check if y is still zero for the return value
  ; the return value is set in the carry flag
  ; carry flag 0 means not equal, 1 means true = equal
  cpy #0
  bne .yGreaterZero
  sec
  jmp .end
.yGreaterZero ; carray 0
  clc
.end

  pla
  tay
  pla
  rts
 
!macro push_pointer   ; we have to use a macro as pushing inside a function and rts don't work
  sta FUNC_pop_push_STACK_A  ; push a
  lda POINTER
  pha
  lda POINTER+1
  pha
  lda FUNC_pop_push_STACK_A  ; pull a
!end
  
!macro pop_pointer
  sta FUNC_pop_push_STACK_A  ; push a
  pla
  sta POINTER+1
  pla
  sta POINTER
  lda FUNC_pop_push_STACK_A  ; pull a
!end
  
!macro push_pointer2   ; we have to use a macro as pushing inside a function and rts don't work
  sta FUNC_pop_push_STACK_A  ; push a
  lda POINTER2
  pha
  lda POINTER2+1
  pha
  lda FUNC_pop_push_STACK_A  ; pull a
!end
  
!macro pop_pointer2
  sta FUNC_pop_push_STACK_A  ; push a
  pla
  sta POINTER2+1
  pla
  sta POINTER2
  lda FUNC_pop_push_STACK_A  ; pull a
!end

page_inc_pointer    ; increase pointer 1 page (256 bytes)
  pha
  clc
  lda POINTER
  adc #<$ff
  sta POINTER
  lda POINTER+1
  adc #>$ff
  sta POINTER+1
  pla
  rts

page_inc_pointer2    ; increase pointer 1 page (256 bytes)
  pha
  clc
  lda POINTER2
  adc #<$ff
  sta POINTER2
  lda POINTER2+1
  adc #>$ff
  sta POINTER2+1
  pla
  rts

!zone page_inc_pointer_y
page_inc_pointer_y    ; increase pointer y-times (y register times) pages
  pha
.loop
  clc
  lda POINTER
  adc #<$ff
  sta POINTER
  lda POINTER+1
  adc #>$ff
  sta POINTER+1
  dey
  bne .loop
  pla
  rts

!zone page_inc_pointer2_y
page_inc_pointer2_y    ; increase pointer2 y-times (y register times) pages
  pha
.loop
  clc
  lda POINTER2
  adc #<$ff
  sta POINTER2
  lda POINTER2+1
  adc #>$ff
  sta POINTER2+1
  dey
  bne .loop
  pla
  rts

!zone blockInc_AVParam ; increases the value at aAddr by blockSize * blockCount
!macro blockInc_AVParam aAddr, vBlockSize ; param is FUNC_blockInc_AVV_blockCount
; increase the stack pointer
  ldx #0
.blocksLoop
  ldy #0
.byteLoop
  +bit16_inc_A aAddr
  iny
  cpy #vBlockSize
  bne .byteLoop
  inx
  cpx FUNC_blockInc_AVV_blockCount
  bne .blocksLoop
!end

!zone blockInc_AVV ; increases the value at aAddr by blockSize * blockCount
!macro blockInc_AVV aAddr, vBlockSize, vBlockCount
  lda #vBlockCount
  sta FUNC_blockInc_AVV_blockCount
  +blockInc_AVParam aAddr, vBlockSize
!end
 
!macro inc_pointer_16bit_V vValue    ; increase pointer by a 16bit value
  pha
  clc
  lda POINTER
  adc #<vValue
  sta POINTER
  lda POINTER+1
  adc #>vValue
  sta POINTER+1
  pla
!end
  
inc_pointer_16bit    ; increase pointer by a 16bit value defined by register b
  pha
  clc
  lda POINTER
  adc REGISTER_16_B
  sta POINTER
  lda POINTER+1
  adc REGISTER_16_B+1
  sta POINTER+1
  pla
  rts
  
dec_pointer_16bit    ; decrease pointer by a 16bit value defined by register b
  pha
  sec
  lda POINTER
  sbc REGISTER_16_B
  sta POINTER
  lda POINTER+1
  sbc REGISTER_16_B+1
  sta POINTER+1
  pla
  rts
  
inc_pointer2_16bit    ; increase pointer2 by a 16bit value defined by register b
  pha
  clc
  lda POINTER2
  adc REGISTER_16_B
  sta POINTER2
  lda POINTER2+1
  adc REGISTER_16_B+1
  sta POINTER2+1
  pla
  rts

dec_pointer2_16bit    ; decrease pointer2 by a 16bit value defined by register b
  pha
  sec
  lda POINTER2
  sbc REGISTER_16_B
  sta POINTER2
  lda POINTER2+1
  sbc REGISTER_16_B+1
  sta POINTER2+1
  pla
  rts
  
inc_pointer    ; increase pointer by one
  pha
  clc
  lda POINTER
  adc #<$1
  sta POINTER
  lda POINTER+1
  adc #>$1
  sta POINTER+1
  pla
  rts
  
inc_pointer2    ; increase pointer2 by one
  pha
  clc
  lda POINTER2
  adc #<$1
  sta POINTER2
  lda POINTER2+1
  adc #>$1
  sta POINTER2+1
  pla
  rts

dec_pointer    ; decrease pointer by one
  pha
  sec
  lda POINTER
  sbc #<$1
  sta POINTER
  lda POINTER+1
  sbc #>$1
  sta POINTER+1
  pla
  rts
  
dec_pointer2    ; decrease pointer2 by one
  pha
  sec
  lda POINTER2
  sbc #<$1
  sta POINTER2
  lda POINTER2+1
  sbc #>$1
  sta POINTER2+1
  pla
  rts
  
!macro sta_P pAdr ; saves the accu to the adress where pAdr points to
  +set_pointer_P pAdr
  ldy #0
  sta (POINTER),y
!end

!macro lda_P pAdr ; loads the value pAdr points to into accu, uses y and a
  +set_pointer_P pAdr
  ldy #0
  lda (POINTER),y
!end

!macro sta_offset_PV pAdr, vOffset ; saves the accu to the adress where pAdr points to
  +set_pointer_P pAdr
  sty FUNC_pointer_temp_stack_1
  ldy #vOffset
  sta (POINTER),y
  php
  ldy FUNC_pointer_temp_stack_1
  plp
!end
  
!macro lda_offset_PV pAdr, vOffset ; loads the value pAdr points to into accu, uses y and a
  +set_pointer_P pAdr
  sty FUNC_pointer_temp_stack_1
  ldy #vOffset
  lda (POINTER),y
  php
  ldy FUNC_pointer_temp_stack_1
  plp
!end

eof_pointer
;}