#import "bootstrap.asm"
jmp start

#import "zpallocator.asm"
.eval zpAllocatorInit(List().add(hardwiredPortRegisters))

#import "macros.m.asm"
#import "testsuite.m.asm"
#import "worm.asm"
#import "circular-buffer.asm"
#import "wozPrintHex.asm"


.macro add16Test (a, b, wanted, title) {
	beginTest(title)

	// TODO: Just pass the immediate value, instead of using a temp ZP variable.
	ldaxImmediate(a)
	.var result = allocateZpWord()
	stax(result)

	ldaxImmediate(b)
	.var b2 = allocateZpWord()
	stax(b2)

	add16(result, b2)

	endTest(result, wanted)

	.eval deallocateZpWord(result)
	.eval deallocateZpWord(b2)
}

.macro add16_8Test (a, b, wanted, title) {
	beginTest(title)

	ldaxImmediate(a)
	.var result = allocateZpWord()
	stax(result)

	lda #b
	.var b2 = allocateZpByte()
	sta b2
	add16_8(result, b2)

	endTest(result, wanted)

	.eval deallocateZpWord(result)
	.eval deallocateZpByte(b2)
}

.macro multiply8Test (a, b, wanted, title) {
	beginTest(title)

	lda #a
	.var result = allocateZpByte()
	sta result
	lda #b
	.var b2 = allocateZpByte()
	sta b2
	multiply8(result, b2)
	endTest8(result, wanted)

	.eval deallocateZpByte(result)
	.eval deallocateZpByte(b2)
}

.macro cmpTest (a, b, title) {
	beginTest(title)

	lda #a
	.var a2 = allocateZpByte()
	sta a2

	lda #b
	.var b2 = allocateZpByte()
	sta b2

	lda a2
	cmp b2

	.eval deallocateZpByte(a2)
	.eval deallocateZpByte(b2)
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
	.var a2 = allocateZpWord()
	stax(a2)

	ldaxImmediate(b)
	.var b2 = allocateZpWord()
	stax(b2)

	cmp16(a2, b2)

	.eval deallocateZpWord(a2)
	.eval deallocateZpWord(b2)
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
		.var length = allocateZpByte()
		wormGetLength(worm, length)
		endTest8(length, 0)
		.eval deallocateZpByte(length)
	}

	{
		beginTest("Set position.")
		ldaxImmediate($0100)
		.var position = allocateZpWord()
		stax(position)
		wormSetPosition(worm, position)
		wormGetPosition(worm, position)
		endTest(position, $0100)
		.eval deallocateZpWord(position)
	}

	{
		beginTest("Set direction. (down)")
		lda #$01
		.var direction = allocateZpByte()
		sta direction
		wormSetDirection(worm, direction)
		wormGetDirection(worm, direction)
		endTest8(direction, $01)
		.eval deallocateZpByte(direction)
	}

	{
		beginTest("Move forward.")
		wormMoveForward(worm)
		.var position = allocateZpWord()
		wormGetPosition(worm, position)
		endTest(position, $0128)
		.eval deallocateZpWord(position)
	}

	{
		beginTest("Move right.")
		lda #$00
		.var direction = allocateZpByte()
		sta direction
		wormSetDirection(worm, direction)
		.eval deallocateZpByte(direction)

		wormMoveForward(worm)
		.var position = allocateZpWord()
		wormGetPosition(worm, position)
		endTest(position, $0129)
		.eval deallocateZpWord(position)
	}

	{
		beginTest("Move up.")
		lda #$03
		.var direction = allocateZpByte()
		sta direction
		wormSetDirection(worm, direction)
		.eval deallocateZpByte(direction)
		wormMoveForward(worm)

		.var position = allocateZpWord()
		wormGetPosition(worm, position)
		endTest(position, $0101)
		.eval deallocateZpWord(position)
	}

	{
		beginTest("Tail should be length 0.")
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 0)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("Grow tail. Tail should still be length 0.")
		wormGrowTail(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 0)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("After move. Tail should be length 1.")
		wormMoveForward(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 1)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("Move more. Tail should stay 1.")
		wormMoveForward(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 1)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("Grow tail twice. Tail should stay 1.")
		wormGrowTail(worm)
		wormGrowTail(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 1)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("Move 1. Tail should be 2.")
		wormMoveForward(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 2)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("Move 2. Tail should be 3.")
		wormMoveForward(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 3)
		.eval deallocateZpByte(tailLength)
	}

	{
		beginTest("Move more. Tail should stay 3.")
		wormMoveForward(worm)
		.var tailLength = allocateZpByte()
		wormGetTail(worm, tailLength)
		endTest8(tailLength, 3)
		.eval deallocateZpByte(tailLength)
	}

	// CircularBuffer tests.
	// Allocate and initialize circular buffer for tests.
	jmp !+
circularBuffer:
	circularBufferAllocate()
!:
	circularBufferInitialize(circularBuffer)

	{
		beginTest("Push should grow buffer.")
		lda #$12
		.var value = allocateZpByte()
		sta value
		circularBufferPush(circularBuffer, value)
		.var length = allocateZpByte()
		circularBufferGetLength(circularBuffer, length)
		endTest8(length, 1)
		.eval deallocateZpByte(length)
		.eval deallocateZpByte(value)
	}

	{
		beginTest("The value should be in the buffer.")
		.var iterator = allocateZpWord()
		circularBufferGetIterator(circularBuffer, iterator)
		ldy #0
		lda (iterator), y
		.var value = allocateZpByte()
		sta value
		endTest8(value, $12)
		.eval deallocateZpWord(iterator)
		.eval deallocateZpByte(value)
	}

	// {
	// 	beginTest("Push second value.")
	// 	lda #$34
	// 	.var _04 = allocateSpecificZpByte($04)
	// 	sta _04
	// 	circularBufferPush(circularBuffer, _04)
	// 	.var _02 = allocateSpecificZpWord($02)
	// 	circularBufferGetIterator(circularBuffer, _02)
	// 	.var _08 = allocateSpecificZpByte($08)
	// 	circularBufferGetIteratorNext(circularBuffer, _02, _08)
	// 	circularBufferGetIteratorNext(circularBuffer, _02, _08)
	// 	endTest8(_08, $34)
	// 	.eval deallocateZpByte(_04)
	// 	.eval deallocateZpWord(_02)
	// 	.eval deallocateZpByte(_08)
	// }

	// {
	// 	beginTest("Iterator should be null terminated.")
	// 	circularBufferGetIterator(circularBuffer, $02)
	// 	circularBufferGetIteratorNext(circularBuffer, $02, $08)
	// 	circularBufferGetIteratorNext(circularBuffer, $02, $08)
	// 	endTest($02, $0000)
	// }

	// {
	// 	beginTest("Pop first value.")
	// 	circularBufferPop(circularBuffer, $02)
	// 	endTest8($02, $12)
	// }

	afterTests()
