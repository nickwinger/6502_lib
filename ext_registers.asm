REGISTER_16_B  = $3FC ; 16bit register
REGISTER_16_C  = $3FE ; 16bit register

STACK_16_B = $334
STACK_16_C = $336

ZERO_PAGE_BYTE = $02 ; one of the few free zero page bytes of the c64

  jmp eof_ext_registers

 

!macro inc_16A16A a1,a2   ; increase the value at adress by a 16bit value 
  pha
  clc
  lda a1
  adc a2
  sta a1
  lda a1+1
  adc a2+1
  sta a1+1
  pla
!end

!macro inc_16A16V a1,v1   ; increase the value at adress by a 16bit value 
  pha
  clc
  lda a1
  adc #<v1
  sta a1
  lda a1+1
  adc #>v1
  sta a1+1
  pla
!end


!macro mov_16V16A v1, v2     ; move 16bit value to 16 bit adress
  lda #<v1 ;  LSB
  sta v2 
  lda #>v1 ;  MSB
  sta v2+1
!end

!macro mova_V16A v1, a1  ; move value to 16bit adress
  lda #v1
  sta a1
!end

!macro mov_16A16A a1, a2     ; move 16bit adress to 16 bit adress
  lda a1 ;  LSB
  sta a2 
  lda a1+1 ;  MSB
  sta a2+1
!end

!macro ldb v1     ; load 16bit register b
  pha
  lda #<v1 ;  LSB
  sta REGISTER_16_B 
  lda #>v1 ;  MSB
  sta REGISTER_16_B+1
  pla
!end

!macro point_regB_offset_PV pPointer, vOffset ; points regB to pPointer and offsets it
  +point_regB_P pPointer ; regB points now to the start of the object
  +adc_regB_16V vOffset ; regB now points to the animIndex of the object
!end

!macro point_regC_offset_PV pPointer, vOffset ; points regC to pPointer and offsets it
  +point_regC_P pPointer ; regC points now to the start of the object
  +adc_regC_16V vOffset ; regC now points to the animIndex of the object
!end

!macro point_regB_P pPointer     ; point the 16bit register b to where the given pointer points to
  +point_P_P REGISTER_16_B, pPointer
!end

!macro point_regC_P pPointer     ; point the 16bit register c to where the given pointer points to
  +point_P_P REGISTER_16_C, pPointer
!end

!macro point_P_P pPointer1, pPointer2     ; point the pointer1 to where the pointer2 points to
  pha
  lda pPointer2 ;  LSB
  sta pPointer1 
  lda pPointer2+1 ;  MSB
  sta pPointer1+1
  pla
!end

!macro bit16_push_b   ; we have to use a macro as pushing inside a function and rts don't work
  sta ZERO_PAGE_BYTE  ; push a
  lda REGISTER_16_B
  pha
  lda REGISTER_16_B+1
  pha
  lda ZERO_PAGE_BYTE  ; pull a
!end

!macro bit16_pull_b
  sta ZERO_PAGE_BYTE  ; push a
  pla
  sta REGISTER_16_B+1
  pla
  sta REGISTER_16_B
  lda ZERO_PAGE_BYTE  ; pull a
!end

!macro bit16_push_c   ; we have to use a macro as pushing inside a function and rts don't work
  sta ZERO_PAGE_BYTE  ; push a
  lda REGISTER_16_C
  pha
  lda REGISTER_16_C+1
  pha
  lda ZERO_PAGE_BYTE  ; pull a
!end

!macro bit16_pull_c
  sta ZERO_PAGE_BYTE  ; push a
  pla
  sta REGISTER_16_C+1
  pla
  sta REGISTER_16_C
  lda ZERO_PAGE_BYTE  ; pull a
!end

!zone bit16_inc_A
!macro bit16_inc_A  a1
  inc a1
  bne .end          ; if not going over $ff end
  inc a1+1          ; else also increase msb
.end
!end

!zone bit16_dec
!macro bit16_dec  a1
  dec a1
  cmp $ff
  bne .end          ; if not going under 0 end
  dec a1+1          ; else also increase msb
.end
!end


!macro adc_regB_16V vValue
  +bit16_adc_16A16V REGISTER_16_B, vValue
!end

!macro adc_regC_16V vValue
  +bit16_adc_16A16V REGISTER_16_C, vValue
!end

!macro bit16_adc_16A16V  a1, v1
  clc
  lda a1
  adc #<v1
  sta a1
  lda a1+1
  adc #>v1
  sta a1+1
!end

!macro bit16_sdc_16A16V  a1, v1
  sec
  lda a1
  sbc #<v1
  sta a1
  lda a1+1
  sbc #>v1
  sta a1+1
!end

!macro ldZPB_offset_PV pPointer, vOffset ; loads the value given by the pointer and added offset into ZeroPageByte
  +set_pointer_P pPointer
  ldy #vOffset
  lda (POINTER),y
  sta ZERO_PAGE_BYTE
!end

!macro ldZPB_V vValue
  lda #vValue
  sta ZERO_PAGE_BYTE
!end

bit16_push_c
  sta ZERO_PAGE_BYTE
  lda REGISTER_16_C
  pha
  lda REGISTER_16_C+1
  pha
  lda ZERO_PAGE_BYTE
  rts

bit16_pull_c
  sta ZERO_PAGE_BYTE
  pla
  sta REGISTER_16_C+1
  pla
  sta REGISTER_16_C
  lda ZERO_PAGE_BYTE
  rts
  
bit16_cmp
  rts
  
bit16_move_b   ;moves value of b to the location defined by pointer
  pha
  tya
  pha
  
  lda REGISTER_16_B
  ldy #$0
  sta (POINTER),y
  lda REGISTER_16_B+1
  ldy #$1
  sta (POINTER),y
  
  pla
  tay
  pla
  rts
  
  
bit16_add    ; add 16bit value stored at register b  with a 16bit value defined byregister c
  ; the result is stored in REGISTER c
  clc
  
  ; LSB
  lda REGISTER_16_B
  adc REGISTER_16_C
  sta REGISTER_16_C
  
  ; MSB
  lda REGISTER_16_B+1
  adc REGISTER_16_C+1
  sta REGISTER_16_C+1
  rts
eof_ext_registers
