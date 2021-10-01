jmp eof_properties

!macro sta_properties_PV pPropertiesAdr, vPropertyIndex ; saves the accu to the adress where pAdr points to
  +set_pointer_P pPropertiesAdr
  sty FUNC_pointer_temp_stack_1
  ldy #vPropertyIndex
  sta (POINTER),y
  php
  ldy FUNC_pointer_temp_stack_1
  plp
!end

!macro set_properties_ramAdr_P pPropertiesAdr ; before calling a function, we set the start adress of the properties memory block
  +set_pointer_P pPropertiesAdr
!end

!macro set_properties_ramAdr_A aPropertiesAdr ; before calling st_property_VV, we set the start adress of the properties block
  +set_pointer aPropertiesAdr
!end

!macro lda_property_V vPropertyIndex ; 
  ldy #vPropertyIndex
  lda (POINTER),y
!end

!macro st_property_VV vPropertyIndex, vPropertyValue ; 
  ldy #vPropertyIndex
  lda #vPropertyValue
  sta (POINTER),y
!end

!macro st_property_VP vPropertyIndex, pVPropertyValue ; store a pointer
  ldy #vPropertyIndex
  lda pVPropertyValue
  sta (POINTER),y
  iny
  lda pVPropertyValue + 1
  sta (POINTER),y
!end

!macro st_property_VA vPropertyIndex, aPropertyValue ; store a memory adress
  ldy #vPropertyIndex
  lda <aPropertyValue
  sta (POINTER),y
  iny
  lda >aPropertyValue
  sta (POINTER),y
!end

eof_properties