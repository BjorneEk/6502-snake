vidpage = $000a ; goes to 3fff

offset = $0000
dir = $0001
prevoff = $0002
yy = $0003
v1 = $2a13
v2 = $2a93
v3 = $2b13
v4 = $2b93
v5 = $2c13
selected = $0009

PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003
PCR = $600c
IFR = $600d
IER = $600f

start = $22

	.org $8000

reset:
	lda 0
	sta dir

	lda #1
	sta selected

	lda #0
	sta offset
	lda #%00011000
	sta DDRA

	ldx #$ff
	txs
	cli

	lda #$82
	sta IER
	lda #$00
	sta PCR

	lda #$20
	sta start + 1
	lda #$00
	sta start

	lda #$20
	sta vidpage + 1
	lda #$00
	sta vidpage

	ldx #$20
	ldy $0
	jsr page
	jmp loop

page:

	lda #%00000000

	sta (vidpage), y
	clc
	iny
	bne page
	inc vidpage + 1
	dex
	bne page
	rts


resetjmp:
	jmp reset
increment_x:
	jsr nooop
	lda offset
	cmp #$64
	bcc incx
	jmp setrect
incx:
	inc offset
	inc offset
	jmp setrect

decrement_x:
	jsr nooop
	lda offset
	cmp #$2
	bcc setrect
	dec offset
	dec offset
	jmp setrect

increment_y:
	lda start + 1
	cmp #$3f
	bcc incy
	jmp setrect
incy:
	inc start + 1
	jmp setrect

decrement_y:
	lda start + 1
	cmp #$20
	bcc setrect
	dec start + 1
	jmp setrect

loop:



	jsr nooop
	jsr nooop
	jsr nooop
	jsr nooop
	jsr nooop
	jsr nooop
	jsr nooop
	jsr nooop

	lda dir
	cmp #%00000001
	beq increment_x
	cmp #%00000010
	beq decrement_x
	cmp #%00000011
	beq increment_y
	cmp #%00000100
	beq decrement_y
	jmp loop
setrect:
	ldy offset
	lda (start), y
	cmp #%00001100
	beq resetjmp

	;jsr clearRect

	lda #%00001100

	ldy offset
	sta (start), y

	ldx #$80
	jsr inyx
	sta (start), y

	ldy offset
	ldx #$1
	jsr inyx
	sta (start), y

	ldy offset
	ldx #$81
	jsr inyx
	sta (start), y

	jmp loop

inyx:
	iny
	dex
	bne inyx
	rts

gameover:
	lda #$20
	sta vidpage + 1
	lda #$00
	sta vidpage

	ldx #$20
	ldy $0
	jsr page
	jmp inf
inf:
	jmp inf

nooop:
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	jsr noop
	rts
jmploop:
 jmp loop
noop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rts
up:
	lda dir
	cmp #%00000100
	beq jmploop
	lda #%00000011
	sta dir
	jmp jmploop
down:
	lda dir
	cmp #%00000011
	beq jmploop
	lda #%00000100
	sta dir
	jmp jmploop
left:
	lda dir
	cmp #%00000001
	beq jmploop
	lda #%00000010
	sta dir
	jmp jmploop
right:
	lda dir
	cmp #%00000010
	beq jmploop
	lda #%00000001
	sta dir
	jmp jmploop
nmi:
	lda #%00000000
	sta DDRA
	nop
	nop
	nop
	nop
	nop
	nop
evtcheck:
	lda PORTA
	cmp #%01000000
	beq right
	cmp #%10000000
	beq left
	cmp #%00100000
	beq up
	cmp #%00010000
	beq down
	jmp evtcheck
exit_nmi:
	rti
irq:
	jmp exit_irq
exit_irq:
	rti

	.org $fffa
	.word nmi
	.word reset
	.word irq
