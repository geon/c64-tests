;!src <6502/std.a>
!src "macros.m.asm"
!src "testsuite.m.asm"
!src "worm.asm"
!src "circular-buffer.asm"

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
	+endTest8 $02, wanted
}

start
	+beforeTests

	+beginTest "cmp $11, $22 endTestFlagZClear"
	lda #$11
	sta $02
	lda #$22
	sta $04
	lda $02
	cmp $04
	+endTestFlagZClear

	+beginTest "cmp $22, $11 endTestFlagZClear"
	lda #$22
	sta $02
	lda #$11
	sta $04
	lda $02
	cmp $04
	+endTestFlagZClear

	+beginTest "cmp $aa, $aa endTestFlagZSet"
	lda #$aa
	sta $02
	lda #$aa
	sta $04
	lda $02
	cmp $04
	+endTestFlagZSet

	+beginTest "cmp $11, $22 endTestFlagNSet"
	lda #$11
	sta $02
	lda #$22
	sta $04
	lda $02
	cmp $04
	+endTestFlagNSet

	+beginTest "cmp $22, $11 endTestFlagNClear"
	lda #$22
	sta $02
	lda #$11
	sta $04
	lda $02
	cmp $04
	+endTestFlagNClear

	+beginTest "cmp $aa, $aa endTestFlagNClear"
	lda #$aa
	sta $02
	lda #$aa
	sta $04
	lda $02
	cmp $04
	+endTestFlagNClear

	+beginTest "+cmp16 $1111, $2222 endTestFlagZClear"
	+ldaxImmediate $1111
	+stax $02
	+ldaxImmediate $2222
	+stax $04
	+cmp16 $02, $04
	+endTestFlagZClear

	+beginTest "+cmp16 $2222, $1111 endTestFlagZClear"
	+ldaxImmediate $2222
	+stax $02
	+ldaxImmediate $1111
	+stax $04
	+cmp16 $02, $04
	+endTestFlagZClear

	+beginTest "+cmp16 $aaaa, $aaaa endTestFlagZSet"
	+ldaxImmediate $aaaa
	+stax $02
	+ldaxImmediate $aaaa
	+stax $04
	+cmp16 $02, $04
	+endTestFlagZSet

	+beginTest "+cmp16 $1111, $2222 endTestFlagNSet"
	+ldaxImmediate $1111
	+stax $02
	+ldaxImmediate $2222
	+stax $04
	+cmp16 $02, $04
	+endTestFlagNSet

	+beginTest "+cmp16 $2222, $1111 endTestFlagNClear"
	+ldaxImmediate $2222
	+stax $02
	+ldaxImmediate $1111
	+stax $04
	+cmp16 $02, $04
	+endTestFlagNClear

	+beginTest "+cmp16 $aaaa, $aaaa endTestFlagNClear"
	+ldaxImmediate $aaaa
	+stax $02
	+ldaxImmediate $aaaa
	+stax $04
	+cmp16 $02, $04
	+endTestFlagNClear

	+beginTest "+cmp16 $0000, $00ff endTestFlagNSet"
	+ldaxImmediate $0000
	+stax $02
	+ldaxImmediate $00ff
	+stax $04
	+cmp16 $02, $04
	+endTestFlagNSet

	+beginTest "+cmp16 $00ff, $0000 endTestFlagNClear"
	+ldaxImmediate $00ff
	+stax $02
	+ldaxImmediate $0000
	+stax $04
	+cmp16 $02, $04
	+endTestFlagNClear

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

	+beginTest "Move right."
	lda #$00
	sta $02
	+wormSetDirection .worm, $02
	+wormMoveForward .worm
	+wormGetPosition .worm, $02
	+endTest $02, $0129

	+beginTest "Move up."
	lda #$03
	sta $02
	+wormSetDirection .worm, $02
	+wormMoveForward .worm
	+wormGetPosition .worm, $02
	+endTest $02, $0101

	+beginTest "Tail should be length 0."
	+wormGetTail .worm, $02
	+endTest8 $02, 0

	+beginTest "Grow tail. Tail should still be length 0."
	+wormGrowTail .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 0

	+beginTest "After move. Tail should be length 1."
	+wormMoveForward .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 1

	+beginTest "Move more. Tail should stay 1."
	+wormMoveForward .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 1

	+beginTest "Grow tail twice. Tail should stay 1."
	+wormGrowTail .worm
	+wormGrowTail .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 1

	+beginTest "Move 1. Tail should be 2."
	+wormMoveForward .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 2

	+beginTest "Move 2. Tail should be 3."
	+wormMoveForward .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 3

	+beginTest "Move more. Tail should stay 3."
	+wormMoveForward .worm
	+wormGetTail .worm, $02
	+endTest8 $02, 3

	; CircularBuffer tests.
	; Allocate and initialize circular buffer for tests.
	jmp +
.circularBuffer
	+circularBufferAllocate
+
	+circularBufferInitialize .circularBuffer

	+beginTest "Push should grow buffer."
	lda #$12
	sta $04
	+circularBufferPush .circularBuffer, $04
	+circularBufferGetLength .circularBuffer, $02
	+endTest8 $02, 1

	+beginTest "The value should be in the buffer."
	+circularBufferGetIterator .circularBuffer, $30
	ldy #0
	lda ($30), y
	sta $40
	+endTest8 $40, $12

	+beginTest "Push second value."
	lda #$34
	sta $04
	+circularBufferPush .circularBuffer, $04
	+circularBufferGetIterator .circularBuffer, $02
	+circularBufferGetIteratorNext .circularBuffer, $02, $08
	+circularBufferGetIteratorNext .circularBuffer, $02, $08
	+endTest8 $08, $34

	+beginTest "Iterator should be null terminated."
	+circularBufferGetIterator .circularBuffer, $02
	+circularBufferGetIteratorNext .circularBuffer, $02, $08
	+circularBufferGetIteratorNext .circularBuffer, $02, $08
	+endTest $02, $0000

	+beginTest "Pop first value."
	+circularBufferPop .circularBuffer, $02
	+endTest8 $02, $12

	+afterTests


!src "wozPrintHex.asm"
