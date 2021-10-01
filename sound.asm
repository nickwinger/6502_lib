SIDBASE = $D400

VOICE1BASE = $D400
VOICE2BASE = SIDBASE + 7
VOICE3BASE = SIDBASE + 14

;VOICEBASE_ARRAY 
;.word VOICE1BASE, VOICE2BASE, VOICE3BASE

FRELO1          = $D400 ;(54272)
FREHI1          = $D401 ;(54273)
PWLO1           = $D402 ;(54274)
PWHI1           = $D403 ;(54275)
VCREG1          = $D404 ;(54276)
ATDCY1          = $D405 ;(54277)
SUREL1          = $D406 ;(54278)
FRELO2          = $D407 ;(54279)
FREHI2          = $D408 ;(54280)
PWLO2           = $D409 ;(54281)
PWHI2           = $D40A ;(54282)
VCREG2          = $D40B ;(54283)
ATDCY2          = $D40C ;(54284)
SUREL2          = $D40D ;(54285)
FRELO3          = $D40E ;(54286)
FREHI3          = $D40F ;(54287)
PWLO3           = $D410 ;(54288)
PWHI3           = $D411 ;(54289)
VCREG3          = $D412 ;(54290)
ATDCY3          = $D413 ;(54291)
SUREL3          = $D414 ;(54292)
SIGVOL          = $D418 ;(54296)  

  jmp eof_sound

play_voice1
  PHA
  LDA VOICE1BASE+4
  jsr print_a
  ORA #%00000001
  STA VOICE1BASE+4
  PLA
  rts
  
stop_voice1
  PHA
  LDA VOICE1BASE+4
  jsr print_a
  AND #%11111110
  STA VOICE1BASE+4
  PLA
  rts
  
sid_no_filter
  pha
  ; FILTER CUTOFF LO-HI BYTE 
  LDA #1
  STA SIDBASE+21
  LDA #128
  STA SIDBASE+22
  ; FILTER RESONANCE 
  LDA #%11110000
  STA SIDBASE+23
  pla
  rts
  
sid_max_volume
  pha
  ; FILTER MODE AND VOLUME 
  LDA #15
  STA SIDBASE+24
  pla
  rts
  
cycle_motor
  pha

  jsr sid_max_volume
  jsr sid_no_filter
  
  ; VOICE 3 FREQUENCY, LO-HI BYTE 
  LDA #<5407
  STA SIDBASE+0
  LDA #>5407
  STA SIDBASE+1
  ; VOICE 3 PULSE WAVEFORM WIDTH, LO-HI BYTE 
  LDA #60
  STA SIDBASE+2
  LDA #7
  STA SIDBASE+3
  ; VOICE 3 WAVEFORM(S) NOISE 
  LDA #%00110010
  STA SIDBASE+4
  ; VOICE 3 ADSR
  LDA #%00010110
  STA SIDBASE+5
  LDA #%10001001
  STA SIDBASE+6


  pla
  rts

!zone init_sound
init_sound
  pha
  txa
  pha
  ; Clear all the SID registers
  ldx #0
  lda #0
.loop1  
  sta FRELO1,X
  inx
  cpx #$19
  bcc .loop1

  ldx #0
  lda #0
.loop2  
  sta FRELO2,X
  inx
  cpx #$19
  bcc .loop2

  ldx #0
  lda #0
.loop3  
  sta FRELO3,X
  inx
  cpx #$19
  bcc .loop3

  ; Volume & Filter Select
  lda #15
  sta SIGVOL

  pla
  tax
  pla
  rts
 
eof_sound