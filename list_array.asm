

jmp eof_list_array

NULL_P_ITEM
!word $0000 ; "null" reference value

!macro create_list_V_return_regB vSize ; creates a list and returns it's adress in regB
  +malloc_V_return_pRegBCarry vSize + 1 ; 1 one because the first byte is the length of the list
!end

!macro create_pList_V_return_regB vLength ; creates a pList (words) and returns it's adress in regB
  ; mutliply the length by 2, cause pList have word items
  lda #vLength
  asl ; word length to bytes -> * 2
  clc
  adc #1 ; 1 one because the first byte is the length of the list
  sta FUNC_PARAM_1
  +malloc_return_pRegBCarry
  ; store the length in the first byte
  +set_pointer_P REGISTER_16_B
  lda #vLength
  ldy #0
  sta (POINTER),y
!end

!zone list_compare_all_PA
!macro list_compare_all_PA pList1, aList2 ; compares 2 lists if the have the same items
  +push_axy
  +push_pointer
  
  ; match counter to zero, in the end match counter must be equal to list length
  lda #0
  sta FUNC_list_compare_all_PA_COUNTER
  ; point the POINTER to the length of the list
  lda pList1
  sta POINTER
  lda pList1+1
  sta POINTER+1
  jsr dec_pointer
  ; the length must be the same,
  ldy #0
  lda (POINTER),y
  cmp aList2-1
  beq .continue
  ; not the same
  jmp .end
.continue
  jsr inc_pointer ; after reading the length, set the pointer to the list again
  ; point the POINTER to the list
  ldx #0
.outerLoop
  ldy #0
.innerLoop        ; go through all the values inside pList1
  lda aList2, x   ; and compare to the current value inside aList2
  cmp (POINTER),y
  bne .continueInnerLoop
  ; we have a match
  inc FUNC_list_compare_all_PA_COUNTER
  jmp .breakInnerLoop
.continueInnerLoop
  iny
  cpy aList2-1
  bne .innerLoop
  
.breakInnerLoop  
  inx
  cpx aList2-1
  bne .outerLoop
  
  ; if match counter equals list length all items are the same
  lda aList2-1
  cmp FUNC_list_compare_all_PA_COUNTER
  bne .notSame
  ; all are same
  sec
  jmp .end
.notSame
  clc
.end
  +pop_pointer
  +pop_axy
!end

!zone list_compare_all_AA
!macro list_compare_all_AA aList1, aList2 ; compares 2 lists if the have the same items
  ; the length must be the same
  lda aList1-1
  cmp aList2-1
  beq .continue
  ; not the same
  lda #1
  jmp .end
.continue
  ldy #0
.loop
  lda (aList1),y
  +list_contains_regAA aList2
  beq .found
  iny
  cpy aList1-1
  bne .loop
  ; notFound
  lda #1
  jmp .end
.found
  lda #0
.end
!end

!zone pList_contains_list_AA
!macro pList_contains_list_AA pList, list ; a pList to other lists, we check if the given list if equal to one of the lists
  ldx #0
.loop
  ldy #0    ; assume we find
  cmp pList, x
  
  #list_compare_all_AA POINTER, list
  beq .end
  ldy #1
  inx
  cpx pList-1
  bne .loop
.end
  tya ; load the result into accu
!end



!zone pList_contains_listValues_AA
!macro pList_contains_listValues_AA aPList, aList
  ; search the pList list items, and then compares each list item with aList if
  ; it matches all values
  pha
  tya
  pha
  +push_pointer
  +bit16_push_b
  
  ; load the length of the list
  lda #<aPList
  sta POINTER
  lda #>aPList
  sta POINTER+1 ; pointer now points to the list
  
  jsr dec_pointer
  ldy #0
  lda (POINTER),y
  sta FUNC_pList_contains_listValues_AA_ListLength    ; store length in zero page byte
  jsr inc_pointer
  
  ldy #0
.loop
  ; point REGISTER_16_B to the nth list inside the pList
  lda (POINTER),y
  sta REGISTER_16_B
  iny     
  lda (POINTER),y
  sta REGISTER_16_B+1
 
  +list_compare_all_PA REGISTER_16_B, aList
  bcc .fuck
  
  ; we found the item
  jmp .found
.continueWithInc
  iny           ; if the LSB doesn't match we skip comparing the MSB
  jmp .continue
.fuck
  nop
.continue
  iny
  cpy FUNC_pList_contains_listValues_AA_ListLength
  beq .break
  jmp .loop
.break
  clc
  lda #1  ; not found
  jmp .end
.found
  sec
  lda #0  ; set a (as a return value to test against)
.end
  +bit16_pull_b
  +pop_pointer
  pla
  tay
  pla
!end




!zone pList_contains_pItem_AP
!macro pList_contains_pItem_AP aPList, pItem ; search for the same pointer inside the pointer list
  +push_pointer
  +bit16_push_b
  
  ; load the length of the list
  lda #<aPList
  sta POINTER
  lda #>aPList
  sta POINTER+1 ; pointer no points to the list
  
  jsr dec_pointer
  ldy #0
  lda (POINTER),y
  sta ZERO_PAGE_BYTE    ; store length in zero page byte
  jsr inc_pointer
  
  ldy #0
.loop
  ; the list contains pointers which are 2 bytes
  ; compare the adress that these pointers are pointing to
  ; to the adress the pItem is pointing to
  lda (POINTER),y   ; LSB of yth pointer adress
  cmp pItem         ; compare to the LSB the pItem points to
  bne .continueWithInc
  iny
  lda (POINTER),y   ; MSB of yth pointer adress
  cmp pItem+1        ; compare to the MSB the pItem points to
  bne .continue
  
  ; we found the item
  jmp .found
.continueWithInc
  iny           ; if the LSB doesn't match we skip comparing the MSB
.continue
  iny
  cpy ZERO_PAGE_BYTE
  bne .loop
  lda #1  ; not found
  jmp .end
.found
  lda #0  ; set a (as a return value to test against)
.end
  +bit16_pull_b
  +pop_pointer
!end

; definition of an array or list is that the first bytes indicates the length
; of the array/list after that comes the array

!zone list_contains_regAA
!macro list_contains_regAA aList ; looks if the value in the accu is inside the list
  ldx #0
.loop
  ldy #0    ; assume we find
  cmp aList, x
  beq .end
  ldy #1
  inx
  cpx aList-1
  bne .loop
.end
  tya ; load the result into accu
!end

!zone list_contains_AA
!macro list_contains_AA aList, aValue
  ldx #0
.loop
  lda aList, x
  cmp aValue
  beq .found
  inx
  cpx aList-1
  bne .loop
  clc ; not found
  jmp .end
.found
  sec
.end
!end

!macro define_list_AV aList, vLength
  lda #vLength
  sta aList-1
!end

!macro define_pList aPList, vLength ; length is given in word-length
  lda #vLength
  asl
  sta aPList-1
!end

; ######################## set methods ############################
!macro set_item_AVRegY aList, vItem ; index is given in regY
  pha
  lda #vItem
  sta aList, y
  pla 
!end


!macro set_pItem_AARegY aPList, pItem ; index is given in word-length in regY
  pha
  tya
  pha
  asl ; multiply index by 2 to store pointers
  tay
  lda #<pItem
  sta aPList, y
  lda #>pItem
  iny
  sta aPList, y
  pla
  tay
  pla
!end

!macro set_pItem_AAV aPList, pItem, vIndex ; index is given in word-length
  pha
  lda #vIndex
  asl ; multiply index by 2 to store pointers
  tay
  lda #<pItem
  sta aPList, y
  lda #>pItem
  iny
  sta aPList, y
  pla
!end

!macro set_pItem_PAregY pPList, aPItem ; index is given in word-length in regY
  +push_func_params_12345
  lda pPList
  sta FUNC_PARAM_4
  lda pPList+1
  sta FUNC_PARAM_5
  lda aPItem
  sta FUNC_PARAM_1
  lda aPItem+1
  sta FUNC_PARAM_2
  sty FUNC_PARAM_3
  jsr set_pItem_index_pPList
  +pop_func_params_12345
!end

set_pItem_index_pPList ; FUNC_PARAM_1/2 = aPItem, FUNC_PARAM_3 = (word)index, FUNC_PARAM_4/5 = pPList
  +set_pointer_P FUNC_PARAM_4
  lda FUNC_PARAM_3
  asl ; multiply index by 2, because we have pointers of 2 bytes
  clc
  adc #1 ; add one because the first byte if the length of the list
  tay
  lda FUNC_PARAM_1
  sta (POINTER),y
  iny
  lda FUNC_PARAM_2
  sta (POINTER),y
  rts

!macro set_pItem_PAA pPList, aPItem, aIndex ; index is given in word-length 
  lda pPList
  sta FUNC_PARAM_1
  lda pPList+1
  sta FUNC_PARAM_2
  lda aPItem
  sta FUNC_PARAM_3
  lda aPItem+1
  sta FUNC_PARAM_4
  lda aIndex
  sta FUNC_PARAM_5
  jsr set_pItem
!end

!zone set_Array_word_AV ; set all values of the array
!macro set_Array_word_AV aArray, vValue
  ldx #0
.loop
  lda #<vValue
  sta aArray, x
  inx
  lda #>vValue
  sta aArray, x
  inx
  cpx aArray-1  ; length of array
  bne .loop
!end

!zone fill_Array_PV ; set all values of the array
!macro fill_Array_PV pArray, vValue
  +set_pointer_P pArray
  ; store length in ZPB
  lda (POINTER),y ; first byte is the length
  sta CLASS_LIST_ARRAY_LENGTH
  ldy #1
  lda #vValue
.loop
  sta (POINTER), y
  iny
  cpy CLASS_LIST_ARRAY_LENGTH
  bne .loop
!end

!zone set_Array_AV ; set all values of the array
!macro set_Array_AV aArray, vValue
  ldx #0
  lda #vValue
.loop
  sta aArray, x
  inx
  cpx aArray-1
  bne .loop
!end

!zone set_TempArray10_V
!macro set_TempArray10_V vValue
  +set_Array_AV TEMP_ARRAY_10, vValue
!end

; ######################## set methods END ############################

; ######################## get methods ############################
!macro get_item_AVRegX_return_accu aList ; index is given in regY
  lda aList, x
!end

!macro get_item_AVRegY_return_accu aList ; index is given in regY
  lda aList, y 
!end

!macro get_pItem_PregY_return_regB pPList ; index is given in word-length in regY
  pha
  lda pPList
  sta FUNC_PARAM_1
  lda pPList+1
  sta FUNC_PARAM_2
  sty FUNC_PARAM_3
  pla
  jsr get_pItem_pPlistIndex_return_regB
!end

get_pItem_pPlistIndex_return_regB 
  ; pitem is returned in regB
  +set_pointer_P FUNC_PARAM_1
  +push_ay
  lda FUNC_PARAM_3
  asl ; multiply index by 2 to store pointers
  clc
  adc #1 ; add one, because on the first index is the length of the list stored
  tay
  lda (POINTER), y
  sta REGISTER_16_B
  iny
  lda (POINTER), y
  sta REGISTER_16_B + 1
  +pop_ay
  rts

; ######################## get methods END ############################

; beaware that zero items cannot be stored, as zero means here "NULL"
!zone addListItem_AA
!macro addListItem_AA aArray, aValue
  lda aArray-1
  sta ZERO_PAGE_BYTE    ; store length
  ldx #0
.loop
  lda aArray, x     ; find a zero place to put the item
  cmp #0
  bne .continue
  lda aValue       ; set item zero place
  sta aArray, x
  jmp .end
.continue
  inx
  cpx ZERO_PAGE_BYTE
  bne .loop
.end
!end

; ################ find methods

!zone find_index_first_item_in_list_AregA_return_CarryregY
!macro find_index_first_item_in_list_AregA_return_CarryregY aList ; finds the first index of vItem in the aList
  ; index is returned in regY
  ldy #0
.loop
  cmp aList, y 
  beq .itemFound
  iny
  cpy aList-1  ; length
  bne .loop
  clc
  jmp .end
.itemFound
  sec
.end
!end

!zone find_index_first_item_in_list_PV_return_CarryregY
!macro find_index_first_item_in_list_PV_return_CarryregY pAList, vItem ; finds the first index of vItem in the aList
  +set_pointer_P pAList
  ; index is returned in regY
  ldy #0 ; temp store length in ZPB
  lda (POINTER), y 
  sta ZERO_PAGE_BYTE 
  iny
.loop
  lda (POINTER), y 
  cmp #vItem  
  beq .itemFound
  iny
  cpy ZERO_PAGE_BYTE  ; length
  bne .loop
  clc
  jmp .end
.itemFound
  sec
.end
  dey ; minus the length byte
!end

!zone find_index_first_pItem_in_pList_PV_return_CarryregY
!macro find_index_first_pItem_in_pList_PA_return_CarryregY pPList, aItem ; finds the first index of vItem in the aList
  +set_pointer_P pPList
  ; index is returned in regY
  ldy #0 ; temp store length in ZPB
  lda (POINTER), y 
  sta ZERO_PAGE_BYTE 
  iny
.loop
  lda (POINTER), y 
  cmp aItem
  bne .itemNotFound
  iny
  lda (POINTER), y 
  cmp aItem+1
  beq .itemFound
.itemNotFound
  iny
  cpy ZERO_PAGE_BYTE  ; length
  bne .loop
  clc
  jmp .end
.itemFound
  sec
.end
  dey ; minus the length byte
  tya
  lsr ; divide by 2 (byte index to word index)
  tay
!end

!zone find_first_pItem_in_pList_AA
!macro find_first_pItem_in_pList_AA pList, pItem ; finds the first index of pItem in the pList
  ldx #0
  ldy #0
.loop
  lda pList, y     ; find the pItem
  cmp #<pItem   ; compare to lo byte
  bne .continue
  iny
  lda pList, y     ; find an empty-(word)-item place to put the item
  cmp #>pItem   ; compare to hi byte
  bne .continue 
  ; pItem found
  sec
  jmp .end
.continue
  inx
  cpx pList-1  ; length
  bne .loop
  clc
.end
!end

; ################ find methods END

; adds an word-item given by the adress to the list at the next location
; where the empty-item is (this is given by the vEmptyItem)
!zone pList_add_pItem_APA
!macro pList_add_pItem_APA aArray, pValue, aEmptyItem
  ldx #0
.loop
  lda aArray, x     ; find an empty-(word)-item place to put the item
  cmp #<aEmptyItem   ; compare to lo byte
  bne .continue
  lda aArray+1, x     ; find an empty-(word)-item place to put the item
  cmp #>aEmptyItem   ; compare to hi byte
  bne .continue 
  ; found an empty spot, place new item
  lda pValue       ; set item zero place
  sta aArray, x
  inx
  lda pValue+1
  sta aArray, x
  jmp .end
.continue
  inx
  cpx aArray-1  ; length
  bne .loop
.end
!end

!zone addListWordItem_A16A
!macro addListWordItem_A16A aArray, a16Value
  ldx #0
.loop
  lda aArray, x     ; find a zero place to put the item
  cmp #0
  bne .continue
  lda a16Value       ; set item zero place
  sta aArray, x
  inx
  lda a16Value+1
  sta aArray, x
  jmp .end
.continue
  inx
  cpx aArray-1  ; length
  bne .loop
.end
!end

!zone addListItem_AVV
!macro addListItem_AVV aArray, vValue
  lda aArray-1
  sta ZERO_PAGE_BYTE    ; store length
  ldx #0
.loop
  lda aArray, x     ; find a zero place to put the item
  cmp #0
  bne .continue
  lda #vValue       ; set item zero place
  sta aArray, x
  jmp .end
.continue
  inx
  cpx ZERO_PAGE_BYTE
  bne .loop
.end
!end

!zone lda_plist_listValueAtIndex_AAV ; loads the list at aListIndex from the aPList and then loads the vListItemIndex value into accu
!macro lda_plist_listValueAtIndex_AAV aPList, aListIndex, vListItemIndex
  +push_pointer
  +push_pointer2
  lda #<aPList
  sta POINTER
  lda #>aPList
  sta POINTER+1
  lda aListIndex ; because we have pointers (16bit) we have to multiply the index by 2
  asl
  tay
  lda (POINTER),y
  sta POINTER2
  iny
  lda (POINTER),y
  sta POINTER2+1 ; pointer2 now points to the list at aListIndex from the pList
  ldy #vListItemIndex
  lda (POINTER2),y ; accu now has the value from the item at aListItemIndex from the list
  +pop_pointer2
  +pop_pointer
!end

!zone lda_plist_listValueAtIndex_AAA ; loads the list at aListIndex from the aPList and then loads the aListItemIndex value into accu
!macro lda_plist_listValueAtIndex_AAA aPList, aListIndex, aListItemIndex
  +push_pointer
  +push_pointer2
  lda #<aPList
  sta POINTER
  lda #>aPList
  sta POINTER+1
  lda aListIndex ; because we have pointers (16bit) we have to multiply the index by 2
  asl
  tay
  lda (POINTER),y
  sta POINTER2
  iny
  lda (POINTER),y
  sta POINTER2+1 ; pointer2 now points to the list at aListIndex from the pList
  ldy aListItemIndex
  lda (POINTER2),y ; accu now has the value from the item at aListItemIndex from the list
  +pop_pointer2
  +pop_pointer
!end

; ################## compare methods ##########

!macro is_null_pItem_A pItem
  pha
  lda pItem
  sta FUNC_PARAM_1
  lda pItem + 1
  sta FUNC_PARAM_2
  pla
  jsr is_null_pItem
!end

!zone is_null_pItem
is_null_pItem ; checks if the given item is the NULL_P_ITEM
  pha
  lda FUNC_PARAM_1
  cmp NULL_P_ITEM
  bne .notEqual
  lda FUNC_PARAM_2
  cmp NULL_P_ITEM + 1
  bne .notEqual
  sec
  jmp .end
.notEqual
  clc
.end
  pla
  rts
; ################## compare methods END ##########

eof_list_array