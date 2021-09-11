!ifdef circular_buffer_asm !eof
circular_buffer_asm = 1

!macro circularBufferAllocate {
	!byte $aa ; end
	!fill $ff, $bb ; values
}


!macro circularBufferSetEnd .buffer, .value {
	lda .value;
	sta .buffer + 0
}


!macro circularBufferGetEnd .buffer, .value {
	lda .buffer + 0
	sta .value;
}


!macro circularBufferGetLength .buffer, .value {
	+circularBufferGetEnd .buffer, .value
}


!macro circularBufferInitialize .buffer {
	lda #0
	sta $02
	+circularBufferSetEnd .buffer, $02
}


!macro circularBufferGetIterator .buffer, .address {
	+ldaxImmediate .buffer + 1
	+stax .address
}


!macro circularBufferGetIteratorNext .buffer, .iterator {
	; Find end pointer. (One step past the last element.)
	+circularBufferGetIterator .buffer, $10
	+circularBufferGetLength .buffer, $04
	+add16_8 $10, $04

	; Advance iterator.
	lda #1
	sta $06
	+add16_8 .iterator, $06

	+cmp16 .iterator, $10
	bmi +
	; Out of range, so return null pointer.
	+ldaxImmediate $0000
	+stax .iterator
+
}


!macro circularBufferPush .buffer, .value {
	; Save the value.
	+circularBufferGetIterator .buffer,  $02
	+circularBufferGetLength .buffer, $06
	+add16_8 $02, $06
	lda .value
	ldy #0;
	sta ($02), y

	; Increment lenght
	+circularBufferGetEnd .buffer, $02
	inc $02
	+circularBufferSetEnd .buffer, $02
}

!macro circularBufferPop .buffer, .return {
	; Save the value.
	+circularBufferGetIterator .buffer,  $02
	ldy #0;
	lda ($02), y
	sta .return
}
