; constructor

pha
; initialize the alloc list, everything if free on start
lda #MAX_OBJECTS
sta OBJECTS_PROPERTIES_ALLOC_LIST_LENGTH
+set_Array_AV OBJECTS_PROPERTIES_ALLOC_LIST, 0
pla

; allocate memory of the data
+block_alloc_VV_return_pRegBCarry OBJECT_PROPERTIES_SIZE, MAX_OBJECTS
; store the ram start
+mov_16A16A REGISTER_16_B, OBJECTS_PROPERTIES_RAM_START

; end of constructor
jmp eof_object_properties_manager


!macro alloc_object_properties_return_CarryregB ; allocates ram for a properties object and returns it's adress in register b
  +find_index_first_item_in_list_AV_return_CarryAccu OBJECTS_PROPERTIES_ALLOC_LIST, 0
  bcc .noMoreSpaceLeft
  ; calculate the start ram of the properties given the index the size and the start ram
  ; regB = OBJECTS_PROPERTIES_RAM_START + Accu * OBJECT_PROPERTIES_SIZE
  +mov_16A16A OBJECTS_PROPERTIES_RAM_START, REGISTER_16_B
  sta FUNC_blockInc_AVV_blockCount
  +blockInc_AVParam REGISTER_16_B, OBJECT_PROPERTIES_SIZE
  sec
  jmp .end
.noMoreSpaceLeft
  clc
.end
!end


eof_object_properties_manager