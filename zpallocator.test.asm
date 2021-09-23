#import "zpallocator.asm"

// # Compiletime tests

.eval zpAllocatorInit(List().add(hardwiredPortRegisters))

.var A = allocateZpByte()
.var B = allocateZpByte()
.assert "A and B should be distinct.", A!=B, true 

.var zpfb = allocateSpecificZpByte($fb)
.assert "It should be possible to allocate specific ZP bytes.", toHexString(zpfb), toHexString($fb)

.asserterror "Subsequent allocations of the same address should fail.", allocateSpecificZpByte($fb)

.eval deallocateZpByte($fb)
.var zpfb3 = allocateSpecificZpByte($fb)
.assert "After deallocation, addresses should be free again.", toHexString(zpfb3), toHexString($fb)

.eval deallocateZpByte(zpfb3)
.asserterror "Double deallocations of the same address should fail.", deallocateZpByte(zpfb3)

.var word = allocateZpWord()
.assert "Allocating a word alloctes 2 adjecent bytes.", deallocateZpByte(word), deallocateZpByte(word+1)

// # Runtime tests

.eval zpAllocatorInit(List().add(hardwiredPortRegisters))

.macro setColors (backgroundColor, borderColor) {
	setBackgroundColor(backgroundColor)
	setborderColor(borderColor)
}

.macro setBackgroundColor (backgroundColor) {
	lda backgroundColor
	sta $d020
}

.macro setborderColor (borderColor) {
	lda borderColor
	sta $d021
}

.macro add (a, b, result) {
	clc
	lda a
	adc b
	sta result
}

.macro bitwiseInvert (a, result) {
	lda a
	eor #$ff
	sta result
}

.macro negate (a, result) {
	.var inverted = allocateZpByte()
	bitwiseInvert(a, inverted)

	.var one = allocateZpByte()
	lda #1
	sta one

	add(inverted, one, inverted)
	sta result

	.eval deallocateZpByte(one)
	.eval deallocateZpByte(inverted)
}

.macro subtract (a, b, result) {
	.var negated = allocateZpByte()

	negate(b, negated)
	add(a, negated, result)

	.eval deallocateZpByte(negated)
}

#import "bootstrap.asm"

{
	.var backgroundColor = allocateZpByte()
	.var borderColor = allocateZpByte()
	.var one = allocateZpByte()
	lda #1
	sta one

	lda 1
	sta backgroundColor

	subtract(backgroundColor, one, borderColor)

	setColors(backgroundColor, borderColor)

	.eval deallocateZpByte(backgroundColor)
	.eval deallocateZpByte(borderColor)
	.eval deallocateZpByte(one)
}

rts






