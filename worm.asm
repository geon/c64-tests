#import "zpallocator.asm"


.macro wormAllocate () {
	.byte $aa // length
	.word $bbcc // pos, index into screen array
	.byte $dd // direction
	.byte $ff // wantedLength
}


.macro wormInitialize (worm) {
	lda #0
	.var _02 = allocateZpByte()
	sta _02
	wormSetLength(worm, _02)
	wormSetWantedLength(worm, _02)
}


.macro wormSetLength (worm, value) {
	lda value
	sta worm + 0
}


.macro wormGetLength (worm, value) {
	lda worm + 0
	sta value
}


.macro wormSetWantedLength (worm, value) {
	lda value
	sta worm + 4
}


.macro wormGetWantedLength (worm, value) {
	lda worm + 4
	sta value
}


.macro wormSetPosition (worm, pos) {
	ldax(pos)
	stax(worm + 1)
}


.macro wormGetPosition (worm, pos) {
	ldax(worm + 1)
	stax(pos)
}


.macro wormSetDirection (worm, direction) {
	lda direction
	sta worm + 3
}


.macro wormGetDirection (worm, direction) {
	lda worm + 3
	sta direction
}


.macro wormMoveForward (worm) {
	jmp !+
	// offsets +x, +y, -x, -y
table: .word 1, 40, -1, -40
!:
	// Find the offset in the table, by the direction.
	.var _02 = allocateZpWord()
	wormGetDirection(worm, _02)
	rol _02 // Multiply by 2, because words, not bytes.
	ldx _02
	lda table, x
	sta _02
	lda table+1, x
	sta _02+1

	// Move the head.
	.var _04 = allocateZpWord()
	wormGetPosition(worm, _04)
	add16(_04, _02)
	wormSetPosition(worm, _04)

	// Grow if too short.
	wormGetLength(worm, _02)
	wormGetWantedLength(worm, _04)
	lda _02
	cmp _04
	bpl !+
	inc _02
	wormSetLength(worm, _02)
!:

	.eval deallocateZpWord(_02)
	.eval deallocateZpWord(_04)
}


.macro wormGetTail (worm, length) {
	wormGetLength(worm, length)
}


.macro wormGrowTail (worm) {
	.var _02 = allocateZpByte()
	wormGetWantedLength(worm, _02)
	inc _02
	wormSetWantedLength(worm, _02)
	.eval deallocateZpByte(_02)
}
