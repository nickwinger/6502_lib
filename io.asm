jmp eof_io


!zone load_file_APV
!macro load_file_APV load_adress, pFname, fname_length
  LDA #fname_length
  LDX pFname
  LDY pFname+1
  
  +load_file_A load_adress
!end

!zone load_file_AAV
!macro load_file_AAV load_adress, fname, fname_length
  LDA #fname_length
  LDX #<fname
  LDY #>fname
  
  +load_file_A load_adress
!end

!zone load_file_AAAV
!macro load_file_AAAV load_adress, fname_low, fname_high, fname_length
  LDA #fname_length
  LDX #fname_low
  LDY #fname_high
  
  +load_file_A load_adress
!end
      
!zone load_file_A
!macro load_file_A load_adress
JSR $FFBD     ; call SETNAM
        
        LDA #$01      ; fileno
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$00      ; $00 means: load to new address
        JSR $FFBA     ; call SETLFS

        LDX #<load_adress
        LDY #>load_adress
        LDA #$00      ; $00 means: load to memory (not verify)
        JSR $FFD5     ; call LOAD
        BCS .error    ; if carry set, a load error has happened
        jmp .end
        
.error
        ; Accumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

.end
!end

eof_io