// https://gist.github.com/nobuh/1161983
// Hex print by Woz, 1976.

PRBYTE:
	pha                    // Save A for LSD
	lsr
	lsr
	lsr                    // MSD to LSD position
	lsr
	jsr     PRHEX          // Output hex digit
	pla                    // Restore A

// Fall through to print hex routine

//-------------------------------------------------------------------------
//  Subroutine to print a hexadecimal digit
//-------------------------------------------------------------------------
PRHEX:
	and     #%00001111    // Mask LSD for hex print
	ora     #'0'           // Add "0"
	cmp     #'9'+1         // Is it a decimal digit?
	bcc !+                     // Yes! output it
	adc     #6             // Add offset for letter A-F
!:
	jsr $ffd2
	rts
