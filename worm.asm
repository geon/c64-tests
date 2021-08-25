!macro wormAllocate {
	!byte $aa ; length
	!word $bbcc ; pos, index into screen array
	!byte $dd ; direction
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


!macro wormSetPosition .worm, .pos {
	+ldax .pos
	+stax .worm + 1
}


!macro wormGetPosition .worm, .pos {
	+ldax .worm + 1
	+stax .pos
}


!macro wormSetDirection .worm, .direction {
	lda .direction
	sta .worm + 3
}


!macro wormGetDirection .worm, .direction {
	lda .worm + 3
	sta .direction
}


!macro wormMoveForward .worm {
	jmp +
	; offsets +x, +y, -x, -y
.table	!word 1, 40, -1, -40
+
	+wormGetDirection .worm, $02
	rol $02 ; Multiply by 2, because words, not bytes.
	ldx $02
	lda .table, x
	sta $02
	lda .table+1, x
	sta $03

	+wormGetPosition .worm, $04
	+add16 $04, $02
	+wormSetPosition .worm, $04
}


!macro wormGetTail .worm, .length {
	+wormGetLength .worm, .length
}
