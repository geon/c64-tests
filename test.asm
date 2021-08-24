;!src <6502/std.a>
!src "macros.m.asm"
!src "testsuite.m.asm"
!src "worm.asm"

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

!macro add16_8Test a, b, wanted, title {
	+beginTest title
	+ldaxImmediate a
	+stax $02
	lda #b
	sta $04
	+add16_8 $02, $04
	+endTest $02, wanted
}

!macro multiply8Test a, b, wanted, title {
	+beginTest title
	lda #a
	sta $02
	lda #b
	sta $04
	+multiply8 $02, $04
	+endTest $02, wanted
}

start
	+beforeTests

	+add16Test $0001, $0002, $0003, "add16 low bits"
	+add16Test $0100, $0200, $0300, "add16 high bits"
	+add16Test $00ff, $0001, $0100, "add16 overflow low bits"
	+add16Test $ff00, $0100, $0000, "add16 overflow high bits"

	+add16_8Test $0001, $02, $0003, "add16_8 low bits"
	+add16_8Test $00ff, $01, $0100, "add16_8 overflow low bits"
	+add16_8Test $ffff, $01, $0000, "add16_8 overflow high bits"

	+multiply8Test $00, $00, $00, "multiply8 both zero"
	+multiply8Test $01, $01, $01, "multiply8 both one"
	+multiply8Test $05, $01, $05, "multiply8 right one"
	+multiply8Test $01, $00, $00, "multiply8 right zero"
	+multiply8Test $01, $05, $05, "multiply8 left one"
	+multiply8Test $00, $01, $00, "multiply8 left zero"
	+multiply8Test $10, $10, $00, "multiply8 overflow"
	+multiply8Test 5, 5, 25, "multiply8 square"

	; Worm tests.
	; Allocate worm for tests.
	jmp +
.worm
	+wormAllocate ; Allocate som bytes here
+

	+beginTest "Initialize worm. Length should be 0."
	+wormInitialize .worm
	+wormGetLength .worm, $02
	+endTest $02, 0

	+beginTest "Increment length. Length should be 1."
	+wormIncrementLength .worm
	+wormGetLength .worm, $02
	+endTest $02, 1

	+beginTest "Set position."
	+ldaxImmediate $0100
	+stax $02
	+wormSetPosition .worm, $02
	+wormGetPosition .worm, $02
	+endTest $02, $0100

	+beginTest "Set direction. (down)"
	lda #$01
	sta $02
	lda #$00
	sta $03
	+wormSetDirection .worm, $02
	+wormGetDirection .worm, $02
	+endTest $02, $01

	+beginTest "Move forward."
	+wormMoveForward .worm
	+wormGetPosition .worm, $02
	+endTest $02, $0128

	+afterTests


!src "wozPrintHex.asm"
