#import "zpallocator.asm"


// TODO: Move out of zero page.
// Needed between beginTest and afterTests, hence not deallocated.
.var lastMessageStringPointer = allocateSpecificZpWord($fb)
.var lastResult = allocateZpWord()
.var lastOkValue = allocateZpWord()


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
	stax(lastMessageStringPointer)
}


.macro endTest (result, okValue) {
	ldaxImmediate(okValue)
	stax(lastOkValue)
	ldax(result)
	stax(lastResult)

	cmp16(lastOkValue, lastResult)
	bne(@error)
	printPointer(lastMessageStringPointer)
}


.macro endTest8 (result, okValue) {
	lda #okValue
	ldx #$00
	stax(lastOkValue)
	lda result
	ldx #$00
	stax(lastResult)

	cmp #okValue
	bne(@error)

	printPointer(lastMessageStringPointer)
}


.macro endTestFlagZClear () {
	.var zFlag = allocateZpByte()

	// TODO: Replace with getting the flags (push flags, pop to a, and with bit pattern).
	// Set $02 to content of z flag (0/1).
	bne then // bne: branch on z = 0
	jmp else
then:
	// z = 0
	lda #0
	sta zFlag
	jmp endif
else:
	// z = 1
	lda #1
	sta zFlag
endif:

	endTest8(zFlag, $00)

	.eval deallocateZpByte(zFlag)
}


.macro endTestFlagZSet () {
	.var zFlag = allocateZpByte()

	// Set $02 to content of z flag (0/1).
	bne then // bne: branch on z = 0
	jmp else
then:
	// z = 0
	lda #0
	sta zFlag
	jmp endif
else:
	// z = 1
	lda #1
	sta zFlag
endif:

	endTest8(zFlag, $01)

	.eval deallocateZpByte(zFlag)
}


.macro endTestFlagNClear () {
	.var nFlag = allocateZpByte()

	// Set $02 to content of n flag (0/1).
	bmi then // bmi: branch on n = 1
	jmp else
then:
	// n = 1
	lda #1
	sta nFlag
	jmp endif
else:
	// n = 0
	lda #0
	sta nFlag
endif:

	endTest8(nFlag, $00)

	.eval deallocateZpByte(nFlag)
}


.macro endTestFlagNSet () {
	.var nFlag = allocateZpByte()

	// Set $02 to content of n flag (0/1).
	bmi then // bmi: branch on n = 1
	jmp else
then:
	// n = 1
	lda #1
	sta nFlag
	jmp endif
else:
	// n = 0
	lda #0
	sta nFlag
endif:

	endTest8(nFlag, $01)

	.eval deallocateZpByte(nFlag)
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
	printPointer(lastMessageStringPointer)

	printLine("Expected:")
	lda lastOkValue+1
	jsr PRBYTE
	lda lastOkValue
	jsr PRBYTE
	printLine("")
	printLine("Actual:")
	lda lastResult+1
	jsr PRBYTE
	lda lastResult
	jsr PRBYTE
	printLine("")

	// Color for error.
	lda #RED
@end:
	// Show the color.
	sta $d020
	rts
}
