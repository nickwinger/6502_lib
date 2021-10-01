
  jmp eof_math

!zone mod_V
!macro mod_V vMod ; accu modulo x
  sec
.loop
  sbc #vMod
  bcs .loop
  adc #vMod
!end

!zone div_V
!macro div_V vDivisor
  LDX #$FF
  SEC
.loop   
  INX
  SBC #vDivisor
  BCS .loop
  TXA      ;get result into accumulator
!end 

!zone mul_V
!macro mul_V vMultiplikant
  cmp #0
  bne .noNullMulti
  lda #0
  jmp .end
.noNullMulti
 
  sta FUNC_mul_V
  LDX #vMultiplikant
  CLC
.loop   
  dex
  beq .end
  ADC FUNC_mul_V
  jmp .loop
.end
!end 

eof_math
