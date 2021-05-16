         .include "bootstrap.s"
         jmp $4000
         .include "bump_sprite_data.s"

         ; BUMP2.ASS
         ;
         ; (C) Raah 1993
         ;
         ; Latest : 11-6  16:40

         *= $4000

         jsr init
         ldy #<bottomline
         lda #>bottomline
         ldx #250
         jsr showline
label    lda gover
         beq label
         ldy #<govert
         lda #>govert
         ldx #0
         jsr showline
         jmp exit

px       .word 344
py       .word 280
         .word 392,280
         .word 630,120
         .word 630,120,630,170
         .word 630,220,630,270
         .word 630,320

vx       .byte 0
vy       .byte 0
         .byte 0,0,0,0,0,0,0,0,0,0
         .byte 0,0,0,0

ax       .byte 0
ay       .byte 0
         .byte 0,0,0,0,0,0,0,0,0,0
         .byte 0,0,0,0

xmin     .word 48
ymin     .word 100
         .word 48,100,48,100,48,100
         .word 48,100,48,100,48,100
         .word 48,100

xmax     .word 640
ymax     .word 458
         .word 1000,458,640,458,640,458
         .word 640,458,640,458,640,458
         .word 640,458

vxmin    .byte 240
vymin    .byte 240
         .byte 252,252,250,250,248,248
         .byte 246,246,244,244,242,242
         .byte 240,240

vxmax    .byte 17
vymax    .byte 17
         .byte 49,9,7,7,9,9
         .byte 11,11,13,13,15,15
         .byte 17,17

on       .byte 0,0,0,0,0,0,0,0
time     .byte 0,0,0,0,0,0,0,0
adlo     .byte 0,0,0,0,0,0,0,0
adhi     .byte 0,0,0,0,0,0,0,0
adof     .byte 0,0,0,0,0,0,0,0

ads      .word seq00,seq01
         .word seq02,seq03
         .word seq04,seq05
         .word seq06,seq07
         .word seq08,seq09
         .word seq10,seq11
         .word seq12,seq13
         .word seq14,seq15

seq00    .byte 100,0,0
         .byte 1,1,0,0

seq01    .byte 4,1,1
         .byte 4,1,255
         .byte 4,255,255
         .byte 4,255,1
         .byte 0

seq02    .byte 10,255,0
         .byte 10,0,0,0

seq03    = seq01

seq04    .byte 4,1,255
         .byte 20,0,0
         .byte 4,255,1
         .byte 20,0,0,0

seq05    .byte 4,1,1
         .byte 4,255,1
         .byte 4,1,255
         .byte 4,1,1
         .byte 8,255,255,0

seq06    = seq01

seq07    .byte 200,1,0,0

seq08    .byte 200,0,1,0

seq09    .byte 20,0,1
         .byte 20,255,0,0

seq10    = seq01

seq11    = seq01

seq12    = seq04

seq13    = seq05

seq14    .byte 2,2,2
         .byte 200,0,0,0

seq15    .byte 16,1,1
         .byte 4,255,0
         .byte 200,0,0,0

scores   .byte 1,1,4,1
         .byte 2,2,1,1
         .byte 2,5,1,1
         .byte 2,2,3,3

ad       = 251

v2       .word 0
myscore  .byte 0,0
         .byte 0,0
         .byte 0,0
gover    .byte 0
col      .byte 0
beurt    .byte 0
soort    .byte 0
neen     .byte 0
jiffies  .byte 0
seconds  .byte 0
nshot    .byte 0
need     .byte 0
isave    .byte 0
jsave    .byte 0
ksave    .byte 0
lsave    .byte 0
srsave   .byte 0
phase    .byte 0
ssave    .byte 0
csave    .byte 0
noscore  .byte 255
notheir  .byte 255
nobal    .byte 255
vlag     .byte 255
linecount .byte 255
abal     .byte 0
sc       .byte 0
sc2      .byte 0
sound1   .byte 0
sound2   .byte 0
ieffcount .byte 20
effcount .byte 0
eofflink .word 0
eonlink  .word 0
count    .byte 0
windx    .byte 0
windy    .byte 0
joymask  .byte 0
bforce   .byte 0
slowbullet .byte 0

dirx     .byte 0,0,255,1
diry     .byte 1,1,0,1

eofflinks .word windoff,slowboff
         .word invisoff,inconoff

eonlinks .word windon,slowbon
         .word invison,inconon

etlinks  .word windt,slowbt
         .word invist,incont

color1   .byte 6,2,4,5,11,12,14,15
         .byte 9,9,8,5,11,11,11,11

color2   .byte 14,10,15,13,12,15,3,7
         .byte 8,5,7,7,14,5,10,3

color3   .byte 3,7,1,1,15,1,1,1
         .byte 7,7,1,1,1,1,1,1

freq1    .byte 0,255,240,255,240
         .byte 220,250,210,240,160,200
         .byte 0,10,130,5,110,17
         .byte 107,19,110

freq2    .byte 0,4,8,6,10
         .byte 20,12,60,20,50
         .byte 0,110,119,110,120
         .byte 110,120,110,112,110
         .byte 0,40,41,42,43
         .byte 44,45,46,47,48
         .byte 0,60,58,56
         .byte 0,58,56,54
         .byte 0,56,54,52
         .byte 0,54,52,50
         .byte 0,52,50,48
         .byte 0,50,48,46
         .byte 0,48,46,44
         .byte 0,46,44,42
         .byte 0,44,42,40
         .byte 0,42,40,38

         ; you 0000  they 0000  level 0000   time 0
statusline
         .byte $19,$f,$15,$20,$30,$30
         .byte $30,$30,$20,$20,$14,$8
         .byte $5,$19,$20,$30,$30,$30
         .byte $30,$20
         .byte $20,$c,$5,$16,$5,$c
         .byte $20,$30,$30,$30,$30,$20
         .byte $20,$20,$14,$9,$d,$5
         .byte $20,$30
statuscol
         .byte $1,$1,$1,$1,$1,$1
         .byte $1,$1,$7,$7,$7,$7
         .byte $7,$7,$7,$7,$7,$7
         .byte $7,$8
         .byte $8,$8,$8,$8,$8,$8
         .byte $8,$8,$8,$8,$8,$a
         .byte $a,$a,$a,$a,$a,$a
         .byte $a,$a

         ; mibosop/raah bump. (c) 1993
bottomline
         .byte $20,$20,$20,$20,$20,$20
         .byte $d,$9,$2,$f,$13,$f
         .byte $10,$2f,$12,$1,$1,$8
         .byte $20,$2
         .byte $15,$d,$10,$2e,$20,$28
         .byte $3,$29,$20,$31,$39,$39
         .byte $33
         .byte 0

         ; winds
windt    .byte $17,$9,$e,$4,$13
         .byte 0

         ; laser exhausted
slowbt   .byte $c,$1,$13,$5,$12,$20
         .byte $5,$18,$8,$1,$15,$13
         .byte $14,$5,$4
         .byte 0

         ; lights out
invist   .byte $c,$9,$7,$8,$14,$13
         .byte $20,$f,$15,$14
         .byte 0

         ; control failure
incont   .byte $3,$f,$e,$14,$12,$f
         .byte $c,$20,$6,$1,$9,$c
         .byte $15,$12,$5
         .byte 0

         ; start again !
againt   .byte $13,$14,$1,$12,$14,$20
         .byte $1,$7,$1,$9,$e,$20
         .byte $21
         .byte 0

         ; lucky you !
luckyt   .byte $c,$15,$3,$b,$19,$20
         .byte $19,$f,$15,$20,$21
         .byte 0

         ; game over
govert   .byte $7,$1,$d,$5,$20,$f
         .byte $16,$5,$12
         .byte 0

init     sei
         ldx #0
         lda #32
cls      sta $0400,x
         sta $0500,x
         sta $0600,x
         sta $0700,x
         inx
         bne cls
         ldx #39
copystatus lda statusline,x
         sta 1024,x
         lda statuscol,x
         sta 55296,x
         dex
         bpl copystatus
         lda $dd00
         ora #3
         sta $dd00
         lda #21
         sta 53272
         lda #127
         sta $dc0d
         sta $dd0d
         ; bugfix (28 years later)
         ; clear pending CIA interrupt
         bit $dc0d
         lda #5
         sta 53273
         sta 53274
         lda #144
         sta 2040
         lda #137
         sta 2041
         lda #255
         sta 53275
         sta 53276
         lda #155
         sta 53265
         lda #0
         sta 53266
         sta 53271
         sta 53277
         sta 53280
         sta 53281
         sta vx
         sta vy
         sta ax
         sta ay
         sta col
         sta jiffies
         sta nshot
         sta need
         sta abal
         sta gover
         sta neen
         sta joymask
         ldx #5
clrscore sta myscore,x
         dex
         bpl clrscore
         ldx #7
clrsprites sta on,x
         dex
         bpl clrsprites
         ldx #23
clsid    sta 54272,x
         dex
         bpl clsid
         lda #240
         sta 54278
         sta 54285
         sta 54292
         lda #17
         sta 54276
         lda #33
         sta 54283
         lda #129
         sta 54290
         lda #128
         sta 54287
         lda #31
         sta 54296
         lda #244
         sta 54295
         lda #20
         sta ieffcount
         sta effcount
         lda #8
         sta bforce
         lda #1
         sta on
         lda #60
         sta seconds
         lda #<344
         sta px
         lda #>344
         sta px+1
         lda #<280
         sta py
         lda #>280
         sta py+1
         lda #<int
         sta $0314
         lda #>int
         sta $0315
         jsr setcolor
         cli
         rts

exit     sei
         lda #0
         sta 53274
         sta 53269
         sta 54296
         lda 53273
         sta 53273
         lda #129
         sta $dc0d
         lda #<$ea31
         sta $0314
         lda #>$ea31
         sta $0315
         cli
         rts

int      lda 53273
         sta 53273
         sta isave
         and #1
         beq int1
         jsr raster
int1     lda isave
         and #4
         beq int3
         jsr spritesprite
int3     jmp $ea81

raster   jsr clock
         lda #255
         sta noscore
         sta notheir
         sta nobal
         sta vlag
         jsr spriteson
         jsr fireoff
         jsr enemies
         jsr score
         lda 53278
         lda 53279
         jsr compall
         jsr showspr
         jsr sounds
         jsr eoff
         jsr eon
         lda #0
         sta ax
         sta ay
         lda 56320
         ora joymask
         sta jsave
         lsr jsave
         bcs notu
         lda #255
         sta ay
notu     lsr jsave
         bcs notd
         lda #1
         sta ay
notd     lsr jsave
         bcs notl
         lda #255
         sta ax
notl     lsr jsave
         bcs notr
         lda #1
         sta ax
notr     lsr jsave
         bcs notf
         lda ksave
         bne return
         inc ksave
         jmp fire
notf     lda #0
         sta ksave
return   rts

fireoff  lda on+1
         beq return
         lda px+4
         cmp #<700
         lda px+5
         sbc #>700
         bcc return
         lda #0
         sta on+1
         rts

fire     lda on+1
         bne return
         lda #1
         sta on+1
         lda need
         cmp #12
         bcc noterug
         lda ax
         sec
         sbc #4
         sta ax
noterug  lda px
         clc
         adc #48
         sta px+4
         lda px+1
         adc #0
         sta px+5
         lda py
         sta py+4
         lda py+1
         sta py+5
         lda #0
         sta vx+2
         sta vy+2
         sta ay+2
         lda bforce
         sta ax+2
         rts

clock    inc phase
         lda linecount
         beq noline
         dec linecount
         bne noline
         jsr delline
noline   lda seconds
         beq timeup
         inc jiffies
         lda jiffies
         cmp #50
         bcc timeup
         lda #0
         sta jiffies
         dec seconds
         lda seconds
         cmp #10
         bcs timeup
         asl a
         asl a
         adc #34
         sta sound2
         lda seconds
         ora abal
         bne timeup
         inc gover
timeup   rts

spriteson ldx #7
son1     lda on,x
         clc
         beq son2
         cmp #1
         sec
         beq son2
         cmp #14
         bcs sequp
         clc
         adc #1
         cmp #14
         bcc son3
         lda #0
         sta on,x
         clc
         jmp son2
son3     sta on,x
         lsr a
         clc
         adc #137
         sta 2040,x
         sec
         jmp son2
sequp    clc
         adc #1
         cmp #26
         bcc son4
         lda #1
         sta on,x
         inc beurt
         lda beurt
         and #15
         ora #144
         sta 2040,x
         and #15
         asl a
         tay
         lda ads,y
         sta adlo,x
         lda ads+1,y
         sta adhi,x
         lda #0
         sta adof,x
         sta time,x
         sec
         jmp son2
son4     sta on,x
         lsr a
         sta srsave
         lda #150
         sec
         sbc srsave
         sta 2040,x
         sec
son2     rol 53269
         dex
         bpl son1
         lda phase
         lsr a
         and #7
         ora #128
         sta 2040
op       rts

enemies  ldx #2
enemies1 lda on,x
         beq noenemy
         cmp #2
         bcs next
         lda time,x
         beq newa
         dec time,x
next     inx
         cpx #8
         bcc enemies1
         rts
newa     lda adlo,x
         sta ad
         lda adhi,x
         sta ad+1
         lda adof,x
         tay
         lda (ad),y
         bne newa1
         tay
         lda (ad),y
newa1    sta time,x
         txa
         pha
         asl a
         tax
         iny
         lda (ad),y
         sta ax,x
         iny
         lda (ad),y
         sta ay,x
         iny
         pla
         tax
         tya
         sta adof,x
         jmp next
noenemy  lda 54299
         ora 54299
         eor #13
         bne next
         lda #14
         sta on,x
         txa
         pha
         asl a
         tax
         lda #2
         sta vx,x
         lda #0
         sta vy,x
         sta ax,x
         sta ay,x
         txa
         asl a
         tax
         lda #52
         sta px,x
         lda #0
         sta px+1,x
         lda 56324
         cmp #170
         bcc noe1
         sbc #100
noe1     clc
         adc #51
         asl a
         sta py,x
         lda #0
         rol a
         sta py+1,x
         pla
         tax
         jmp next

spritesprite lda 53278
         sta ssave
         and #1
         bne geraakt
         lda ssave
         and #2
         bne raak
         rts

geraakt  ldx #0
         lda #1
ss1      lsr ssave
         bcc niks1
         cpx #2
         bcc niks1
         lda 2040,x
         cmp #144
         bcc bal1
         lda #2
         sta on,x
         lda #138
         sta 2040,x
         lda #0
         sta noscore
         jsr addtheir
         jmp niks1
bal1     cmp #136
         bne niks1
         lda #0
         sta on,x
         jsr addbal
niks1    inx
         cpx #8
         bcc ss1
niks     rts

raak     ldx #0
         lda #1
ss0      lsr ssave
         bcc niks2
         cpx #2
         bcc niks2
         lda 2040,x
         cmp #144
         bcc niks2
         and #15
         tay
         lda scores,y
         sta soort
         lda abal
         bne raak2
         inc nshot
         lda need
         cmp nshot
         bcs geenbal
         lda #0
         sta nshot
         lda #1
         sta abal
         lda #136
         sta 2040,x
         jsr addmy
         jmp niks2
raak2    jsr addtheir
         jmp niks3
geenbal  jsr addmy
ontplof  lda #2
         sta on,x
         lda #138
         sta 2040,x
niks3    lda #0
         sta on+1
niks2    inx
         cpx #8
         bcc ss0
         rts

score    ldx #0
         ldy #4
         jsr score0
         ldx #2
         ldy #15
         jsr score0
         ldx #4
         ldy #27
         jsr score0
         lda seconds
         ldx #48
         beq sec0
         ldx #32
         cmp #10
         bcs sec0
         adc #48
         tax
sec0     stx 1063
         rts

score0   lda #1
         sta sc
         lda #0
         sta sc2
score1   lda myscore,x
         lsr a
         lsr a
         lsr a
         lsr a
         jsr score3
         lda myscore,x
         and #15
         jsr score3
         inx
         dec sc
         bpl score1
         rts

score3   bne nietnul
         lda sc2
         bne tochnul
         lda #32
         .byte 44
tochnul  lda #48
         jmp score2
nietnul  inc sc2
         ora #48
score2   sta 1024,y
         iny
         rts

comp     clc
         adc ax,x
         clc
         adc vx,x
         sta v2
         cmp vxmax,x
         bcc ok
         cmp vxmin,x
         bcc notok
ok       lda v2
         sta vx,x
notok    lda #0
         sta 2
         lda vx,x
         bpl vplus
         lda #255
         sta 2
vplus    lda px,y
         clc
         adc vx,x
         sta v2
         lda px+1,y
         adc 2
         sta v2+1
         lda v2
         cmp xmin,y
         lda v2+1
         sbc xmin+1,y
         bcc bump
         lda v2
         cmp xmax,y
         lda v2+1
         sbc xmax+1,y
         bcc ok2
bump     lda #0
         sec
         sbc vx,x
         sta vx,x
         jmp notok

ok2      lda v2
         sta px,y
         lda v2+1
         sta px+1,y
         rts

compall  ldx #0
         ldy #0
compall1 lda windx
         jsr comp
         inx
         iny
         iny
         lda windy
         jsr comp
         inx
         iny
         iny
         cpx #16
         bcc compall1
         rts

showspr  ldx #0
         ldy #0
         stx v2
showspr1 lda px,y
         sta 53248,x
         lda px+1,y
         lsr a
         ror 53248,x
         lsr a
         ror v2
         inx
         inx
         iny
         iny
         iny
         iny
         cpx #16
         bcc showspr1
         lda v2
         sta 53264
         ldx #0
         ldy #0
showspr2 lda px+3,y
         lsr a
         lda px+2,y
         ror a
         sta 53249,x
         inx
         inx
         iny
         iny
         iny
         iny
         cpx #16
         bcc showspr2
         rts

addbal   lda nobal
         beq add0
         lda seconds
         ldy #0
         sty nobal
         sty abal
         sty jiffies
         sty nshot
         ldy #60
         sty seconds
         tay
         beq geenpunt
         pha
         jsr windoff
         jsr slowboff
         jsr invisoff
         jsr inconoff
         jsr delline
         pla
         cmp #10
         bcs snel
         ldy #<luckyt
         lda #>luckyt
         ldx #200
         jsr showline
snel     lda #0
         sta neen
         lda #20
         sta sound1
         inc need
         ldx ieffcount
         dex
         beq not9
         stx ieffcount
not9     inc col
         lda col
         and #15
         sta col
         jsr setcolor
         ldy #4
punt     lda #1
         jmp add2

geenpunt lda #20
         sta sound2
         sta neen
         ldy #<againt
         lda #>againt
         ldx #200
         jsr showline
add0     rts

addmy    lda neen
         bne add0
         lda noscore
         beq add0
         lda #0
         sta noscore
         lda #10
         sta sound1
         ldy #0
         lda soort
         jmp add2

addtheir lda notheir
         beq add0
         lda #0
         sta noscore
         sta notheir
         lda effcount
         beq add3
         dec effcount
add3     lda #10
         sta sound2
         ldy #2
         lda #1
add2     clc
         sed
         adc myscore+1,y
         sta myscore+1,y
         lda #0
         adc myscore,y
         sta myscore,y
         bcc addok
         inc gover
addok    cld
         rts

setcolor ldx col
         lda color1,x
         sta 53285
         lda color2,x
         ldy #7
setcolor1 sta 53287,y
         dey
         bpl setcolor1
         lda color3,x
         sta 53286
         rts

sounds   ldx sound1
         dex
         bmi nosound1
         lda freq1,x
         sta 54273
         bne notend1
         tax
notend1  stx sound1
nosound1 ldx sound2
         dex
         bmi noise
         lda freq2,x
         sta 54280
         bne notend2
         tax
notend2  stx sound2
noise    lda vx
         bpl noise1
         eor #255
         clc
         adc #1
noise1   sta lsave
         lda vy
         bpl noise2
         eor #255
         clc
         adc #1
noise2   clc
         adc lsave
         cmp #15
         bcc noise3
         lda #15
noise3   asl a
         asl a
         asl a
         asl a
         sta 54294
nosound2 rts

windoff  lda #0
         sta windx
         sta windy
         rts

slowboff lda #8
         sta bforce
         rts

invisoff lda #255
         sta 53276
         lda csave
         sta 53287
         rts

inconoff lda #0
         sta joymask
         rts

eoff     lda count
         beq nosound2
         dec count
         bne nosound2
         jsr delline
         jmp (eofflink)

eon      lda count
         ora effcount
         bne nosound2
         lda ieffcount
         sta effcount
         lda #30
         sta sound2
         lda 56324
         and #6
         tax
         lda eofflinks,x
         sta eofflink
         lda eofflinks+1,x
         sta eofflink+1
         lda eonlinks,x
         sta eonlink
         lda eonlinks+1,x
         sta eonlink+1
         lda etlinks,x
         tay
         lda etlinks+1,x
         ldx #0
         jsr showline
         lda 56324
         asl a
         ora #1
         sta count
         jmp (eonlink)

windon   lda 54299
         and #3
         tax
         lda dirx,x
         sta windx
         lda diry,x
         sta windy
         rts

slowbon  lda #1
         sta bforce
         rts

invison  lda #254
         sta 53276
         lda 53287
         sta csave
         lda #0
         sta 53287
         rts

inconon  lda 54299
         ora 54299
         sta joymask
         rts

showline sty ad
         sta ad+1
         stx linecount
         ldy #0
sl0      lda (ad),y
         beq dl0
         sta 1984,y
         iny
         cpy #40
         bcc sl0
         rts

delline  lda #0
         sta linecount
         ldy #0
dl0      lda #32
dl1      sta 1984,y
         iny
         cpy #40
         bcc dl1
         rts

         ; (C) Raah 1991/1993
