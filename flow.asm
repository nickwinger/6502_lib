jmp eof_flow

!zone is_greater_AA_return_Carry
!macro is_greater_AA_return_Carry aAddr1, aAddr2 ; checks if the value at aAddr1 is greater than the value at aAddr2
  pha
  lda aAddr1
  cmp aAddr2
  BEQ .isNotGreater 
  BCS .isGreater 
.isNotGreater
  clc
  jmp .end
.isGreater
  sec
.end
  pla
!end

!zone is_equal_16bit_AV_returnCarry
!macro is_equal_16bit_AV_returnCarry aAddr1, vAddr2 ; checks if the two 16bit values are ident
  pha
  LDA aAddr1 + 1    ; high bytes
  CMP #>vAddr2
  BNE .notEqual
  LDA aAddr1       ; low bytes
  CMP #<vAddr2
  BEQ .areEqual 
.notEqual
  clc
  jmp .end
.areEqual
  sec
.end
  pla
!end

!zone is_equal_16bit_AA_returnCarry
!macro is_equal_16bit_AA_returnCarry aAddr1, aAddr2 ; checks if the two 16bit values are ident
  pha
  LDA aAddr1 + 1    ; high bytes
  CMP aAddr2 + 1
  BNE .notEqual
  LDA aAddr1       ; low bytes
  CMP aAddr2
  BEQ .areEqual 
.notEqual
  clc
  jmp .end
.areEqual
  sec
.end
  pla
!end

!zone is_greater_16bit_AA_return_Carry
!macro is_greater_16bit_AA_return_Carry aAddr1, aAddr2 ; checks if the value at aAddr1 is greater than the value at aAddr2
  pha
; Val1 ≥ Val2 ?
  LDA aAddr1 + 1    ; high bytes
  CMP aAddr2 + 1
  BCC .LsThan     ; hiVal1 < hiVal2 --> Val1 < Val2
  BNE .GrtEqu     ; hiVal1 ≠ hiVal2 --> Val1 > Val2
  LDA aAddr1       ; low bytes
  CMP aAddr2
  ;BEQ Equal     ; Val1 = Val2
  BCS .GrtEqu     ; loVal1 ≥ loVal2 --> Val1 ≥ Val2
.LsThan
  clc
  jmp .end
.GrtEqu
  sec
.end
  pla
!end

!zone jsr_P
!macro jsr_P pAJumpAdr ; jmp to the func the pointer pAJumpAdr points to and return via rts
  ; manually push the return adress to the stack, so the rts of the start func works
  lda #>.returnFromFunc
  pha
  lda #<.returnFromFunc
  pha
  jmp (pAJumpAdr)
.returnFromFunc
  nop ; rts does a + one
!end

eof_flow