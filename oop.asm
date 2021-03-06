jmp eof_oop

MaxObjectInstances      = 10
OOP_RAM_START           = FIXED_VARIABLES_START + 100 ; 2 bytes
OBJ_Instances_Ram_Start = FIXED_VARIABLES_START+56
OOP_RAM_START_END

OBJ_DEFINITION_SIZE               = 5
OBJ_DEFINITION_TYPE               = 0
OBJ_DEFINITION_FUNCS_JUMPTABLE    = 1
OBJ_DEFINITION_FUNCS_JUMPTABLE_LO = 1 ; pointer to the funcs jumptable of the object
OBJ_DEFINITION_FUNCS_JUMPTABLE_HI = 2
OBJ_DEFINITION_PROPERTIES         = 3 ; pointer to the object properties in memory
OBJ_DEFINITION_PROPERTIES_LOW     = 3
OBJ_DEFINITION_PROPERTIES_HIGH    = 4

init_oop
  pha
  lda #<OOP_DEFAULT_MEM_START
  sta OOP_RAM_START
  lda #>OOP_DEFAULT_MEM_START
  sta OOP_RAM_START+1
  pla
  rts

!macro obj_definition_call_func_PV pObjDefinition, vFuncIndex
  lda pObjDefinition
  sta FUNC_PARAM_1
  lda pObjDefinition
  sta FUNC_PARAM_2
  lda #vFuncIndex
  sta FUNC_PARAM_3
  
  jsr obj_definition_call_func
!end

!macro obj_definition_call_func_PA pObjDefinition, aFuncIndex
  pha
  lda pObjDefinition
  sta FUNC_PARAM_1
  lda pObjDefinition + 1
  sta FUNC_PARAM_2
  lda aFuncIndex
  sta FUNC_PARAM_3
  pla
  jsr obj_definition_call_func
!end

!macro current_obj_definition_call_func_V vFuncIndex
  pha
  lda P_CURRENT_OBJECT_DEFINITION
  sta FUNC_PARAM_1
  lda P_CURRENT_OBJECT_DEFINITION + 1
  sta FUNC_PARAM_2
  lda #vFuncIndex
  sta FUNC_PARAM_3
  pla
  jsr obj_definition_call_func
!end

obj_definition_call_func ; calls the function at index FUNC_PARAM_3 of the definition FUNC_PARAM_1/2 points to
  +push_ay
  +set_properties_ramAdr_P FUNC_PARAM_1
  ; set the global current object properties context
  +lda_property_V OBJ_DEFINITION_PROPERTIES_LOW
  sta P_CURRENT_OBJECT_PROPERTIES
  +lda_property_V OBJ_DEFINITION_PROPERTIES_HIGH
  sta P_CURRENT_OBJECT_PROPERTIES + 1
  ; load the functions jumptable
  +lda_property_V OBJ_DEFINITION_FUNCS_JUMPTABLE_LO
  sta FUNC_PARAM_4
  +lda_property_V OBJ_DEFINITION_FUNCS_JUMPTABLE_HI
  sta FUNC_PARAM_5
  +set_pointer_P FUNC_PARAM_4
  ; pointer2 now points to the functions jumptable of the object (which is a pList)
  lda FUNC_PARAM_3
  asl ; multiply the index by 2 to get the correct index of the word pList
  tay
  lda (POINTER),y
  sta FUNC_PARAM_4
  iny
  lda (POINTER),y
  sta FUNC_PARAM_5
  ; FUNC_PARAM_4/5 now holds the adress of the function to call
  +jsr_P FUNC_PARAM_4
  +pop_ay
  rts

!macro create_obj_VAV vObjType, aFuncJumpTable, vObjPropertiesSize ; reserves memory for the obj definition and returns it's adress at OOP_CONSTRUCTOR_RETURN
  +push_func_params_1234
  pha
  lda #vObjType
  sta FUNC_PARAM_1
  lda #<aFuncJumpTable
  sta FUNC_PARAM_2
  lda #>aFuncJumpTable
  sta FUNC_PARAM_3
  lda #vObjPropertiesSize
  sta FUNC_PARAM_4
  pla
  jsr create_obj_definition
  nop
  +pop_func_params_1234
  nop
!end

create_obj_definition ; FUNC_PARAM_1 = vObjType, FUNC_PARAM_2/3 = aFuncJumpTable, FUNC_PARAM_4 = vObjPropertiesSize ; reserves memory for the obj definition and returns it's adress at OOP_CONSTRUCTOR_RETURN
  +malloc_V_return_pRegBCarry OBJ_DEFINITION_SIZE   ; 1. reserve memory for the definition
  +mov_16A16A REGISTER_16_B, OOP_CONSTRUCTOR_RETURN 
  nop
  +set_properties_ramAdr_P OOP_CONSTRUCTOR_RETURN     ; 2. set properties of the definition
  +st_property_VA OBJ_DEFINITION_TYPE, FUNC_PARAM_1
  +st_property_VA OBJ_DEFINITION_FUNCS_JUMPTABLE_LO, FUNC_PARAM_2
  +st_property_VA OBJ_DEFINITION_FUNCS_JUMPTABLE_HI, FUNC_PARAM_3
  nop
  +malloc_A_return_pRegBCarry FUNC_PARAM_4
  +st_property_VP OBJ_DEFINITION_PROPERTIES, REGISTER_16_B
  rts
  
eof_oop