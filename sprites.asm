
jmp eof_sprites

  SPRITE0X            = $d000   ;(00) X-Position von Sprite 0
SPRITE0Y            = $d001   ;(01) Y-Position von Sprite 0
SPRITE1X            = $d002   ;(02) X-Position von Sprite 1
SPRITE1Y            = $d003   ;(03) Y-Position von Sprite 1
SPRITE2X            = $d004   ;(04) X-Position von Sprite 2
SPRITE2Y            = $d005   ;(05) Y-Position von Sprite 2
SPRITE3X            = $d006   ;(06) X-Position von Sprite 3
SPRITE3Y            = $d007   ;(07) Y-Position von Sprite 3
SPRITE4X            = $d008   ;(08) X-Position von Sprite 4
SPRITE4Y            = $d009   ;(09) Y-Position von Sprite 4
SPRITE5X            = $d00a   ;(10) X-Position von Sprite 5
SPRITE5Y            = $d00b   ;(11) Y-Position von Sprite 5
SPRITE6X            = $d00c   ;(12) X-Position von Sprite 6
SPRITE6Y            = $d00d   ;(13) Y-Position von Sprite 6
SPRITE7X            = $d00e   ;(14) X-Position von Sprite 7
SPRITE7Y            = $d00f   ;(15) Y-Position von Sprite 7
SPRITESMAXX         = $d010   ;(16) Höhstes BIT der jeweiligen X-Position
                              ;        da der BS 320 Punkte breit ist reicht
                              ;        ein !byte für die X-Position nicht aus!
                              ;        Daher wird hier das 9. Bit der X-Pos
                              ;        gespeichert. BIT-Nr. (0-7) = Sprite-Nr.
                              ;        Bit-Nr. = Sprite-Nr.
SPRITEACTIV         = $d015         ;(21) Bestimmt welche Sprites sichtbar sind
      ;        Bit-Nr. = Sprite-Nr.
SPRITEDOUBLEHEIGHT  = $d017   ;(23) Doppelte Höhe der Sprites
                              ;        Bit-Nr. = Sprite-Nr.
SPRITEDEEP          = $d01B   ;(27) Legt fest ob ein Sprite vor oder hinter
                              ;        dem Hintergrund erscheinen soll.
                              ;        Bit = 1: Hintergrund vor dem Sprite
                              ;        Bit-Nr. = Sprite-Nr.
SPRITEMULTICOLOR    = $d01c        ;(28) Bit = 1: MultiColor Sprite 
                              ;        Bit-Nr. = Sprite-Nr.
SPRITEDOUBLEWIDTH   = $d01d   ;(29) Bit = 1: Doppelte Breite des Sprites
                              ;        Bit-Nr. = Sprite-Nr.
SPRITEMULTICOLOR0   = $d025   ;(37) Spritefarbe 0 im Multicolormodus
SPRITEMULTICOLOR1   = $d026   ;(38) Spritefarbe 1 im Multicolormodus
SPRITE0COLOR        = $d027   ;(39) Farbe von Sprite 0
SPRITE1COLOR        = $d028   ;(40) Farbe von Sprite 1
SPRITE2COLOR        = $d029   ;(41) Farbe von Sprite 2
SPRITE3COLOR        = $d02a   ;(42) Farbe von Sprite 3
SPRITE4COLOR        = $d02b   ;(43) Farbe von Sprite 4
SPRITE5COLOR        = $d02c   ;(44) Farbe von Sprite 5
SPRITE6COLOR        = $d02d   ;(45) Farbe von Sprite 6
SPRITE7COLOR        = $d02e   ;(46) Farbe von Sprite 7

SPRITE0DATA         = SCREENRAM+$03f8   ;Sprite-Pointer für die                                     ;Adresse der Sprite-0-Daten
SPRITE1DATA         = SPRITE0DATA+1   ;wie eben, nur für Sprite-1

!macro set_sprite_foreground_V
  lda #%00000000               ;Alle Sprites vor dem Hintergrund anzeigen
  sta SPRITEDEEP
!end

!macro set_sprite_highres_V
  lda #%00000000               ;nur Sprite-1 ist Mulicolor, der Rest Hi-Res
  sta SPRITEMULTICOLOR         ;Multicolor für Sprite-1 aktivieren
!end

!macro set_sprite_double_size_V
  lda #%00000000               ;Keine Vergrößerung gewünscht
  sta SPRITEDOUBLEHEIGHT       ;doppelte Höhe zurücksetzen
  sta SPRITEDOUBLEWIDTH        ;doppelte Breite zurücksetzen
!end

!zone set_sprite_data_PrmRegBRegX
set_sprite_data_PrmRegBRegX                 
  ; increase the reg_b pointer to the correct spriteDataIndex
.loopSpriteDataIndex
  cpx #0
  beq .breakLoopSpriteDataIndex
  +bit16_adc_16A16V REGISTER_16_B, 64
  dex
  jmp .loopSpriteDataIndex
.breakLoopSpriteDataIndex

  ldx #$06                            ;Schleifenzähler fürs Teilen durch 64
.loop
  lsr REGISTER_16_B+1                 ;MSB nach rechts 'shiften'
  ror REGISTER_16_B                   ;LSB nach rechts 'rotieren', wg. Carry-Flag!
  dex                                 ;Schleifenzähler verringern
  bne .loop                           ;wenn nicht 0, nochmal

  lda REGISTER_16_B                   ;Im LSB des 'Hilfsregisters' steht der 64-Byte-Block
  ldy FUNC_set_sprite_Vic_Index
  sta SPRITE0DATA, y         ;In der zuständigen Speicherstelle ablegen
  rts

!zone set_sprite_data_VAA
!macro set_sprite_data_VAA vSpriteNo, aSpriteData, aSpriteDataIndex
  +ldb aSpriteData     
  lda #vSpriteNo
  sta FUNC_set_sprite_Vic_Index
  ldx aSpriteDataIndex
  jsr set_sprite_data_PrmRegBRegX
!end


!zone set_sprite_color_VV
!macro set_sprite_color_VV vSpriteNo, vColor
  +push_ay
  ldy #vSpriteNo
  lda #vColor
  sta $D027, y
  +pop_ay
!end

!zone set_sprite_pos_VVV
!macro set_sprite_pos_VVV vSpriteNo, vSpriteX, vSpriteY
  +push_ay
  ldx #$00                     ;Zur Sicherheit das höchste
  stx SPRITESMAXX              ;Bit für die X-Position löschen
 
  lda #vSpriteNo
  asl ; mutiply by 2 to get the correct register index (x/y byte pairs)
  tay
  lda #vSpriteX
  sta VICSPRITES, y
  lda #vSpriteY
  iny
  sta VICSPRITES, y
  +pop_ay
!end

!zone set_sprite_pos_pObj
!macro set_sprite_pos_pObj pObj
  +push_ay
  ldx #$00                     ;Zur Sicherheit das höchste
  stx SPRITESMAXX              ;Bit für die X-Position löschen
  +lda_offset_PV pObj, OBJECT_VIC_SPRITE_INDEX
  ;lda FUNC_set_sprite_Vic_Index
  asl ; mutiply by 2 to get the correct register index (x/y byte pairs)
  tay
  +lda_offset_PV pObj, OBJECT_POS_X
  sta VICSPRITES, y
  +lda_offset_PV pObj, OBJECT_POS_Y
  iny
  sta VICSPRITES, y
  +pop_ay
!end

eof_sprites