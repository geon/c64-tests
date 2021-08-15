; load A and X
!macro ldax .target {
	lda .target
	ldx .target + 1
}


; store A and X
!macro stax .target {
	sta .target
	stx .target + 1
}


!macro beq @t {
	bne +
	jmp @t
+
}


!macro bne @t {
	beq +
	jmp @t
+
}
