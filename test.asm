#import "bootstrap.asm"
jmp start

#import "macros.m.asm"
#import "testsuite.m.asm"
#import "worm.asm"
#import "circular-buffer.asm"
#import "wozPrintHex.asm"
#import "zpallocator.asm"

.eval zpAllocatorInit(List().add(hardwiredPortRegisters))


.macro add16Test (a, b, wanted, title) {
	beginTest(title)

	// TODO: Just pass the immediate value, instead of using a temp ZP variable.
	ldaxImmediate(a)
	.var _02 = allocateZpWord()
	stax(_02)

	ldaxImmediate(b)
	.var _04 = allocateZpWord()
	stax(_04)

	add16(_02, _04)

	endTest(_02, wanted)

	.eval deallocateZpWord(_02)
	.eval deallocateZpWord(_04)
}

.macro add16_8Test (a, b, wanted, title) {
	beginTest(title)

	ldaxImmediate(a)
	.var _02 = allocateZpWord()
	stax(_02)

	lda #b
	.var _04 = allocateZpByte()
	sta _04
	add16_8(_02, _04)

	endTest(_02, wanted)

	.eval deallocateZpWord(_02)
	.eval deallocateZpByte(_04)
}

.macro multiply8Test (a, b, wanted, title) {
	beginTest(title)

	lda #a
	.var _02 = allocateZpByte()
	sta _02
	lda #b
	.var _04 = allocateZpByte()
	sta _04
	multiply8(_02, _04)
	endTest8(_02, wanted)

	.eval deallocateZpByte(_02)
	.eval deallocateZpByte(_04)
}

.macro cmpTest (a, b, title) {
	beginTest(title)

	lda #a
	.var _02 = allocateZpByte()
	sta _02

	lda #b
	.var _04 = allocateZpByte()
	sta _04

	lda _02
	cmp _04

	.eval deallocateZpByte(_02)
	.eval deallocateZpByte(_04)
}

.macro cmpTestFlagZClear (a, b, title) {
	cmpTest(a, b, title)
	endTestFlagZClear()
}

.macro cmpTestFlagZSet (a, b, title) {
	cmpTest(a, b, title)
	endTestFlagZSet()
}

.macro cmpTestFlagNClear (a, b, title) {
	cmpTest(a, b, title)
	endTestFlagNClear()
}

.macro cmpTestFlagNSet (a, b, title) {
	cmpTest(a, b, title)
	endTestFlagNSet()
}

.macro cmp16Test (a, b, title) {
	beginTest(title)

	ldaxImmediate(a)
	.var _02 = allocateZpWord()
	stax(_02)

	ldaxImmediate(b)
	.var _04 = allocateZpWord()
	stax(_04)

	cmp16(_02, _04)

	.eval deallocateZpWord(_02)
	.eval deallocateZpWord(_04)
}

.macro cmp16TestFlagZClear (a, b, title) {
	cmp16Test(a, b, title)
	endTestFlagZClear()
}

.macro cmp16TestFlagZSet (a, b, title) {
	cmp16Test(a, b, title)
	endTestFlagZSet()
}

.macro cmp16TestFlagNClear (a, b, title) {
	cmp16Test(a, b, title)
	endTestFlagNClear()
}

.macro cmp16TestFlagNSet (a, b, title) {
	cmp16Test(a, b, title)
	endTestFlagNSet()
}

start:
	beforeTests()

	cmpTestFlagZClear($11, $22, "cmp $11, $22 endTestFlagZClear")
	cmpTestFlagZClear($22, $11, "cmp $22, $11 endTestFlagZClear")
	cmpTestFlagZSet($aa, $aa, "cmp $aa, $aa endTestFlagZSet")
	cmpTestFlagNSet($11, $22, "cmp $11, $22 endTestFlagNSet")
	cmpTestFlagNClear($22, $11, "cmp $22, $11 endTestFlagNClear")
	cmpTestFlagNClear($aa, $aa, "cmp $aa, $aa endTestFlagNClear")

	cmp16TestFlagZClear($1111, $2222, "cmp16 $1111, $2222 endTestFlagZClear")
	cmp16TestFlagZClear($2222, $1111, "cmp16 $2222, $1111 endTestFlagZClear")
	cmp16TestFlagZSet($aaaa, $aaaa, "cmp16 $aaaa, $aaaa endTestFlagZSet")
	cmp16TestFlagNSet($1111, $2222, "cmp16 $1111, $2222 endTestFlagNSet")
	cmp16TestFlagNClear($2222, $1111, "cmp16 $2222, $1111 endTestFlagNClear")
	cmp16TestFlagNClear($aaaa, $aaaa, "cmp16 $aaaa, $aaaa endTestFlagNClear")

	add16Test($0001, $0002, $0003, "add16 low bits")
	add16Test($0100, $0200, $0300, "add16 high bits")
	add16Test($00ff, $0001, $0100, "add16 overflow low bits")
	add16Test($ff00, $0100, $0000, "add16 overflow high bits")

	add16_8Test($0001, $02, $0003, "add16_8 low bits")
	add16_8Test($00ff, $01, $0100, "add16_8 overflow low bits")
	add16_8Test($ffff, $01, $0000, "add16_8 overflow high bits")

	multiply8Test($00, $00, $00, "multiply8 both zero")
	multiply8Test($01, $01, $01, "multiply8 both one")
	multiply8Test($05, $01, $05, "multiply8 right one")
	multiply8Test($01, $00, $00, "multiply8 right zero")
	multiply8Test($01, $05, $05, "multiply8 left one")
	multiply8Test($00, $01, $00, "multiply8 left zero")
	multiply8Test($10, $10, $00, "multiply8 overflow")
	multiply8Test(5, 5, 25, "multiply8 square")

	// Worm tests.
	// Allocate worm for tests.
	jmp !+
worm:
	wormAllocate() // Allocate som bytes here
!:

	{
		beginTest("Initialize worm. Length should be 0.")
		wormInitialize(worm)
		// TODO: Just using allocateZpByte() fails the test.
		.var _02 = allocateSpecificZpByte($02)
		wormGetLength(worm, _02)
		endTest(_02, 0)
		.eval deallocateZpByte(_02)
	}

	{
		beginTest("Set position.")
		ldaxImmediate($0100)
		.var _02 = allocateSpecificZpWord($02)
		stax(_02)
		wormSetPosition(worm, _02)
		wormGetPosition(worm, _02)
		endTest(_02, $0100)
		.eval deallocateZpWord(_02)
	}

	{
		beginTest("Set direction. (down)")
		lda #$01
		.var _02 = allocateSpecificZpByte($02)
		sta _02
		lda #$00
		.var _03 = allocateSpecificZpByte($03)
		sta _03
		wormSetDirection(worm, _02)
		wormGetDirection(worm, _02)
		endTest(_02, $01)
		.eval deallocateZpByte(_02)
		.eval deallocateZpByte(_03)
	}

	{
		beginTest("Move forward.")
		wormMoveForward(worm)
		wormGetPosition(worm, $02)
		endTest($02, $0128)
	}

	{
		beginTest("Move right.")
		lda #$00
		sta $02
		wormSetDirection(worm, $02)
		wormMoveForward(worm)
		wormGetPosition(worm, $02)
		endTest($02, $0129)
	}

	{
		beginTest("Move up.")
		lda #$03
		sta $02
		wormSetDirection(worm, $02)
		wormMoveForward(worm)
		wormGetPosition(worm, $02)
		endTest($02, $0101)
	}

	{
		beginTest("Tail should be length 0.")
		wormGetTail(worm, $02)
		endTest8($02, 0)
	}

	{
		beginTest("Grow tail. Tail should still be length 0.")
		wormGrowTail(worm)
		wormGetTail(worm, $02)
		endTest8($02, 0)
	}

	{
		beginTest("After move. Tail should be length 1.")
		wormMoveForward(worm)
		wormGetTail(worm, $02)
		endTest8($02, 1)
	}

	{
		beginTest("Move more. Tail should stay 1.")
		wormMoveForward(worm)
		wormGetTail(worm, $02)
		endTest8($02, 1)
	}

	{
		beginTest("Grow tail twice. Tail should stay 1.")
		wormGrowTail(worm)
		wormGrowTail(worm)
		wormGetTail(worm, $02)
		endTest8($02, 1)
	}

	{
		beginTest("Move 1. Tail should be 2.")
		wormMoveForward(worm)
		wormGetTail(worm, $02)
		endTest8($02, 2)
	}

	{
		beginTest("Move 2. Tail should be 3.")
		wormMoveForward(worm)
		wormGetTail(worm, $02)
		endTest8($02, 3)
	}

	{
		beginTest("Move more. Tail should stay 3.")
		wormMoveForward(worm)
		wormGetTail(worm, $02)
		endTest8($02, 3)
	}

	// CircularBuffer tests.
	// Allocate and initialize circular buffer for tests.
	jmp !+
circularBuffer:
	circularBufferAllocate()
!:
	circularBufferInitialize(circularBuffer)

	beginTest("Push should grow buffer.")
	lda #$12
	sta $04
	circularBufferPush(circularBuffer, $04)
	circularBufferGetLength(circularBuffer, $02)
	endTest8($02, 1)

	beginTest("The value should be in the buffer.")
	circularBufferGetIterator(circularBuffer, $30)
	ldy #0
	lda ($30), y
	sta $40
	endTest8($40, $12)

	beginTest("Push second value.")
	lda #$34
	sta $04
	circularBufferPush(circularBuffer, $04)
	circularBufferGetIterator(circularBuffer, $02)
	circularBufferGetIteratorNext(circularBuffer, $02, $08)
	circularBufferGetIteratorNext(circularBuffer, $02, $08)
	endTest8($08, $34)

// beginTest("Iterator should be null terminated.")
// circularBufferGetIterator(circularBuffer, $02)
// circularBufferGetIteratorNext(circularBuffer, $02, $08)
// circularBufferGetIteratorNext(circularBuffer, $02, $08)
// endTest($02, $0000)

// 	beginTest("Pop first value.")
// 	circularBufferPop(circularBuffer, $02)
// 	endTest8($02, $12)

	afterTests()
