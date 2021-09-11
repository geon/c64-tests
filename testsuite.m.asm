!ifdef testsuite_m_asm !eof
testsuite_m_asm = 1

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


!macro endTest .result, .okValue {
	+ldaxImmediate .okValue
	+stax $08
	+ldax .result
	+stax $06

	+cmp16 $08, $06
	+bne error
	+printPointer $fb
}


!macro endTest8 .result, .okValue {
	lda #.okValue
	ldx #$00
	+stax $08
	lda .result
	ldx #$00
	+stax $06

	cmp #.okValue
	+bne error

	+printPointer $fb
}


!macro endTestFlagZClear {
	; Set $02 to content of z flag (0/1).
	bne .then ; bne: branch on z = 0
	jmp .else
.then
	; z = 0
	lda #0
	sta $02
	jmp .endif
.else
	; z = 1
	lda #1
	sta $02
.endif

	+endTest8 $02, $00
}


!macro endTestFlagZSet {
	; Set $02 to content of z flag (0/1).
	bne .then ; bne: branch on z = 0
	jmp .else
.then
	; z = 0
	lda #0
	sta $02
	jmp .endif
.else
	; z = 1
	lda #1
	sta $02
.endif

	+endTest8 $02, $01
}


!macro endTestFlagNClear {
	; Set $02 to content of n flag (0/1).
	bmi .then ; bmi: branch on n = 1
	jmp .else
.then
	; n = 1
	lda #1
	sta $02
	jmp .endif
.else
	; n = 0
	lda #0
	sta $02
.endif

	+endTest8 $02, $00
}


!macro endTestFlagNSet {
	; Set $02 to content of n flag (0/1).
	bmi .then ; bmi: branch on n = 1
	jmp .else
.then
	; n = 1
	lda #1
	sta $02
	jmp .endif
.else
	; n = 0
	lda #0
	sta $02
.endif

	+endTest8 $02, $01
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

	+printLine "Expected:"
	lda $08+1
	jsr PRBYTE
	lda $08
	jsr PRBYTE
	+printLine ""
	+printLine "Actual:"
	lda $06+1
	jsr PRBYTE
	lda $06
	jsr PRBYTE
	+printLine ""

	; Color for error.
	lda #red
end
	; Show the color.
	sta $d020
	rts
}
