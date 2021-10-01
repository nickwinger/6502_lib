!ifndef GRAPHICS {
  GRAPHICS = 1

COLOR_BLACK         = $00          ;schwarz
COLOR_WHITE         = $01          ;weiß
COLOR_RED           = $02          ;rot
COLOR_CYAN          = $03          ;türkis
COLOR_PURPLE        = $04          ;lila
COLOR_GREEN         = $05          ;grün
COLOR_BLUE          = $06          ;blau
COLOR_YELLOW        = $07          ;gelb
COLOR_ORANGE        = $08          ;orange
COLOR_BROWN         = $09          ;braun
COLOR_PINK          = $0a          ;rosa
COLOR_DARKGREY      = $0b          ;dunkelgrau
COLOR_GREY          = $0c          ;grau
COLOR_LIGHTGREEN    = $0d          ;hellgrün
COLOR_LIGHTBLUE     = $0e          ;hellblau
COLOR_LIGHTGREY     = $0f          ;hellgrau

VICBASE             = $d000        ;(RG) = Register-Nr. dezimal
VICSPRITES          = VICBASE
VICBORDERCOLOR      = $d020        ;(32) Bildschirmrandfarbe
VICBACKGROUNDCOLOR  = $d021        ;(33) Hintergrundfarbe
VICCOLORRAM         = $d800
VICSCREENRAM        = $0400
SCREENRAM           = VICSCREENRAM
COLORRAM            = VICCOLORRAM
VICSCREEN_COLOR_OFFSET = VICCOLORRAM - VICSCREENRAM

jmp eof_lib_graphics


ScreenRAMRowStartLow ;  SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
        !byte <SCREENRAM,       <(SCREENRAM+40),  <(SCREENRAM+80)
        !byte <(SCREENRAM+120), <(SCREENRAM+160), <(SCREENRAM+200)
        !byte <(SCREENRAM+240), <(SCREENRAM+280), <(SCREENRAM+320)
        !byte <(SCREENRAM+360), <(SCREENRAM+400), <(SCREENRAM+440)
        !byte <(SCREENRAM+480), <(SCREENRAM+520), <(SCREENRAM+560)
        !byte <(SCREENRAM+600), <(SCREENRAM+640), <(SCREENRAM+680)
        !byte <(SCREENRAM+720), <(SCREENRAM+760), <(SCREENRAM+800)
        !byte <(SCREENRAM+840), <(SCREENRAM+880), <(SCREENRAM+920)
        !byte <(SCREENRAM+960)

ScreenRAMRowStartHigh ;  SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
        !byte >SCREENRAM,      >(SCREENRAM+40),  >(SCREENRAM+80)
        !byte >(SCREENRAM+120), >(SCREENRAM+160), >(SCREENRAM+200)
        !byte >(SCREENRAM+240), >(SCREENRAM+280), >(SCREENRAM+320)
        !byte >(SCREENRAM+360), >(SCREENRAM+400), >(SCREENRAM+440)
        !byte >(SCREENRAM+480), >(SCREENRAM+520), >(SCREENRAM+560)
        !byte >(SCREENRAM+600), >(SCREENRAM+640), >(SCREENRAM+680)
        !byte >(SCREENRAM+720), >(SCREENRAM+760), >(SCREENRAM+800)
        !byte >(SCREENRAM+840), >(SCREENRAM+880), >(SCREENRAM+920)
        !byte >(SCREENRAM+960)

ColorRAMRowStartLow ;  COLORRAM + 40*0, 40*1, 40*2 ... 40*24
        !byte <COLORRAM,      <(COLORRAM+40),  <(COLORRAM+80)
        !byte <(COLORRAM+120), <(COLORRAM+160), <(COLORRAM+200)
        !byte <(COLORRAM+240), <(COLORRAM+280), <(COLORRAM+320)
        !byte <(COLORRAM+360), <(COLORRAM+400), <(COLORRAM+440)
        !byte <(COLORRAM+480), <(COLORRAM+520), <(COLORRAM+560)
        !byte <(COLORRAM+600), <(COLORRAM+640), <(COLORRAM+680)
        !byte <(COLORRAM+720), <(COLORRAM+760), <(COLORRAM+800)
        !byte <(COLORRAM+840), <(COLORRAM+880), <(COLORRAM+920)
        !byte <(COLORRAM+960)

ColorRAMRowStartHigh ;  COLORRAM + 40*0, 40*1, 40*2 ... 40*24
        !byte >COLORRAM,     >(COLORRAM+40),  >(COLORRAM+80)
        !byte >(COLORRAM+120), >(COLORRAM+160), >(COLORRAM+200)
        !byte >(COLORRAM+240), >(COLORRAM+280), >(COLORRAM+320)
        !byte >(COLORRAM+360), >(COLORRAM+400), >(COLORRAM+440)
        !byte >(COLORRAM+480), >(COLORRAM+520), >(COLORRAM+560)
        !byte >(COLORRAM+600), >(COLORRAM+640), >(COLORRAM+680)
        !byte >(COLORRAM+720), >(COLORRAM+760), >(COLORRAM+800)
        !byte >(COLORRAM+840), >(COLORRAM+880), >(COLORRAM+920)
        !byte >(COLORRAM+960)

        
!macro drawChar_VV16V16V v1, v2, vx, vy ; char, color, x, y
  pha
  tya
  pha
  
  +set_pointer2 VICSCREENRAM
  +inc_16A16V POINTER2, (SCREEN_WIDTH * vy + vx)
  lda #v1
  ldy #0
  sta (POINTER2),y
  
  lda #v2
  +set_pointer2 VICCOLORRAM
  +inc_16A16V POINTER2, (SCREEN_WIDTH * vy + vx)
  sta (POINTER2),y
  
  pla
  tay
  pla
!end

!macro drawChar_AAAA aChar, aColor, aCol, aRow
  ; set char
  ldy aRow
  jsr set_screenpointer_row
  ldy aCol
  lda aChar
  sta (SCREEN_POINTER),Y
  
  ; set color
  ldy aRow
  jsr set_colorpointer_row
  ldy aCol
  lda aColor
  sta (SCREEN_POINTER),Y
!end

!macro drawChar_VVAA vChar, vColor, aCol, aRow
  lda #vColor
  sta FUNC_drawChar_VVAA_color
  +drawChar_VAAA vChar, FUNC_drawChar_VVAA_color, aCol, aRow
!end

!macro drawChar_VAAA vChar, aColor, aCol, aRow
  ; set char
  ldy aRow
  jsr set_screenpointer_row
  ldy aCol
  lda #vChar
  sta (SCREEN_POINTER),Y
  
  ; set color
  ldy aRow
  jsr set_colorpointer_row
  ldy aCol
  lda aColor
  sta (SCREEN_POINTER),Y
!end

!macro drawChar_VVVV vChar, vColor, vCol, vRow
  ; set char
  ldy #vRow
  jsr set_screenpointer_row
  ldy #vCol
  lda #vChar
  sta (SCREEN_POINTER),Y
  
  ; set color
  ldy #vRow
  jsr set_colorpointer_row
  ldy #vCol
  lda #vColor
  sta (SCREEN_POINTER),Y
!end

!macro drawChar_VV16A v1, v2, a1 ; char, color, offsetScreen (passed by adress)
  pha
  tya
  pha
  
  +set_pointer2 VICSCREENRAM
  +inc_16A16A POINTER2, a1
  lda #v1
  ldy #$0
  sta (POINTER2),y
  
  lda #v2
  +set_pointer2 VICCOLORRAM
  +inc_16A16A POINTER2, a1 
  sta (POINTER2),y
  
  pla
  tay
  pla
!end

!macro get_char_16A a1 ; loads the char at offset a1 into accu
  +set_pointer2 VICSCREENRAM
  +inc_16A16A POINTER2, a1
  ldy #$0
  lda (POINTER2),y
!end

!zone draw_screen_image
draw_screen_image                 ; image adress to draw is at x/y register
  pha
  
  stx POINTER                     ; pointer has start adress of image
  sty POINTER+1

  ; copy chars of image
  +set_pointer2 VICSCREENRAM
  +ldb 1000
  jsr copy_mem
  
  stx POINTER                     ; pointer has start adress of image
  sty POINTER+1
  
  +ldb 1000
  jsr inc_pointer_16bit           ; inc pointer by register b (1000) to find the color info
  
  +set_pointer2 VICCOLORRAM
  +ldb 1000
  jsr copy_mem
  
  pla
  rts
 
init_screenpointer
  pha
  +set_pointer2 VICSCREENRAM
  pla
  rts

inc_screenpointer
  pha
  clc
  lda SCREEN_POINTER
  adc #<$1
  sta SCREEN_POINTER
  lda SCREEN_POINTER+1
  adc #>$1
  sta SCREEN_POINTER+1
  pla
  rts
  
screenpointer_lower_right
  jsr init_screenpointer
  pha
  clc
  lda SCREEN_POINTER
  adc #<(SCREEN_SIZE-1)
  sta SCREEN_POINTER
  lda SCREEN_POINTER+1
  adc #>(SCREEN_SIZE-1)
  sta SCREEN_POINTER+1
  pla
  rts

screenpointer_lower_left
  jsr screenpointer_lower_right
  pha
  sec
  lda SCREEN_POINTER
  sbc #<(SCREEN_WIDTH-1)
  sta SCREEN_POINTER
  lda SCREEN_POINTER+1
  sbc #>(SCREEN_WIDTH-1)
  sta SCREEN_POINTER+1
  pla
  rts
  
screenpointer_sub_line
  pha
  sec
  lda SCREEN_POINTER
  sbc #<SCREEN_WIDTH
  sta SCREEN_POINTER
  lda SCREEN_POINTER+1
  sbc #>SCREEN_WIDTH
  sta SCREEN_POINTER+1
  pla
  rts
  
screenpointer_add_row
  pha
  clc
  lda SCREEN_POINTER
  adc #<SCREEN_WIDTH
  sta SCREEN_POINTER
  lda SCREEN_POINTER+1
  adc #>SCREEN_WIDTH
  sta SCREEN_POINTER+1
  pla
  rts

!zone get_relative_char_AAV
!macro get_relative_char_AAV aCol, aRow, vDirection ; loads the relative char into accu
  ldy aRow          ; load row
  lda #vDirection   ; check direction
  cmp #UP
  bne .notUp
  dey
.notUp
  cmp #DOWN
  bne .notDown
  iny
.notDown
  jsr set_screenpointer_row ; set screen pointer into correct row
  
  ldy aCol          ; load col
  cmp #LEFT
  bne .notLeft
  dey
.notLeft
  cmp #RIGHT
  bne .notRight
  iny
.notRight
  lda (SCREEN_POINTER),y
!end
  
set_screenpointer_row ; vRow = y
  pha
  lda ScreenRAMRowStartLow, y
  sta SCREEN_POINTER
  lda ScreenRAMRowStartHigh, y
  sta SCREEN_POINTER+1
  pla
  rts

set_screenpointer_row_regX ; vRow = y
  pha
  lda ScreenRAMRowStartLow, x
  sta SCREEN_POINTER
  lda ScreenRAMRowStartHigh, x
  sta SCREEN_POINTER+1
  pla
  rts
  
!macro set_screenpointer_row_V vRow
  ldy #vRow
  lda ScreenRAMRowStartLow, y
  sta SCREEN_POINTER
  lda ScreenRAMRowStartHigh, y
  sta SCREEN_POINTER+1
!end

set_colorpointer_row
  lda ColorRAMRowStartLow, y
  sta SCREEN_POINTER
  lda ColorRAMRowStartHigh, y
  sta SCREEN_POINTER+1
  rts
  
!macro set_colorpointer_row_V vRow
  ldy #vRow
  lda ColorRAMRowStartLow, y
  sta SCREEN_POINTER
  lda ColorRAMRowStartHigh, y
  sta SCREEN_POINTER+1
!end

!macro set_screenpointer_row_A aRow
  ldy aRow
  lda ScreenRAMRowStartLow, y
  sta SCREEN_POINTER
  lda ScreenRAMRowStartHigh, y
  sta SCREEN_POINTER+1
!end

!macro set_colorpointer_row_A aRow
  ldy aRow
  lda ColorRAMRowStartLow, y
  sta SCREEN_POINTER
  lda ColorRAMRowStartHigh, y
  sta SCREEN_POINTER+1
!end

!zone drawdecimal_VVAV
!macro  drawdecimal_VVAV vX, vY, aDec, vColor ; /1 = X Position 0-39 (Address)
                                ; /2 = Y Position 0-24 (Address)
                                ; /3 = decimal number 2 nybbles (Address)
                                ; /4 = Text Color (Value)
  ldy #vY
  jsr set_colorpointer_row
  lda POINTER2  ; store the color_pointer in pointer
  sta POINTER
  lda POINTER2+1
  sta POINTER+1
  jsr set_screenpointer_row
  
  ; save the digits (in reverse order) into an array, so we know the length to draw
  +set_TempArray10_V 11
  lda aDec
  ldy #0
  jmp .loop 
.outerLoop
  +div_V 10
.loop
  tax                   ; save the current digit
  +mod_V 10
  sta ZERO_PAGE_BYTE    ; save the modulo
  sta TEMP_ARRAY_10,y
  iny     ; move to next digit
  txa     ; get the current digit
  sec
  sbc ZERO_PAGE_BYTE  ; minus the modulo
  bne .outerLoop 
  
  ; get the length of the number
  ldx #$FF
.lengthloop
  inx
  lda TEMP_ARRAY_10,x
  cmp #11
  bne .lengthloop
  stx ZERO_PAGE_BYTE
  
  ; start the x coord at plus 10 (we draw backwards)
  lda #vX
  clc
  adc ZERO_PAGE_BYTE  ; length of number
  tay
  ; now draw the saved array backwards (digits of 11 means skip)
  ldx #$FF
.drawLoop
  inx
  cpx ZERO_PAGE_BYTE
  beq .endDrawLoop
  lda TEMP_ARRAY_10, x
  clc
  adc #PETSCII_NUMBERS_START ; to petscci char 
  sta (SCREEN_POINTER), y
  lda #vColor
  sta (POINTER),y
  dey
  jmp .drawLoop
.endDrawLoop
  
!end
                              
!macro  drawdecimal_VVAV2 vX, vY, aDec, color ; /1 = X Position 0-39 (Address)
                                ; /2 = Y Position 0-24 (Address)
                                ; /3 = decimal number 2 nybbles (Address)
                                ; /4 = Text Color (Value)
  ldy #vY
  jsr set_screenpointer_row
  

  ; get high nybble
  lda aDec
  and #$F0

  ; convert to ascii
  lsr
  lsr
  lsr
  lsr
  ora #$30

  ldy #vX ; load x position into Y register
  
  sta (SCREEN_POINTER),Y

  ; move along to next screen position
  iny 

  ; get low nybble
  lda aDec
  and #$0F

  ; convert to ascii
  ora #$30  
  lda #$01
  sta (SCREEN_POINTER),Y


  ldy vY
  jsr set_colorpointer_row
  ;+set_pointer2 VICCOLORRAM
  ;+inc_16A16V POINTER2, (SCREEN_WIDTH * vy + vx)
  
  ldy #vX ; load x position into Y register

  lda #color
  sta (SCREEN_POINTER),Y

  ; move along to next screen position
  iny 

  sta (SCREEN_POINTER),Y

!end

!zone print_a
print_a
  jsr init_screenpointer
  
  sta STACK_A
  sty STACK_Y
  
  ldy #$8
.loop
  ror
  sta TEMP_VAR           ; store the rolled a
  bcc .zero
  lda #$31
  jmp .print
.zero
  lda #$30
.print
  sta (SCREEN_POINTER),y
  lda TEMP_VAR
  dey
  bne .loop
  
  lda STACK_A
  ldy STACK_Y
  rts

!zone drawtext_VVAV
!macro drawtext_VVAV vX, vY, aText, vColor; /1 = X Position 0-39 (Value)
                      ; /2 = Y Position 0-24 (Val)ue
                      ; /3 = 0 terminated string (Address)
                      ; /4 = Text Color (Value)
  ldy #vX
  sty FUNC_drawtext_VVAV_X
  ldy #vY
  sty FUNC_drawtext_VVAV_Y
  
  +drawtext_AAAV FUNC_drawtext_VVAV_X, FUNC_drawtext_VVAV_Y, aText, vColor
!end

!zone drawtext_AAAV
!macro drawtext_AAAV aX, aY, aText, vColor; /1 = X Position 0-39 (Address)
                      ; /2 = Y Position 0-24 (Address)
                      ; /3 = 0 terminated string (Address)
                      ; /4 = Text Color (Value)
  
  ldy aY
  jsr set_screenpointer_row

  ldy aX ; load x position into Y register
  ldx #0
.loop   
  lda aText,X
  cmp #0
  beq .done
  sta (SCREEN_POINTER),Y
  inx
  iny
  jmp .loop
.done


  ldy aY ; load y position as index into list
  
  jsr set_colorpointer_row

  ldy aX ; load x position into Y register
  ldx #0
.loop2  
  lda aText,X
  cmp #0
  beq .done2
  lda #vColor
  sta (SCREEN_POINTER),Y
  inx
  iny
  jmp .loop2
.done2

!end

find_char_on_screen
  +push_axy
  
  ldx #0
  ldy #0
  jsr init_screenpointer
.loop
  lda (SCREEN_POINTER),y    ; y is actually col = x coord
  cmp FUNC_find_char_on_screen_Q
  beq .playerPosFound
  iny
  cpy #SCREEN_WIDTH
  bne .loop
  inx
  jsr screenpointer_add_row
  ldy #0
  cpx #SCREEN_HEIGHT
  bne .loop
.playerPosFound
  sty FUNC_find_char_on_screen_X
  stx FUNC_find_char_on_screen_Y
  
  +pop_axy
  rts
  
get_color_of_char ; char position is in x/y register, return color is in accu
  jsr set_colorpointer_row
  txa ; move x register to y register
  tay
  lda (SCREEN_POINTER),y
  rts
  
!zone find_first_char
!macro find_first_char_V vChar ; gets the first appearance of char (register a) on the screen, 
  ;position is in the x/y register (changed x = yCoord/row, y = xCoord/col)
  ; find the initial player position
  ldx #0
  ldy #0
  jsr init_screenpointer
.loop
  lda (SCREEN_POINTER),y    ; y is actually col = x coord
  cmp #vChar
  beq .posFound
  iny
  cpy #SCREEN_WIDTH
  bne .loop
  inx
  jsr screenpointer_add_row
  ldy #0
  cpx #SCREEN_HEIGHT
  bne .loop
.posNotFound
  ; if not found set return flag
  clc
  jmp .end
.posFound
  ; exchange x and y registers so that x is the xCoord
  +exchange_xy
  sec
.end
!end

!zone find_first_colorChar_color_VV
!macro find_first_colorChar_color_VV vChar, vColor ; gets the first appearance of char (register a) on the screen, 
  ;position is in the x/y register
  ; find the initial player position
  ldx #0
  ldy #0
  jsr init_screenpointer
.loop
  lda (SCREEN_POINTER),y    ; y is actually col = x coord
  cmp #vChar
  bne .charNotFound
  ; if char found check if color matches
  +ldb VICSCREEN_COLOR_OFFSET
  jsr inc_pointer2_16bit
  lda (SCREEN_POINTER),y ; color is now in accu
  and #$0f  ; vic colorram only uses the low nibble, high nibble is random
  cmp #vColor
  beq .posFound
  jsr dec_pointer2_16bit ; back to screen ram
.charNotFound
  iny
  cpy #SCREEN_WIDTH
  bne .loop
  inx
  jsr screenpointer_add_row
  ldy #0
  cpx #SCREEN_HEIGHT
  bne .loop
.posNotFound
  ; if not found set return flag
  clc
  jmp .end
.posFound
  ; exchange x and y registers so that x is the xCoord
  +exchange_xy
  sec
.end
!end

!zone replace_colorChar_color_VVV
!macro replace_colorChar_color_VVV vChar, vCharColor, vColor
  lda #vColor
  sta FUNC_replace_colorChar_color_VVV_color
  +replace_colorChar_color_VVA vChar, vCharColor, FUNC_replace_colorChar_color_VVV_color
!end

!zone replace_colorChar_color_VVA
!macro replace_colorChar_color_VVA vChar, vCharColor, aColor
  ldx #0
  ldy #0
  jsr init_screenpointer
.loop
  lda (SCREEN_POINTER),y    ; y is actually col = x coord
  cmp #vChar
  bne .continue
  ; if char found check if color matches
  +ldb VICSCREEN_COLOR_OFFSET
  jsr inc_pointer2_16bit
  lda (SCREEN_POINTER),y ; color is now in accu
  and #$0f  ; vic colorram only uses the low nibble, high nibble is random
  cmp #vCharColor
  beq .posFound
  jsr dec_pointer2_16bit ; back to screen ram
  jmp .continue
.posFound
  ; char found repaint it
  ;VICCOLORRAM         = $d800
  ;VICSCREENRAM        = $0400
  ; add the difference of the screen and color ram, to jump to the color position
  ; of the current char
  lda aColor ; now we are at the color ram
  sta (SCREEN_POINTER),y
  jsr dec_pointer2_16bit ; back to screen ram
.continue
  iny
  cpy #SCREEN_WIDTH
  bne .loop
  inx
  jsr screenpointer_add_row
  ldy #0
  cpx #SCREEN_HEIGHT
  bne .loop
!end

!zone replace_char_color
!macro replace_char_color_VV vChar, vColor ; searches through the screen and replaces the color when the given char is found
  ldx #0
  ldy #0
  jsr init_screenpointer
.loop
  lda (SCREEN_POINTER),y    ; y is actually col = x coord
  cmp #vChar
  bne .continue
  ; char found repaint it
  ;VICCOLORRAM         = $d800
  ;VICSCREENRAM        = $0400
  ; add the difference of the screen and color ram, to jump to the color position
  ; of the current char
  +ldb VICSCREEN_COLOR_OFFSET
  jsr inc_pointer2_16bit
  lda #vColor ; now we are at the color ram
  sta (SCREEN_POINTER),y
  jsr dec_pointer2_16bit ; back to screen ram
.continue
  iny
  cpy #SCREEN_WIDTH
  bne .loop
  inx
  jsr screenpointer_add_row
  ldy #0
  cpx #SCREEN_HEIGHT
  bne .loop
!end
  
!macro set_background_color_V vColor
  lda #vColor
  sta VICBACKGROUNDCOLOR
!end

!macro set_border_color_V vColor
  lda #vColor
  sta VICBORDERCOLOR
!end

!macro set_background_color_RegA
  sta VICBACKGROUNDCOLOR
!end

!macro set_border_color_RegA
  sta VICBORDERCOLOR
!end

eof_lib_graphics
}
  