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

; Directly after the basic code.
*=$080e

!macro add16Test a, b, wanted, title {
	+beginTest title
	+ldaxImmediate a
	+stax $02
	+ldaxImmediate b
	+stax $04
	+add16 $02, $04
	+endTest $02, wanted
}

start
	+beforeTests

	+add16Test $0001, $0002, $0003, "add16 low bits"
	+add16Test $0100, $0200, $0300, "add16 high bits"
	+add16Test $00ff, $0001, $0100, "add16 overflow low bits"
	+add16Test $ff00, $0100, $0000, "add16 overflow high bits"

	+afterTests
