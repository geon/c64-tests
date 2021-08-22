; load A and X
!macro ldaxImmediate .target {
	lda #<.target
	ldx #>.target
}


; load A and X
!macro ldax .target {
	lda .target
	ldx .target + 1
}


; store A and X
!macro stax .target {
	sta .target
	stx .target + 1
}


!macro beq @t {
	bne +
	jmp @t
+
}


!macro bne @t {
	beq +
	jmp @t
+
}


!macro printPointer string {
	ldy #0
-
	lda (string),y
	beq +
	jsr $ffd2
	iny
	jmp -
+
}


!macro printLine string {
	jmp +
.message !pet string,13,0
+
	ldy #0
-
	lda .message,y
	beq +
	jsr $ffd2
	iny
	jmp -
+
}


!macro add16 .a, .b {
	clc

	lda .a
	adc .b
	sta .a

	lda .a+1
	adc .b+1
	sta .a+1
}


!macro add16_8 .a, .b {
	clc

	lda .a
	adc .b
	sta .a

	lda .a+1
	adc #0
	sta .a+1
}


!macro multiply8 .a, .b {
	lda #0 ; Clear accumulator.
	ldx .b ; Loop .b times.
	clc
-
	dex
	bmi +
	adc .a
	jmp -
+
	sta .a
}
