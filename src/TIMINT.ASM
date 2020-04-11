; timena - enable timer tick
; timnxt - update output compare register with a new value
;	   so that to have another interrupt after few msecs
;	   read existing ocmp register low and high byte
;	   add low and high byte of clk count
;	   and write back in ocmp register(first high then low byte)
; xtal clock = 4 MHz
; timer clock = 500 KHz , time = 2 uSEC
; 1 msec = 500 clocks
;  5 msec = 2500 clocks
; 10 msec = 5000 clocks
; 20 msec = 10000 clocks
; 40 msec = 20000 clocks
; 50 msec = 25000 clocks
; 100 msec = 50000 clocks
; rem timeout cnt is based on output compare time
; if clkcount is changed also change remtimoutcnt in stdac program
clkcount fdb	2500t
tic_in_1sec  fcb    200t
tic_in_half_sec  fcb   100t
timena: lda	tcr		; read tcr
	ora	#40h		; set ocie = 1
	sta	tcr		; write back to enable ocie
timnxt: lda	tsr		; read tsr to clear flag
	lda	ocmpl		; read output compare low
	add	clkcount+1	; add count low byte
	sta	itemp		 ; save in temp
	lda	ocmph		; read output compare high
	adc	clkcount	; add count high byte
	sta	ocmph		; write back in output compare high
	lda	itemp		 ; and in output compare low
	sta	ocmpl		; (first high then low as per 05 manual)
	rts

; timint - timer interrupt occurs every 50 msec
;	isr will update ocmp register for nxt interrupt
;	isr will refresh grid data also
;	increase tick count
;	if tick count reaches a value of 1 sec
;	   reset tick count and update time in secs/mins/hours

timint: brclr	ocf,tsr,chk_ic	    ; if output compare flag set , goto oc_int
	jsr	oc_int
chk_ic: brclr	icf,tsr,ret_timint     ; if input capturre flag set , goto ic_int
	jsr	ic_int

hwirq_int:
swirq_int:
ret_timint: rti



oc_int:		jsr	timnxt		; update ocmp register for nxt interrupt
		jsr	refresh_grid	; refresh display data

oc_int1:	lda	ticks		; increment tick count
		inc	ticks
		cmp	tic_in_half_sec ; is 1/2 second over
		bne	chk_1_sec	; no , inc ticks
; add program				; sub routine for action at 1/2 sec
		inc	half_secs	; used for numeric key entry also
		bra	chk_onoffdly
chk_1_sec:	cmp	tic_in_1sec
		bne	chk_onoffdly
		clr	ticks
		inc	sex
		lda	#60t		; added on 20.3.95 for sleep function
		cmp	sex		; is secs = 60t
		bne	chk_onoffdly	; no chk_on offdly
		inc	mins		; else inc mins
		clr	sex		; and reset secs to zero
		lda	sleep_mins	; if sleep_mins already zero
		beq	chk_onoffdly	; do nothing
		dec	sleep_mins	; else decremen sleep mins
		bne	chk_onoffdly	; if not yet zero-chk_onoffdly
		jsr	set_power_off	; else switch off power

;; if onoffdly is ff do not do any thing-goto tofint
;; if onoffdly # ff then decrement onoffdly
;;	if onoffdly #  zero goto tofint
;; if onoffdly = 00 then analyse -ontime or offtime
;;	depending upon dispon_offb bit in status
;;  if display was off then set display on
;;	but check for timeout first
;;	if timeout become zero
;;		then stop blinking by setting onoffdly to ff
;;		and by displaying channel number inpalce of tuning value
;;	set onoffdly = dispontime
;;	set dispon_offb bit to 1
;;	display tuning value on display
;;  if display was on then set display off
;;	set onoffdly = dispofftime
;;	blank display
;;	clear dispon_offb bit to 0
;;
;;


chk_onoffdly:	lda	onoffdly
		cmp	#0ffh
		beq	tofint
		dec	onoffdly
		bne	tofint
		brset	dispon_offb,status,offtime
ontime:		bset	dispon_offb,status
		lda	timeout
		beq	ontime1
		dec	timeout
		beq	tout_blink
ontime1:	lda	#dispontime
		sta	onoffdly
		bra	tofint
offtime:	lda	#dispofftime
		sta	onoffdly
		inc	blink_count
		brset	0,blink_count,offtime1	; update display after 2 blinks
		bset	upd_blink_data,status	; for updating blink data
offtime1:	bclr	dispon_offb,status
		bra	tofint
;; if rem time out reaches a vlue of zero
;; then clear byte count
;; new data and repeat in status
tofint:		tst	rem_timeout
		beq	ret_tofint
		dec	rem_timeout
		bne	ret_tofint
		clr	byte_cnt
		clr	decode
		bclr	new_data,status
		bclr	repeat,status
ret_tofint:	rts

;; after time out
;; display channel number
;; clear mode into channel

tout_blink:	jsr	update_disp
		bra	tofint




; ic_int : used for sensing remote rx data
;	read input capture time value and store in fime
;	check decode value and act according to state
;	leader leading edge	state 1
;	leader fallin edge	state 2
;	first custom code edge	state 3


recdat: jsr	chk_valid_pulse ; check pulse validity
	bcc	ignore_pulse	; ignore if invalod
	ldx	#off_0		; is time gap from bit to bit = 0
	jsr	chk_lim
	bcs	recda_qu	; yes goto recda_qu
	ldx	#off_1		; else check for bit 1
	jsr	chk_lim2
	bcs	tstok3
	jmp	sx0		; if neither 0 nor 1 reset process
tstok3: bset	7,data		; bit 1 rcvd , set msb of data
recda_qu: inc	bit_cnt		; increase bit cnt
	brset	3,bit_cnt,byte_do	; if all 8 bits rcvd goto byte_do
	lsr	data		; else shift right data by one
	jmp	tstok2		; update stimed and return

byte_do: lda	decode		; get decode value
	ldx	data
	sub	#03
	bne	ck_bcus

$ifnot	skipcust
dec_s34:cpx	#custcode	 ; state 3 - custome code rcvd = custcode?
	beq	tstokda		; yes , goto testokda, next byte
	bra	sx0		; else start process again
$elseif
dec_s34:bra	tstokda
$endif

ck_bcus: deca			; check for state 4
	bne	ck_data
dec_s45: comx			; state 4 - inverted custom code

$ifnot	skipcust
	cpx	#custcode1	 ; is it equal to custcode
	beq	tstokda		; if yes , next byte
	bra	sx0		; else restart proccess
$elseif
	bra	tstokda
$endif

ck_data: deca			; check for state 5
	bne	ck_bdata
dec_s56: stx	incode		; save data in incode
	bra	tstokda
ck_bdata: deca			; inverted data
	bne	sx0
dec_s67: comx			; is this byte inverse of previous byte
	cpx	incode
	bne	sx0		; no , reset process
	bset	new_data,status ; new byte rcvd
	bclr	repeat,status	; clear repeat bit in status
	clr	byte_cnt	; clear byte count to zero
	lda	#rem_timeout_cnt
	sta	rem_timeout
	jmp	tstokda		; next byte


ic_int:  lda	icrh
	 sta	ftimeh
	 lda	icrl
	 sta	ftimel
	 lda	decode
	 beq	dec_s01
	 cmp	#1
	 beq	dec_s12
	 cmp	#2
	 beq	dec_s23
	 cmp	#7
	 beq	dec_s78
	 cmp	#8
	 beq	dec_s89
	 cmp	#9
	 beq	dec_s90
	 cmp	#0ah
	 beq	dec_s08
	 jmp	recdat
sx0:	 clr	decode			; reset remote sense process
$if	 ir_low
	 bset	iedg,tcr
$elseif
	 bclr	iedg,tcr
$endif
ignore_pulse: nop
ic_qu:	 rts				; return

$if	ir_low
dec_s01: bclr	iedg,tcr		; first leader edge rcvd,start process
$elseif
dec_s01: bset	iedg,tcr
$endif

tstokda  clr	bit_cnt			; select trailing edge ,clr bit_cnt,data
	 clr	data			; to check width of leader pulse
tstok1	 inc	decode			; next state decode = decode+1
tstok2	 lda	ftimeh			; copy time read(ftime) to stimed
	 sta	stimedh
	 lda	ftimel
	 sta	stimedl
	 bra	ic_qu			; return
dec_s12: ldx   #off_s12			; check leader width
	bsr	chk_lim			; should be between 8 - 10 msecs
	bcc	sx0			; if not goto sx0 ie reset process
$if	ir_low
	bset	iedg,tcr		; select rising edge for gap checking
$elseif
	bclr	iedg,tcr		; or fallin egde for next gap checking
$endif
	bra	tstok1			; goto tstok1,update decode,stimed

dec_s23: jsr	 chk_valid_pulse	 ; if noise pulse
	bcc	ignore_pulse		; then just ignore this
	ldx    #off_s23		       ; check gap between leader and first
	bsr	chk_lim			; custom code. between 4 to 5 msec
	bcc	sx0			; if not goto sx0 ie reset process
$if	ir_low
	bset	iedg,tsr		; if yes select next leading edge state
$elseif
	bclr	iedg,tcr
$endif
	bra	tstok1

dec_s78:jsr	chk_valid_pulse
	bcc	ignore_pulse
	ldx    #off_s78		       ; check gap between repeat leader
	bsr	chk_lim			; pulse and last data bit pulse
	bcs	dec_s01			; set for checking falling edge
;	bra	sx0			; using dec_s01
	bra	dec_s01			; even if gap not proper goto dec_s01
					; to check wieth of leader pulse

dec_s89: ldx	#off_s89		; width of repeat leader
	bsr	chk_lim			; should be equal to  9 msec
;	bcc	sx0
	bcc	sx7
$if	ir_low
	bset	iedg,tcr
$elseif
	bclr	iedg,tcr
$endif
	bra	tstokda

dec_s90:jsr	chk_valid_pulse
	bcc	ignore_pulse
	ldx    #off_s90		       ; gap between leader falling edge
	bsr	chk_lim			; and repeat pulse
;	bcc	sx0			; equal to 2.25 msec
	bcc	sx7
	bset	repeat,status
	inc	byte_cnt		; number of repeat bytes rcvd
	lda	#repeat_tocnt		; increase timeout count
	sta	rem_timeout
	bra	tstokda

dec_s08:jsr	chk_valid_pulse
	bcc	ignore_pulse
	ldx    #off_s08		       ; gap between repeat pulse to repeat
	bsr	chk_lim			; leader pulse should be equal to app.
;	bcc	sx0			; 96.75 msec
	bcc	sx7
	dec	decode			; modify decode so as to come to state
	dec	decode			; dec_s89
	dec	decode
	bra	dec_s01

sx7:	lda	#7
	sta	decode
$if	ir_low
	bset	iedg,tcr
$elseif
	bclr	iedg,tcr
$endif
	rts

;; check that input pulse remain active for three times after small delay
;; to avoid detecting spurious noise pulses

chk_valid_pulse:ldx	#3
chk_valid_again:jsr	small_dly
$if	ir_low
		brset	7,portd,ok_pulse
$elseif
		brclr	7,portd,ok_pulse
$endif
		clc
		rts
ok_pulse:	decx
		bne	chk_valid_again
		sec
		rts



chk_lim: lda	ftimel
	sub	stimedl
	sta	stimedl
	lda	ftimeh
	sbc	stimedh
	sta	stimedh
chk_lim2: lda	tim_tbl,x
	cmp	stimedh
	bhi	out_lim
	beq	lo_lim
	lda	tim_tbl+2,x
	cmp	stimedh
	blo	out_lim
	bhi	in_lim
up_lim: lda	tim_tbl+3,x
	cmp	stimedl
	bhs	in_lim
out_lim:clc
	rts
lo_lim: lda	tim_tbl+1,x
	cmp	stimedl
	bhi	out_lim
in_lim: sec
	rts

;; key table modified for ver 2.21/ using 21 keys single sided 6121 board
;; additions are any time selections by numeric key pad
;; local keys as chup/dn or favchup/dn selectable by remote

$if keys_21
numtable:	db 8eh,83h,82h,81h,87h	;key codes for 0,1,2,3,4
		db 86h,84h,8bh,8ah,88h	;key codes for 5,6,7,8,9

k_power		equ	85h
k_favsel	equ	8fh
k_favup		equ	93h
k_favdn		equ	97h
k_chup		equ	90h
k_ftup		equ	92h
k_chdn		equ	94h
k_ftdn		equ	96h
k_lastch	equ	8ch
k_localfav	equ	80h
k_timer		equ	89h
$endif


$if keys_27
numtable:	db 8dh,9ah,99h,98h,96h	;key codes for 0,1,2,3,4
		db 95h,94h,92h,91h,90h	;key codes for 5,6,7,8,9

k_power		equ	80h
k_favsel	equ	8eh
k_favup		equ	8ah
k_timer		equ	82h
k_favdn		equ	86h
k_localfav	equ	81h
k_chup		equ	88h
k_ftup		equ	89h
k_chdn		equ	84h
k_ftdn		equ	85h
k_lastch	equ	8ch
$endif
