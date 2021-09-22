// load A and X
.macro ldaxImmediate (target) {
	lda #<target
	ldx #>target
}


// load A and X
.macro ldax (target) {
	lda target
	ldx target + 1
}


// store A and X
.macro stax (target) {
	sta target
	stx target + 1
}


.macro beq (t) {
	bne !+
	jmp t
!:
}


.macro bne (t) {
	beq !+
	jmp t
!:
}


.macro printPointer (string) {
	ldy #0
!:
	lda (string),y
	beq !+
	jsr $ffd2
	iny
	jmp !-
!:
}


.macro printLine (string) {
	jmp !+
message:
	.encoding "petscii_mixed"
	.text string
	.byte 13, 0
!:
	ldy #0
!:
	lda message,y
	beq !+
	jsr $ffd2
	iny
	jmp !-
!:
}


.macro add16 (a, b) {
	clc

	lda a
	adc b
	sta a

	lda a+1
	adc b+1
	sta a+1
}


.macro add16_8 (a, b) {
	clc

	lda a
	adc b
	sta a

	lda a+1
	adc #0
	sta a+1
}


.macro multiply8 (a, b) {
	lda #0 // Clear accumulator.
	ldx b // Loop b times.
	clc
!:
	dex
	bmi !+
	adc a
	jmp !-
!:
	sta a
}


// https://codebase64.org/doku.php?id=base:16-bit_comparison
// Does exactly the same as CMP of two values (effectively its a A - M) and sets the flags as follows:
// If A = M : Carry =  SET   Zero =  SET   Negative = CLEAR
// If A > M : Carry =  SET   Zero = CLEAR  Negative = CLEAR
// If A < M : Carry = CLEAR  Zero = CLEAR  Negative =  SET
.macro cmp16 (A, M) {
	// Compare low byte and push flags.
    lda A
    cmp M
    php
	// Compare high byte and push flags.
    lda A+1
    sbc M+1
    php
	// Pop the high byte flags to A and store as immediate value in the and-instruction below.
	// Use self modifying code to avoid poluting registers or the zero page.
    pla
    sta andInstruction+1
	// Pop the low byte flags to A.
    pla
	// Bit  magic.
	// Bit 1 is Z-flag.
    ora #%11111101
andInstruction:
	// This value was overwritten above.
    and #00
	// Push the result.
    pha
	// Pop manipulated bits to flags.
    plp
}
