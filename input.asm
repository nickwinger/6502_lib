!ifndef INPUT {
  INPUT = 1

jmp eof_input

; KEYS
KEY_REG_A = $dc00
KEY_REG_B = $dc01
INPUT_NONE          = $00          ;Es wurde noch kein Port gewählt
INPUT_JOY1          = $01          ;Joystick in Port-1
INPUT_JOY2          = $02          ;oder 2

JOY_UP    = %00000001
JOY_DOWN  = %00000010
JOY_LEFT  = %00000100
JOY_RIGHT = %00001000
JOY_FIRE  = %00010000  

JOY_MASKS ; in the sort like the KEY_FIRE, KEY_UP, KEY_DOWN vars have
!byte JOY_FIRE, JOY_UP, JOY_DOWN, JOY_LEFT, JOY_RIGHT


KEY_CURSOR_DOWN = $11
KEY_CURSOR_RIGHT = $1D 
KEY_CURSOR_UP = $91
KEY_CURSOR_LEFT = $9D

select_input_device
  rts

!zone check_pressed_fire
check_pressed_fire  ; sets the status registers, does not push a
  lda KEY_REG_B
  and #JOY_FIRE     ; z-flag: 0 = not pressed, 1 = pressed
  bne .end
  lda #0
  sta KEY_FIRE_PRESSED ; key pressed
  lda #0
  rts
.end
  lda #1 ; return value false
  rts

!zone check_released_fire
check_released_fire  ; sets the status registers, does not push a
  ; first we have to check if the button is or was pressed
  jsr check_pressed_fire
  ; only if key was pressed it can be a release
  lda KEY_FIRE_PRESSED
  bne .end
  ; actual check for released
  lda KEY_REG_B
  and #JOY_FIRE     ; z-flag: 0 = not pressed, 1 = pressed
  beq .end
  lda #1
  sta KEY_FIRE_PRESSED ; key released
  lda #0 ; return value 0 = true
  rts
.end
  lda #1 ; return false
  rts


!zone check_pressed_key_V
!macro check_pressed_key_V vKey ; sets the status registers, does not push a
  ldy #vKey
  lda KEY_REG_B
  and JOY_MASKS, y     ; z-flag: 0 = not pressed, 1 = pressed
  bne .returnFalse
  lda #0
  sta KEY_PRESSED, y ; key pressed
  sec
  jmp .end
.returnFalse
  clc ; return value false
.end
!end

!zone check_released_key_V
!macro check_released_key_V vKey ; sets the status registers, does not push a
  ; first we have to check if the button is or was pressed
  +check_pressed_key_V vKey
  ; only if key was pressed it can be a release
  ldy #vKey
  lda KEY_PRESSED, y
  bne .returnFalse
  ; actual check for released
  lda KEY_REG_B
  and JOY_MASKS, y     ; z-flag: 0 = not pressed, 1 = pressed
  beq .returnFalse
  lda #1
  sta KEY_PRESSED, y ; key released
  sec ; return value 0 = true
  jmp .end
.returnFalse
  clc ; return false
.end
!end


!zone wait_for_fire
wait_for_fire
  pha
.wait
  jsr check_pressed_fire
  bne .wait
  pla
  rts

!zone wait_for_joystick_selection
wait_for_joystick_selection
  lda #INPUT_NONE                   ;Aktuelles Eingabegerät auf unbekannt
  sta SELECTED_INPUT_DEVICE                   ;setzen
 
.wait
  jsr select_input_device             ;Auf Eingabegerät prüfen
  lda SELECTED_INPUT_DEVICE                   ;Aktuelles Gerät in den Akku
  beq .wait 
  rts

check_pressed_left
  +check_pressed_key_V KEY_LEFT
  rts

check_released_left
  +check_released_key_V KEY_LEFT 
  rts

check_pressed_right
  +check_pressed_key_V KEY_RIGHT
  rts

check_released_right 
  +check_released_key_V KEY_RIGHT 
  rts
  
eof_input
}