;!src <6502/std.a>
!src "macros.m.asm"

; Bootstrap
; Beginning of basic code area.
*=$0801
; 10 SYS 2062
; pointer to next line (2 byte, that last null pointer)
; line no. (hex, 2 byte)
; $9e=sys https://sta.c64.org/cbm64basins2.html
; $20=space
; 2062 (4 byte, petscii, $080e in hex)
; null terminator of line
; null-pointer to next line (2 byte)
!byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$32,$00, $00, $00

	red = 2
	green = 5

; Directly after the basic code.
*=$080e
jmp start



!macro beginTest messageString {
	jmp +
.message !pet messageString,13,0
+
	lda #<.message
	ldx #>.message
	+stax $fb
}

!macro endTest okValue {
	cmp #okValue
	+bne error
	+printPointer $fb
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



start
	; Set screen mode to lower/upper case.
	lda #23
	sta 53272

	; Clear screen.
	jsr $e544

	+printLine "Running tests:"
	+printLine "----------------------------------------"

	+beginTest "This should pass."
	lda #0
	+endTest 0

	+beginTest "This as well."
	lda #123
	+endTest 123

	+beginTest "This should fail."
	lda #124
	+endTest 123




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
