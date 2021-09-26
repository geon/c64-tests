#import "zpallocator.asm"


.macro circularBufferAllocate () {
	.byte $aa // end
	.fill $ff, $bb // values
}


.macro circularBufferSetEnd (buffer, value) {
	lda value
	sta buffer + 0
}


.macro circularBufferGetEnd (buffer, value) {
	lda buffer + 0
	sta value
}


.macro circularBufferGetLength (buffer, value) {
	circularBufferGetEnd(buffer, value)
}


.macro circularBufferInitialize (buffer) {
	// TODO: Replace with immediate value.
	lda #0
	.var zero = allocateZpByte()
	sta zero
	circularBufferSetEnd(buffer, zero)
	.eval deallocateZpByte(zero)
}


.macro circularBufferGetIterator (buffer, address) {
	ldaxImmediate(buffer + 1)
	stax(address)
}


.macro circularBufferGetIteratorNext(buffer, iterator, return){
	// Read the value to return.
	ldy #0
	lda (iterator), y
	sta return

	// Find end pointer. (One step past the last element.)
	.var _10 = allocateZpWord()
	circularBufferGetIterator(buffer, _10)
	.var _04 = allocateZpByte()
	circularBufferGetLength(buffer, _04)
	add16_8(_10, _04)

	// Advance iterator.
	lda #1
	.var _06 = allocateZpByte()
	sta _06
	add16_8(iterator, _06)

	cmp16(iterator, _10)
	bmi !+
	// Out of range, so return null pointer.
	ldaxImmediate($0000)
	stax(iterator)
!:

	.eval deallocateZpWord(_10)
	.eval deallocateZpByte(_04)
	.eval deallocateZpByte(_06)
}


.macro circularBufferPush (buffer, value) {
	// Save the value.
	.var _02 = allocateZpWord()
	circularBufferGetIterator(buffer, _02)
	.var _06 = allocateZpByte()
	circularBufferGetLength(buffer, _06)
	add16_8(_02, _06)
	lda value
	ldy #0
	sta (_02), y

	// Increment lenght
	circularBufferGetEnd(buffer, _02)
	inc _02
	circularBufferSetEnd(buffer, _02)

	.eval deallocateZpWord(_02)
	.eval deallocateZpByte(_06)
}

.macro circularBufferPop (buffer, return) {
	// Save the value.
	.var _02 = allocateZpWord()
	circularBufferGetIterator(buffer,  _02)
	ldy #0
	lda (_02), y
	sta return

	.eval deallocateZpWord(_02)
}
