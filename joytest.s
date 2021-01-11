  .include "bootstrap.s"

pra  = $dc00
prb  = $dc01
ddra = $dc02
ddrb = $dc03
icr  = $dc0d
icr2 = $dd0d

viccry = $d011
vicec  = $d020

; turn off CIA interrupts
  lda #$7f
  sei
  sta icr
  lda icr
  cli
; remap nmi
  lda #<nmi
  sta $fffa
  lda #>nmi
  sta $fffb
  lda #$35
  sta 1
; set ports to input
  lda #0
  sta ddra
  sta ddrb
; turn off display
  lda #11
  sta viccry

loop
  lda pra     ; 4
  sta vicec   ; 8
  lsr         ; 10
  lsr         ; 12
  lsr         ; 14
  lsr         ; 16
  sta vicec   ; 20
  lda prb     ; 24
  sta vicec   ; 28
  lsr         ; 30
  lsr         ; 32
  lsr         ; 34
  lsr         ; 36
  sta vicec   ; 40
  lda #0      ; 42
  nop         ; 44
  sta vicec   ; 48
  .rept 6
  nop
  .endr       ; 60
  jmp loop    ; 63

nmi
  rti
