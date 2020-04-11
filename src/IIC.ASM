
;; input in a register
byte_iic:	ldx		#8		; count of 8 bits
bit_iic:	rola				; shift msb to carry
		bcc		sda_low		; if no carry(msb low)
sda_high:	bset		sda,iicport	; carry set msb high
		bra		pulse_scl
sda_low:	bclr		sda,iicport
pulse_scl:	bsr		delay_small	; delay
		bset		scl,iicport	; set scl high
		bsr		delay_small
		bclr		scl,iicport	; then scl is set low
 ;		bsr		delay_small
		decx				; is count over
		bne		bit_iic		; no next bit
		bclr		sda,iicont	; leave sda high by making it input
		bsr		delay_small
		bsr		delay_small
		bset		scl,iicport
wait_till_scl:	brclr		scl,iicport,wait_till_scl
		bsr		delay_small
		brclr		sda,iicport,byte_over ;error if ackn not rcvd
		bsr		iic_error
byte_over:	bclr		scl,iicport	; set scl and sda low
		bsr		delay_small
		bsr		delay_small
		bclr		sda,iicport
		bset		sda,iicont	; make sda as ouutput port
		rts

delay_small:	nop
		nop
		nop
		nop
		nop
		nop
		rts



iic_error:	bra	       iic_error

iic_tx:		lda		#0c2h		; set iic address byte
		sta		iic_buff
		lda		#94h		; and co_byte as 94h
		sta		co_byte
;; generate start condition
;; first set sda then scl then make sda low while scl is high
;; on return sda is low and scl is low

		bclr		sda,iicport
		bsr		delay_small
		bclr		scl,iicport
		lda		iic_buff
		bsr		byte_iic
		lda		iic_buff+1
		bsr		byte_iic
		lda		iic_buff+2
		bsr		byte_iic
		lda		iic_buff+3
		bsr		byte_iic
		lda		iic_buff+4
		bsr		byte_iic

;; generate stop condition
;; fisrt sda is cleared  the scl is set high
;; then make sda is set high keepring scl high
;; on return scl is high and sda is also high

		bset		scl,iicport
		bsr		delay_small
		bset		sda,iicport
		rts


