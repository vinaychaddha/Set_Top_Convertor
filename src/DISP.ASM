

;; cnvrt - convert a binary number into two digit segemnt data
;; and save decoded data in segunit and segten
;; uses variables - tens,segunit,segten



cnvrt:	clr tens
cnvten	cmp #10t
	blo cnvunit
	sub #10t
	inc tens
	bra cnvten
cnvunit tax
	lda dat_fnd,x
	sta segunit
	ldx tens
	lda dat_fnd,x
	sta segten
	rts



; clear data from grid
; if dispon_offb is low just quit
; if unit grid low then select gridten and put ten segdata on segport
; else select gridunit and put unit segment data on segport
;	but check for fav ch bit in status, if on then light up dot also

refresh_grid: lda #blank
	sta	segport
	brclr	dispon_offb,status,blankgrid
	brclr	grid_unit,gridport,selten

selunit:bset	grid_ten,gridport
	bclr	grid_unit,gridport
	lda	segunit
	brclr	ch_favbit,offset,dispdata	; if fav bit on in offset
	and	#dot_on				; set grid of unit digit on
	bra	dispdata			; and goto dispdata
selten: bset	grid_unit,gridport
	bclr	grid_ten,gridport
	lda	segten
dispdata: sta	  segport			; put segdata on display
blankgrid:rts					; and return

