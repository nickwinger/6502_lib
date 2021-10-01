
jmp eof_mem


!zone copy_mem
copy_mem                 ; copy the memory from location stored at pointer, to location stored at pointer2
                          ; byte count to copy is stored in register b
  ; copy from end to start to test for equal 0 in loop
  pha
  +bit16_push_b
  
  lda POINTER
  sta REGISTER_16_C
  lda POINTER+1
  sta REGISTER_16_C+1
  
  jsr inc_pointer_16bit
  jsr inc_pointer2_16bit
  
  tya
  pha
  ldy #$0
.loop
  jsr dec_pointer
  jsr dec_pointer2
  lda (POINTER),y
  sta (POINTER2),y
  jsr cmp_c_pointer
  bcc .loop
  
  pla
  tay
  +bit16_pull_b
  
  pla
  rts

!zone fill_mem_AVV
!macro fill_mem_AVV aStartAdress, vFillByte, vCount
  pha
  +bit16_push_b
  +bit16_push_c
  
  ; set pointer and register c to start adress
  lda #<aStartAdress
  sta POINTER
  sta REGISTER_16_C
  lda #>aStartAdress
  sta POINTER+1
  sta REGISTER_16_C+1
  
  ; go to the end (we fill backwards)
  lda #<vCount
  sta REGISTER_16_B
  lda #>vCount
  sta REGISTER_16_B+1
  jsr inc_pointer_16bit
  
  tya
  pha
  ldy #$0
  lda #vFillByte
.loop
  jsr dec_pointer
  sta (POINTER),y 
  jsr cmp_c_pointer ; carry is 1 means true if the are equal
  bcc .loop
  
  pla
  tay
  +bit16_pull_c
  +bit16_pull_b
  
  pla
  !end
  
eof_mem