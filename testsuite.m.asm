!macro beforeTests {
	; Set screen mode to lower/upper case.
	lda #23
	sta 53272

	; Clear screen.
	jsr $e544

	+printLine "Running tests:"
	+printLine "----------------------------------------"
}


!macro beginTest messageString {
	jmp +
.message !pet messageString,13,0
+
	lda #<.message
	ldx #>.message
	+stax $fb
}


!macro endTest result, okValue {
	lda result
	cmp #<okValue
	+bne error
	+printPointer $fb
}


	red = 2
	green = 5

!macro afterTests {
    ; Display test result.
	+printLine "----------------------------------------"
	+printLine "All tests passed."
	; Color for success.
	lda #green
	jmp end
error
	+printLine "****************************************"
	+printLine "Test failed:"
	+printPointer $fb
	; Color for error.
	lda #red
end
	; Show the color.
	sta $d020
	rts
}
