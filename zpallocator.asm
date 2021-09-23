#importonce
.filenamespace ZpAllocator

.var freeZpAddresses

.const @hardwiredPortRegisters = List().add($00, $01).lock()

.function @zpAllocatorInit(addressLists) {
	.eval freeZpAddresses = Hashtable()

	.for(var i=0; i<256; i++) {
		.eval freeZpAddresses.put(i, true)
	}

	.eval reserveUnsafeAddresses(addressLists)
}

.function reserveUnsafeAddresses(addressLists) {
	.for(var j=0; j<addressLists.size(); j++) {
		.var addressList = addressLists.get(j)
		.for(var i=0; i<addressList.size(); i++) {
			.eval allocateSpecificZpByte(addressList.get(i))
		}
	}
}

.function @allocateZpByte() {
	.for(var i=255; i>=0; i-=1) {
		.if(freeZpAddresses.containsKey(i)) {
			.return allocateSpecificZpByte(i)
		}
	}

	.errorif true, "No free bytes available in zero page."
}

.function @allocateZpWord() {
	.for(var i=0; i<256; i+=2) {
		.if(freeZpAddresses.containsKey(i) && freeZpAddresses.containsKey(i+1)) {
			.var lowByte = allocateSpecificZpByte(i)
			.eval allocateSpecificZpByte(i+1)
			.return lowByte
		}
	}

	.errorif true, "No free words available in zero page."
}

.function @allocateSpecificZpByte(requestedAddress) {
	.errorif !freeZpAddresses.containsKey(requestedAddress), "Address $"+toHexString(requestedAddress)+" is taken."
	.eval freeZpAddresses.remove(requestedAddress)
	.return requestedAddress
}

.function @allocateSpecificZpWord(requestedAddress) {
	.var address = allocateSpecificZpByte(requestedAddress)
	.eval allocateSpecificZpByte(requestedAddress+1)
	.return address
}

.function @deallocateZpByte(freeAddress) {
	.errorif freeZpAddresses.containsKey(freeAddress), "Address $"+toHexString(freeAddress)+" is aldready free."
	.eval freeZpAddresses.put(freeAddress, true)
}

.function @deallocateZpWord(freeAddress) {
	.eval @deallocateZpByte(freeAddress)
	.eval @deallocateZpByte(freeAddress+1)
}
