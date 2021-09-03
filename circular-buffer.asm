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
	; Advance iterator.
	lda #1
	sta $06
	+add16_8 .iterator, $06
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
