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
	.var end = allocateZpWord()
	circularBufferGetIterator(buffer, end)
	.var length = allocateZpByte()
	circularBufferGetLength(buffer, length)
	add16_8(end, length)

	// Advance iterator.
	// TODO: Replace with immediate value.
	lda #1
	.var one = allocateZpByte()
	sta one
	add16_8(iterator, one)

	cmp16(iterator, end)
	bmi !+
	// Out of range, so return null pointer.
	ldaxImmediate($0000)
	stax(iterator)
!:

	.eval deallocateZpWord(end)
	.eval deallocateZpByte(length)
	.eval deallocateZpByte(one)
}


.macro circularBufferPush (buffer, value) {
	// Save the value.
	.var elementPointer = allocateZpWord()
	circularBufferGetIterator(buffer, elementPointer)
	.var length = allocateZpByte()
	circularBufferGetLength(buffer, length)
	add16_8(elementPointer, length)
	// TODO: Replace with macro.
	lda value
	ldy #0
	sta (elementPointer), y

	// Increment lenght
	.var end = allocateZpWord()
	circularBufferGetEnd(buffer, end)
	inc end
	circularBufferSetEnd(buffer, end)
	.eval deallocateZpWord(end)

	.eval deallocateZpWord(elementPointer)
	.eval deallocateZpByte(length)
}

.macro circularBufferPop (buffer, return) {
	// Save the value.
	.var elementPointer = allocateZpWord()
	circularBufferGetIterator(buffer,  elementPointer)
	ldy #0
	lda (elementPointer), y
	sta return

	.eval deallocateZpWord(elementPointer)
}
