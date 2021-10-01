;===============================================================================
; Constants

jmp eof_sound2

TriangleStart   = 17
TriangleEnd     = 16
SawtoothStart   = 33
SawtoothEnd     = 32
PulseStart      = %01000001
PulseEnd        = %01000000
NoiseStart      = %10000001 ; 129
NoiseEnd        = %10000000 ; 128

Attack_2ms      = 0
Attack_8ms      = 16    ; 1<<4
Attack_16ms     = 32    ; 2<<4
Attack_24ms     = 48    ; 3<<4
Attack_38ms     = 64    ; 4<<4
Attack_56ms     = 80    ; 5<<4
Attack_68ms     = 96    ; 6<<4
Attack_80ms     = 112   ; 7<<4
Attack_100ms    = 128   ; 8<<4
Attack_250ms    = 144   ; 9<<4
Attack_500ms    = 160   ; 10<<4
Attack_800ms    = 176   ; 11<<4
Attack_1s       = 192   ; 12<<4
Attack_3s       = 208   ; 13<<4
Attack_5s       = 224   ; 14<<4
Attack_8s       = 240   ; 15<<4

Decay_6ms       = 0
Decay_24ms      = 1
Decay_48ms      = 2
Decay_72ms      = 3
Decay_114ms     = 4
Decay_168ms     = 5
Decay_204ms     = 6
Decay_240ms     = 7
Decay_300ms     = 8
Decay_750ms     = 9
Decay_1_5s      = 10
Decay_2_4s      = 11
Decay_3s        = 12
Decay_9s        = 13
Decay_15s       = 14
Decay_24s       = 15

Sustain_Vol0    = 0
Sustain_Vol1    = 16    ; 1<<4
Sustain_Vol2    = 32    ; 2<<4
Sustain_Vol3    = 48    ; 3<<4
Sustain_Vol4    = 64    ; 4<<4
Sustain_Vol5    = 80    ; 5<<4
Sustain_Vol6    = 96    ; 6<<4
Sustain_Vol7    = 112   ; 7<<4
Sustain_Vol8    = 128   ; 8<<4
Sustain_Vol9    = 144   ; 9<<4
Sustain_Vol10   = 160   ; 10<<4
Sustain_Vol11   = 176   ; 11<<4
Sustain_Vol12   = 192   ; 12<<4
Sustain_Vol13   = 208   ; 13<<4
Sustain_Vol14   = 224   ; 14<<4
Sustain_Vol15   = 240   ; 15<<4

Release_6ms     = 0
Release_24ms    = 1
Release_48ms    = 2
Release_72ms    = 3
Release_114ms   = 4
Release_168ms   = 5
Release_204ms   = 6
Release_240ms   = 7
Release_300ms   = 8
Release_750ms   = 9
Release_1_5s    = 10
Release_2_4s    = 11
Release_3s      = 12
Release_9s      = 13
Release_15s     = 14
Release_24s     = 15

CmdWave                 = 0
CmdAttackDecay          = 1
CmdSustainRelease       = 2
CmdFrequencyHigh        = 3
CmdFrequencyLow         = 4
CmdPulseWidthHigh       = 5
CmdPulseWidthLow        = 6
CmdDelay                = 7
CmdEnd                  = 8
CmdFreqInc              = 9

;===============================================================================
; Variables

soundVoiceActive        !byte 0, 0, 0
soundVoiceCmdPtrHigh    !byte 0, 0, 0
soundVoiceCmdPtrLow     !byte 0, 0, 0
soundVoiceCmdIndex      !byte 0, 0, 0
soundVoiceDelay         !byte 0, 0, 0
soundVoiceFreqIncSteps  !byte 0, 0, 0
soundVoiceFreqHi        !byte 0, 0, 0
soundVoiceFreqLo        !byte 0, 0, 0

;===============================================================================
; Pre-made sound effect comand buffers

soundOpenDoor   !byte CmdAttackDecay, Attack_68ms+Decay_24ms
                !byte CmdSustainRelease, Sustain_Vol1+Release_168ms                
                !byte CmdFrequencyHigh, 143
                !byte CmdFrequencyLow, 010
                !byte CmdWave, NoiseStart
                !byte CmdDelay, 15
                !byte CmdWave, NoiseEnd
                !byte CmdEnd
soundOpenDoorHigh   !byte >soundOpenDoor
soundOpenDoorLow  !byte <soundOpenDoor

soundUseKey     !byte CmdAttackDecay, Attack_500ms+Decay_24ms
                !byte CmdSustainRelease, Sustain_Vol4+Release_48ms                
                !byte CmdFrequencyHigh, 005
                !byte CmdFrequencyLow, 071
                !byte CmdWave, SawtoothStart
                !byte CmdDelay, 3
                !byte CmdWave, SawtoothEnd
                !byte CmdEnd

soundFiring     !byte CmdAttackDecay, Attack_2ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                !byte CmdWave, SawtoothStart
                !byte CmdFrequencyHigh, 18
                !byte CmdFrequencyLow, 209
                !byte CmdDelay, 5
                !byte CmdWave, SawtoothEnd

                !byte CmdAttackDecay, Attack_2ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                !byte CmdWave, SawtoothStart
                !byte CmdFrequencyHigh, 22
                !byte CmdFrequencyLow, 96
                !byte CmdDelay, 5
                !byte CmdWave, SawtoothEnd

                !byte CmdEnd
soundFiringHigh !byte >soundFiring
soundFiringLow  !byte <soundFiring

; --------------------------------------------------------

soundExplosion  !byte CmdWave, NoiseEnd
                !byte CmdAttackDecay, Attack_38ms+Decay_114ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_300ms
                !byte CmdFrequencyHigh, 21
                !byte CmdFrequencyLow, 31
                !byte CmdWave, NoiseStart
                !byte CmdDelay, 2
                !byte CmdWave, NoiseEnd
                !byte CmdEnd
soundExplosionHigh !byte >soundExplosion
soundExplosionLow  !byte <soundExplosion

soundKill       !byte CmdWave, SawtoothEnd
                !byte CmdAttackDecay, 1+1
                !byte CmdSustainRelease, Sustain_Vol10+1
                !byte CmdFrequencyHigh, >4291
                !byte CmdFrequencyLow, <4291
                !byte CmdWave, SawtoothStart
                !byte CmdDelay, 2
                !byte CmdWave, SawtoothEnd
                !byte CmdEnd
soundKillHigh !byte >soundKill
soundKillLow  !byte <soundKill

; --------------------------------------------------------

soundPickup     !byte CmdAttackDecay, Attack_2ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                !byte CmdFrequencyHigh, 84
                !byte CmdFrequencyLow, 125
                !byte CmdWave, SawtoothStart
                !byte CmdDelay, 5
                !byte CmdWave, SawtoothEnd

                !byte CmdAttackDecay, Attack_2ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_300ms
                !byte CmdFrequencyHigh, 100
                !byte CmdFrequencyLow, 121
                !byte CmdWave, SawtoothStart
                !byte CmdDelay, 5
                !byte CmdWave, SawtoothEnd

                !byte CmdEnd
soundPickupHigh !byte >soundPickup
soundPickupLow  !byte <soundPickup


soundJump       !byte CmdAttackDecay, Attack_8ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_24ms
                !byte CmdFrequencyHigh, >4291
                !byte CmdFrequencyLow, <4291
                !byte CmdWave, TriangleStart
                !byte CmdDelay, 5
                !byte CmdFreqInc, 250, 7, 0
                !byte CmdWave, TriangleEnd
                !byte CmdEnd
soundJumpHigh !byte >soundJump
soundJumpLow  !byte <soundJump

; --------------------------------------------------------

soundEnding     !byte CmdPulseWidthHigh, 8
                !byte CmdPulseWidthLow, 128
                !byte CmdFrequencyHigh, 56
                !byte CmdFrequencyLow, 99

                !byte CmdAttackDecay, Attack_2ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                !byte CmdWave, PulseStart
                !byte CmdDelay, 5
                !byte CmdWave, PulseEnd

                !byte CmdDelay, 1

                !byte CmdAttackDecay, Attack_2ms+Decay_6ms
                !byte CmdSustainRelease, Sustain_Vol10+Release_750ms
                !byte CmdWave, PulseStart
                !byte CmdDelay, 30
                !byte CmdWave, PulseEnd

                !byte CmdEnd
soundEndingHigh !byte >soundEnding
soundEndingLow  !byte <soundEnding

;===============================================================================
; Macros/Subroutines

!zone libSoundInit
libSoundInit

        ; Clear all the SID registers
        ldx #0
        lda #0
.loop1  sta FRELO1,X
        inx
        cpx #$19
        bcc .loop1

        ldx #0
        lda #0
.loop2  sta FRELO2,X
        inx
        cpx #$19
        bcc .loop2

        ldx #0
        lda #0
.loop3  sta FRELO3,X
        inx
        cpx #$19
        bcc .loop3

        ; Volume & Filter Select
        lda #15
        sta SIGVOL

        rts

;===============================================================================

!zone LIBSOUND_PLAY_VAA
!macro LIBSOUND_PLAY_VAA vVoice, aCommandBufferHigh, aCommandBufferLow
                        ; /1 = Voice                   (Value)
                        ; /2 = Command Buffer Ptr High (Address)
                        ; /3 = Command Buffer Ptr Low  (Address)

  ldx #vVoice

  lda aCommandBufferHigh
  sta soundVoiceCmdPtrHigh,X

  lda aCommandBufferLow
  sta soundVoiceCmdPtrLow,X

  lda #1
  sta soundVoiceActive,X

  lda #0
  sta soundVoiceCmdIndex,X

!end

!zone LIBSOUND_PLAY_VA
!macro LIBSOUND_PLAY_VA vVoice, aCommandBuffer
  ldx #vVoice

  lda #>aCommandBuffer
  sta soundVoiceCmdPtrHigh,X

  lda #<aCommandBuffer
  sta soundVoiceCmdPtrLow,X

  lda #1
  sta soundVoiceActive,X

  lda #0
  sta soundVoiceCmdIndex,X
!end

;===============================================================================
!zone LIBSOUND_PROCESSWAVE
!macro LIBSOUND_PROCESSWAVE
lSUWave
        cmp #CmdWave
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
 
        cpx #0
        bne .reg2
        sta VCREG1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta VCREG2
        jmp .regdone
.reg3   
        sta VCREG3
.regdone        
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip
  ;rts
!end

;===============================================================================
!zone LIBSOUND_PROCESSATTACKDECAY
!macro    LIBSOUND_PROCESSATTACKDECAY
        
lSUAttackDecay
        cmp #CmdAttackDecay
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y

        cpx #0
        bne .reg2
        sta ATDCY1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta ATDCY2
        jmp .regdone
.reg3   
        sta ATDCY3
.regdone        
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip
  
        !end

;===============================================================================
!zone LIBSOUND_PROCESSSUSTAINRELEASE
!macro    LIBSOUND_PROCESSSUSTAINRELEASE
        
lSUSustainRelease
        cmp #CmdSustainRelease
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        
        cpx #0
        bne .reg2
        sta SUREL1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta SUREL2
        jmp .regdone
.reg3   
        sta SUREL3
.regdone     
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip

        !end

;===============================================================================
!zone LIBSOUND_PROCESSFREQUENCYHIGH
!macro    LIBSOUND_PROCESSFREQUENCYHIGH
        
lSUFrequencyHigh
        cmp #CmdFrequencyHigh
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        sta soundVoiceFreqHi, X
        
        cpx #0
        bne .reg2
        sta FREHI1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta FREHI2
        jmp .regdone
.reg3   
        sta FREHI3
.regdone
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip

        !end

;===============================================================================
!zone LIBSOUND_PROCESSFREQUENCYLOW
!macro    LIBSOUND_PROCESSFREQUENCYLOW
        
lSUFrequencyLow
        cmp #CmdFrequencyLow
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        sta soundVoiceFreqLo, X
        
        cpx #0
        bne .reg2
        sta FRELO1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta FRELO2
        jmp .regdone
.reg3   
        sta FRELO3
.regdone
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip

        !end

;===============================================================================
!zone LIBSOUND_PROCESSPULSEWIDTHHIGH
!macro    LIBSOUND_PROCESSPULSEWIDTHHIGH
        
lSUPulseWidthHigh
        cmp #CmdPulseWidthHigh
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y

        cpx #0
        bne .reg2
        sta PWHI1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta PWHI2
        jmp .regdone
.reg3   
        sta PWHI3
.regdone
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip

        !end

;===============================================================================

!zone LIBSOUND_PROCESSPULSEWIDTHLOW
!macro    LIBSOUND_PROCESSPULSEWIDTHLOW
        
lSUPulseWidthLow
        cmp #CmdPulseWidthLow
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        
        cpx #0
        bne .reg2
        sta PWLO1
        jmp .regdone
.reg2 
        cpx #1
        bne .reg3
        sta PWLO2
        jmp .regdone
.reg3   
        sta PWLO3
.regdone
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
.skip

        !end

;===============================================================================

!zone LIBSOUND_PROCESSDELAY
!macro    LIBSOUND_PROCESSDELAY
lSUDelay
        cmp #CmdDelay
        bne .skip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        sta soundVoiceDelay,X
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        jmp lSUDone
.skip

        !end

;===============================================================================

!zone LIBSOUND_PROCESSEND
!macro    LIBSOUND_PROCESSEND
     
lSUEnd   
        cmp #CmdEnd
        bne .skip
        lda #0
        sta soundVoiceActive,X
        sta soundVoiceCmdIndex,X
        jmp lSUDone
.skip
        !end

;===============================================================================
!zone LIBSOUND_CmdFreqInc
!macro    LIBSOUND_CmdFreqInc
        
        cmp #CmdFreqInc
        beq .doNotSkip
        jmp .skip
.doNotSkip
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        
        lda soundVoiceFreqLo,X
        clc 
        adc (POINTER),Y
        sta soundVoiceFreqLo,X
        lda soundVoiceFreqHi,X
        adc #0
        sta soundVoiceFreqHi,X
        
        ; set new lo freq
        cpx #0
        bne .regLo2
        lda soundVoiceFreqLo,X
        sta FRELO1
        lda soundVoiceFreqHi,X
        sta FREHI1
        jmp .regLodone
.regLo2 
        cpx #1
        bne .regLo3
        lda soundVoiceFreqLo,X
        sta FRELO2
        lda soundVoiceFreqHi,X
        sta FREHI2
        jmp .regLodone
.regLo3   
        clc
        lda soundVoiceFreqLo,X
        sta FRELO3
        lda soundVoiceFreqHi,X
        sta FREHI3
.regLodone

       
        ; steps
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y       
        ; only set this new if not zero
        lda soundVoiceFreqIncSteps,X
        bne .noNewSet
        lda (POINTER),Y
        sta soundVoiceFreqIncSteps,X
        
.noNewSet    
        dec soundVoiceFreqIncSteps,X
        
        ; delay
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        ; only store delay if not zero
        lda soundVoiceDelay ,X
        bne .noNewDelaySet
        lda (POINTER),Y
        sta soundVoiceDelay,X
.noNewDelaySet
       
        ; we are done when all the steps are finished
        lda soundVoiceFreqIncSteps,X
        cmp #1
        bne .notDoneYet
        inc soundVoiceCmdIndex,X ; move to next !byte
        ldy soundVoiceCmdIndex,X
        lda (POINTER),Y
        jmp lSUDone
.notDoneYet
        ; if not done yet, reverse to the start of the command
        dec soundVoiceCmdIndex,X
        dec soundVoiceCmdIndex,X
        dec soundVoiceCmdIndex,X
        jmp lSUDone
.skip

        !end

;===============================================================================
!zone libSoundUpdate
libSoundUpdate

        ldx #0
lSULoop
        lda soundVoiceActive,X
        bne lSUActive
        jmp lSUDone
lSUActive
        lda soundVoiceDelay,X
        beq lSUProcess
        dec soundVoiceDelay,X
        jmp lSUDone
lSUProcess

        lda soundVoiceCmdPtrLow,X ; load low address !byte
        sta POINTER

        lda soundVoiceCmdPtrHigh,X ; load high address !byte
        sta POINTER+1

        ldy soundVoiceCmdIndex,X ; load x position into Y register
        lda (POINTER),Y     ; load the command

        
lSUProcessLoop
        ; process the command
        +LIBSOUND_PROCESSWAVE
        +LIBSOUND_PROCESSATTACKDECAY
        +LIBSOUND_PROCESSSUSTAINRELEASE
        +LIBSOUND_PROCESSFREQUENCYHIGH
        +LIBSOUND_PROCESSFREQUENCYLOW
        +LIBSOUND_PROCESSPULSEWIDTHHIGH
        +LIBSOUND_PROCESSPULSEWIDTHLOW
        +LIBSOUND_CmdFreqInc
        +LIBSOUND_PROCESSDELAY
        +LIBSOUND_PROCESSEND
        jmp lSUProcessLoop

lSUDone
        inx
        cpx #3
        beq lSUFinished
        jmp lSULoop
lSUFinished

        rts
        
eof_sound2


