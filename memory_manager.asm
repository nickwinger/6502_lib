; constructor

pha
lda #<MEMORY_MANAGER_DEFAULT_RAM_START
sta MEMORY_MANAGER_RAM_START
sta MEMORY_MANAGER_RAM_STACK_POINTER
lda #>MEMORY_MANAGER_DEFAULT_RAM_START
sta MEMORY_MANAGER_RAM_START + 1
sta MEMORY_MANAGER_RAM_STACK_POINTER + 1
lda #<(MEMORY_MANAGER_DEFAULT_RAM_END - MEMORY_MANAGER_DEFAULT_RAM_START)
sta MEMORY_MANAGER_MAX_RAM_SIZE
lda #>(MEMORY_MANAGER_DEFAULT_RAM_END - MEMORY_MANAGER_DEFAULT_RAM_START)
sta MEMORY_MANAGER_MAX_RAM_SIZE + 1
lda #<MEMORY_MANAGER_DEFAULT_RAM_END
sta MEMORY_MANAGER_RAM_END
lda #>MEMORY_MANAGER_DEFAULT_RAM_END
sta MEMORY_MANAGER_RAM_END + 1
pla

jmp eof_memory_manager

!zone malloc_V_return_pRegBCarry ; reserves memory and returns the pointer to it
  ; exceeding the reservable memory, sets the carry to 0 (false)
!macro malloc_V_return_pRegBCarry vSize
  pha
  lda #<vSize
  sta FUNC_PARAM_1
  lda #>vSize
  sta FUNC_PARAM_2
  +malloc_return_pRegBCarry
  pla
!end

!zone malloc_return_pRegBCarry ; reserves memory and returns the pointer to it
  ; exceeding the reservable memory, sets the carry to 0 (false)
  ; size is in FUNC_PARAM_1/2
!macro malloc_return_pRegBCarry
  +push_xy
  
  ; if the stack pointer is already above the allocatable memory immediately return false
  +is_greater_16bit_AA_return_Carry MEMORY_MANAGER_RAM_STACK_POINTER, MEMORY_MANAGER_RAM_END
  bcs .tooMuchMemoryAllocated
  
  ; point regB to the start of the reserved memory
  +mov_16A16A MEMORY_MANAGER_RAM_STACK_POINTER, REGISTER_16_B
  ; increase the stack pointer
  +inc_16A16A MEMORY_MANAGER_RAM_STACK_POINTER, FUNC_PARAM_1

  ; check if we wanted to allocate too much memory
  +is_greater_16bit_AA_return_Carry MEMORY_MANAGER_RAM_STACK_POINTER, MEMORY_MANAGER_RAM_END
  bcs .tooMuchMemoryAllocated
  sec
  jmp .end
.tooMuchMemoryAllocated
  clc ; set the carry that the operation returns false
.end
  +pop_xy
!end

!zone block_alloc_VV_return_pRegBCarry ; reserve blocks of memory and returns the pointer to the block
  ; exceeding the reservable memory array, sets the carry
!macro block_alloc_VV_return_pRegBCarry vBlockSize, vBlockCount
  +push_xy
  
  ; if the stack pointer is already above the allocatable memory immediately return false
  +is_greater_16bit_AA_return_Carry MEMORY_MANAGER_RAM_STACK_POINTER, MEMORY_MANAGER_RAM_END
  bcs .tooMuchMemoryAllocated
  
  ; point regB to the start of the reserved memory
  +mov_16A16A MEMORY_MANAGER_RAM_STACK_POINTER, REGISTER_16_B
  ; increase the stack pointer
  +blockInc_AVV MEMORY_MANAGER_RAM_STACK_POINTER, vBlockSize, vBlockCount

  ; check if we wanted to allocate too much memory
  +is_greater_16bit_AA_return_Carry MEMORY_MANAGER_RAM_STACK_POINTER, MEMORY_MANAGER_RAM_END
  bcs .tooMuchMemoryAllocated
  sec
  jmp .end
.tooMuchMemoryAllocated
  clc ; set the carry that the operation returns false
.end
  +pop_xy
!end
  
  
eof_memory_manager