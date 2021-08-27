!macro circularBufferAllocate {
	!byte $aa ; end
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

!macro circularBufferPush .buffer, .value {
	; Increment lenght
	+circularBufferGetEnd .buffer, $02
	inc $02
	+circularBufferSetEnd .buffer, $02
}
