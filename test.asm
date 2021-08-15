;!src <6502/std.a>
!src "macros.m.asm"
!src "testsuite.m.asm"

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







start
	+beforeTests

	+beginTest "This should pass."
	lda #0
	+endTest 0

	+beginTest "This as well."
	lda #123
	+endTest 123

	+beginTest "This should fail."
	lda #124
	+endTest 123

	+afterTests
