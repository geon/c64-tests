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

start
	+beforeTests

	+beginTest "add16 low bits"
	+ldaxImmediate $0001
	+stax $02
	+ldaxImmediate $0002
	+stax $04
	+add16 $02, $04
	+endTest $02, $0003

	+beginTest "add16 high bits"
	+ldaxImmediate $0100
	+stax $02
	+ldaxImmediate $0200
	+stax $04
	+add16 $02, $04
	+endTest $02, $0300

	+beginTest "add16 overflow low bits"
	+ldaxImmediate $00ff
	+stax $02
	+ldaxImmediate $0001
	+stax $04
	+add16 $02, $04
	+endTest $02, $0100

	+beginTest "add16 overflow high bits"
	+ldaxImmediate $ff00
	+stax $02
	+ldaxImmediate $0100
	+stax $04
	+add16 $02, $04
	+endTest $02, $0000

	+afterTests
