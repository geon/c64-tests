!macro wormAllocate {
	!byte $aa ; length
	!byte $bb ; xpos
	!byte $cc ; ypos
}


!macro wormInitialize .worm {
	lda #0
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


!macro wormSetPosition .worm, .x, .y {
	ldx .x
	ldy .y
	stx .worm + 1
	sty .worm + 2
}


!macro wormGetPosition .worm, .x, .y {
	ldx .worm + 1
	ldy .worm + 2
	stx .x
	sty .y
}
