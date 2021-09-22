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


.byte $dd
.macro circularBufferInitialize (buffer) {
	lda #0
	sta $02
	circularBufferSetEnd(buffer, $02)
}


.macro circularBufferGetIterator (buffer, address) {
	ldaxImmediate(buffer + 1)
	stax(address)
}

circularBufferGetIteratorNext_iterator:
	.word $00
circularBufferGetIteratorNext_return:
	.byte $00
.macro circularBufferGetIteratorNext(buffer, iterator, return){
	// Transfer args to variables at once.
	ldax(iterator)
	stax(circularBufferGetIteratorNext_iterator)
	ldax(return)
	stax(circularBufferGetIteratorNext_return)

	// Read the value to return.
	ldy #0
	lda (circularBufferGetIteratorNext_iterator), y
	sta circularBufferGetIteratorNext_return

	// Find end pointer. (One step past the last element.)
	circularBufferGetIterator(buffer, $10)
	circularBufferGetLength(buffer, $04)
	add16_8($10, $04)

	// Advance iterator.
	lda #1
	sta $06
	add16_8(circularBufferGetIteratorNext_iterator, $06)

	cmp16(circularBufferGetIteratorNext_iterator, $10)
	bmi !+
	// Out of range, so return null pointer.
	ldaxImmediate($0000)
	stax(circularBufferGetIteratorNext_iterator)
!:
}


.macro circularBufferPush (buffer, value) {
	// Save the value.
	circularBufferGetIterator(buffer, $02)
	circularBufferGetLength(buffer, $06)
	add16_8( $02, $06)
	lda value
	ldy #0
	sta ($02), y

	// Increment lenght
	circularBufferGetEnd(buffer, $02)
	inc $02
	circularBufferSetEnd(buffer, $02)
}

.macro circularBufferPop (buffer, return) {
	// Save the value.
	circularBufferGetIterator( buffer,  $02)
	ldy #0//
	lda ($02), y
	sta return
}
