#import "zpallocator.asm"


.macro wormAllocate () {
	.byte $aa // length
	.word $bbcc // pos, index into screen array
	.byte $dd // direction
	.byte $ff // wantedLength
}


.macro wormInitialize (worm) {
	lda #0
	.var zero = allocateZpByte()
	sta zero
	wormSetLength(worm, zero)
	wormSetWantedLength(worm, zero)
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
	.var direction = allocateZpWord()
	wormGetDirection(worm, direction)

	// TODO: Add macro to convert direction to direction.
	rol direction // Multiply by 2, because words, not bytes.
	ldx direction
	.eval deallocateZpWord(direction)
	lda table, x
	.var offset = allocateZpWord()
	sta offset
	lda table+1, x
	sta offset+1

	// Move the head.
	.var position = allocateZpWord()
	wormGetPosition(worm, position)
	add16(position, offset)
	wormSetPosition(worm, position)
	.eval deallocateZpWord(position)

	// Grow if too short.
	.var length = allocateZpByte()
	wormGetLength(worm, length)
	.var wantedLength = allocateZpByte()
	wormGetWantedLength(worm, wantedLength)
	lda length
	cmp wantedLength
	bpl !+
	inc length
	wormSetLength(worm, length)
!:
	.eval deallocateZpByte(length)

	.eval deallocateZpWord(offset)
	.eval deallocateZpByte(wantedLength)
}


.macro wormGetTail (worm, length) {
	wormGetLength(worm, length)
}


.macro wormGrowTail (worm) {
	.var wantedLength = allocateZpByte()
	wormGetWantedLength(worm, wantedLength)
	inc wantedLength
	wormSetWantedLength(worm, wantedLength)
	.eval deallocateZpByte(wantedLength)
}
