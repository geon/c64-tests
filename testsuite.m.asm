#import "zpallocator.asm"


// TODO: Move out of zero page.
// Needed between beginTest and afterTests, hence not deallocated.
.var _fb = allocateSpecificZpWord($fb)
.var _06 = allocateZpWord()
.var _08 = allocateZpWord()


.macro beforeTests () {
	// Set screen mode to lower/upper case.
	lda #23
	sta 53272

	// Clear screen.
	jsr $e544

	printLine("Running tests:")
	printLine("----------------------------------------")
}


.macro beginTest (messageString) {
	jmp !+
message:
	.encoding "petscii_mixed"
	.text messageString
	.byte 13, 0
!:
	lda #<message
	ldx #>message
	stax(_fb)
}


.macro endTest (result, okValue) {
	ldaxImmediate(okValue)
	stax(_08)
	ldax(result)
	stax(_06)

	cmp16(_08, _06)
	bne(@error)
	printPointer(_fb)
}


.macro endTest8 (result, okValue) {
	lda #okValue
	ldx #$00
	stax(_08)
	lda result
	ldx #$00
	stax(_06)

	cmp #okValue
	bne(@error)

	printPointer(_fb)
}


.macro endTestFlagZClear () {
	// Set $02 to content of z flag (0/1).
	bne then // bne: branch on z = 0
	jmp else
then:
	// z = 0
	lda #0
	.var _02 = allocateZpByte()
	sta _02
	jmp endif
else:
	// z = 1
	lda #1
	sta _02
endif:

	endTest8(_02, $00)

	.eval deallocateZpByte(_02)
}


.macro endTestFlagZSet () {
	// Set $02 to content of z flag (0/1).
	bne then // bne: branch on z = 0
	jmp else
then:
	// z = 0
	lda #0
	.var _02 = allocateZpByte()
	sta _02
	jmp endif
else:
	// z = 1
	lda #1
	sta _02
endif:

	endTest8(_02, $01)

	.eval deallocateZpByte(_02)
}


.macro endTestFlagNClear () {
	// Set $02 to content of n flag (0/1).
	bmi then // bmi: branch on n = 1
	jmp else
then:
	// n = 1
	lda #1
	.var _02 = allocateZpByte()
	sta _02
	jmp endif
else:
	// n = 0
	lda #0
	sta _02
endif:

	endTest8(_02, $00)

	.eval deallocateZpByte(_02)
}


.macro endTestFlagNSet () {
	// Set $02 to content of n flag (0/1).
	bmi then // bmi: branch on n = 1
	jmp else
then:
	// n = 1
	lda #1
	.var _02 = allocateZpByte()
	sta _02
	jmp endif
else:
	// n = 0
	lda #0
	sta _02
endif:

	endTest8(_02, $01)

	.eval deallocateZpByte(_02)
}


.macro afterTests () {
	// Display test result.
	printLine("----------------------------------------")
	printLine("All tests passed.")
	// Color for success.
	lda #GREEN
	jmp end
@error:
	printLine("****************************************")
	printLine("Test failed:")
	printPointer(_fb)

	printLine("Expected:")
	lda _08+1
	jsr PRBYTE
	lda _08
	jsr PRBYTE
	printLine("")
	printLine("Actual:")
	lda _06+1
	jsr PRBYTE
	lda _06
	jsr PRBYTE
	printLine("")

	// Color for error.
	lda #RED
@end:
	// Show the color.
	sta $d020
	rts
}
