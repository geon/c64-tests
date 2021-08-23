!macro wormAllocate {
	!fill 1 ; Allocate some bytes.
}


!macro wormInitialize .worm {
	lda #0;
	sta $02
	+wormSetLength .worm, $02
}


!macro wormSetLength .worm, .value {
	lda .value;
	sta .worm + 0
}


!macro wormGetLength .worm, .value {
	lda .worm + 0
	sta .value
}

!macro wormIncrementLength .worm {
	+wormGetLength .worm, $02
	inc $02
	+wormSetLength .worm, $02
}
