RND_UG         = 4
RND_OG         = 7+1   

 
  ;*** eigenen Startwert ermitteln
 jsr rndSIDInit
 jsr rndSID
 sta RANDOM_SEED
 
 ;für rndBASIC
 lda #$00

 jmp eof_random
 
 
;*** gewünschte Zufallsfunktion wählen
getRandom
 jsr rndBASIC
 jsr rndRaster
 jsr rndSID
 jsr rndTIMER
 ;eor rndSeed                        ;für eine bessere Streuung, diese
 ;sta rndSeed                        ;beiden Zeilen einkommentieren
 rts                                ;zurück
 
 
 
getRandom_Range
 jsr getRandom                      ;Zufallszahl holen
 cmp #RND_OG-RND_UG                 ;prüfen ob im gewünschten Bereich
 bcs getRandom_Range                ;wenn nicht, neue Zufallszahl
 adc #RND_UG                        ;untere Grenze addieren
 rts                                ;zurück
 
!zone getRandom_VV_returnAccu
!macro getRandom_VV_returnAccu vMin, vMax
.start
 jsr getRandom                      ;Zufallszahl holen
 cmp #vMax-vMin                 ;prüfen ob im gewünschten Bereich
 bcs .start                ;wenn nicht, neue Zufallszahl
 adc #vMin                        ;untere Grenze addieren
!end  
 
rndBASIC
 jsr $e097
 lda $63
 rts
 
 
 
rndRaster
 lda $d012
 rts
 
 
 
rndSIDInit
 lda #$80                           ;Frequenz
 sta $d40e                          ;Low-Byte  der Frequenz für Stimme 3
 sta $d40f                          ;High-Byte der Frequenz für Stimme 3
 sta $d412                          ;Rauschen für die 3. Stimme setzen
 rts
 
rndSID
 lda $d41B
 rts
 
 
 
rndTIMER
 lda $dc04                          ;Low-Byte  von Timer A aus dem CIA-1
 eor $dc05                          ;High-Byte von Timer A aus dem CIA-1
 eor $dd04                          ;Low-Byte  von Timer A aus dem CIA-2
 adc $dd05                          ;High-Byte von Timer A aus dem CIA-2
 eor $dd06                          ;Low-Byte  von Timer B aus dem CIA-2
 eor $dd07                          ;High-Byte von Timer B aus dem CIA-2
 rts
 
 
 
eof_random