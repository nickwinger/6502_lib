*=$0801
!byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
 
!source "vars.asm"
!source "random.asm"
!source "ext_registers.asm"
!source "pointer.asm"
!source "graphics.asm"
!source "control.asm"
!source "utils.asm"
!source "math.asm"
!source "lib_vars.asm"
!source "mem.asm"
!source "sound.asm"
!source "liner_gameloop.asm"

main
  ;jsr liner_init
  ;jsr liner_loop
  
  jsr jumping_cursor_init
  jsr jumping_cursor_loop
  
  rts
