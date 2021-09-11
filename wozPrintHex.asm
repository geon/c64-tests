; Having the include guard here made failing tests crash.
; !ifdef wozPrintHex_asm !eof
; wozPrintHex_asm = 1

; https://gist.github.com/nobuh/1161983
; Hex print by Woz, 1976.

PRBYTE
	PHA                    ; Save A for LSD
	LSR
	LSR
	LSR                    ; MSD to LSD position
	LSR
	JSR     PRHEX          ; Output hex digit
	PLA                    ; Restore A

; Fall through to print hex routine

;-------------------------------------------------------------------------
;  Subroutine to print a hexadecimal digit
;-------------------------------------------------------------------------
PRHEX
	AND     #%00001111    ; Mask LSD for hex print
	ORA     #"0"           ; Add "0"
	CMP     #'9'+1         ; Is it a decimal digit?
	BCC +                     ; Yes! output it
	ADC     #6             ; Add offset for letter A-F
+
	jsr $ffd2
	rts
