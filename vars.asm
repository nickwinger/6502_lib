GROUND = $66

  jmp eof_vars
  
CIA1_CLOCK_TENTH    = $dc08         ;Adresse zehntel Sekunden (Uhrzeit) im CIA1
CIA1_CLOCK_SECONDS  = $dc09         ;Adresse Sekunden (Uhrzeit) im CIA1

SCREEN_WIDTH  = $28 ; 40
SCREEN_HEIGHT  = $19 ; 25
SCREEN_SIZE = $3e8 ; 1000

GAME_SPEED = 5
; PLAYER
POINTER = $fd  ; 16bit $c2 + $c3 (textmode = 1000 chars (40x25))
SCREEN_POINTER = $fb ; 16bit
ZERO_PAGE_BYTE = $02 ; one of the few free zero page bytes of the c64

VARIABLES_START       = $c000
PLAYER_DIRECTION      = VARIABLES_START
TEMP_VAR              = VARIABLES_START+1
STACK_A               = VARIABLES_START+2
STACK_X               = VARIABLES_START+3
STACK_Y               = VARIABLES_START+4
SELECTED_INPUT_DEVICE = VARIABLES_START+5
ACTIVE_INPUT_STATE    = VARIABLES_START+6
PLAYER_POS            = VARIABLES_START+7 ; 16bit
;*** Platzhalter für unseren Startwert
RANDOM_SEED           = VARIABLES_START+9
GAME_LOOP_COUNTER     = VARIABLES_START+10
 
 
level1
!media "level1.charscreen",charcolor

eof_vars
}