

;; 4.3.95 V2.0	converted to multi tuner type
;;		added two port lines as tuner_lo and tuner_psc
;;		in port tunerd
;;		tuner with 611.75(LOW) or 612.75(HIGH) local oscillator
;;		and psc of 256(LOW) or 128(HIGH) can be used
;;		pll table contains only frequency
;;		div ratio is calculated as freq+LO*step/mhz-def_offset

;;		init_tuner routine added in main program during power up
;;		mode. it checks two io lines and set various tuner based values
;;		for psc of 128 step is 4,def_offset is 14,max offset is 28
;;		for psc of 256 step is 2,def_offset is 28,max offset is 14
;;		routines added freq2div in keyproc
;;		modified cal_freq in keyproc

;;		pll table reduced to single byte table (LSB) of freq
;;		msb is calculated as 00 for ch 02-31 and 01 for ch 32-64
;;		and 02 for ch 65-68. changes in cal_freq in keyproc

;;		removed fpl494 and main494 display table as they are no
;;		longer reqd. also removed debug condition for testing with
;;		t10 evm
;;
;; 20.03.95V2.01if psc is 256 then in fre2div routine def_offsetm is not
;;		subtracted. this caused problems with eastern tuner.
;;		problem corrected by change bra location in fre2div program
;;		HEX CHECKSUM 6002
;;
;; 13.3.95	to reduce size removed all init routines and added them to
;; V 2.1	main program
;;		chk_num routine modified to reduce space(rem_act)
;;		co byte as 94 in iic_tx routine in place of first byte
;;		removed first bute of plltable as iic_tx routin modified
;;		cal_freq modified soo that first byte is for ch 2
;;
;;		genstart and  genstop conditions moved in the iic_tx
;;		routine to save jsr and rts instructions
;;		also reduntant instrutions to set sda and scl
;;		at known values removed for  space savings
;;
;;		cnvrt modified to reduce byte count
;;
;;		in refersh_grid routine jsr to next_grid removed
;;		for program reduction
;;
;;		sleep timer function added from 01-99 minutes
;;		at power_on clear sleep timer to avoid any pending sleep time
;;		(routine modified set_power_on in keyproc)
;;
;;		in timint if secs reach a value of sixty then inc mins and
;;		clear secs to zero. and then check for
;;		sleep_mins if zero do nothing
;;		else decrement sleep mins
;;		if reaches a value of zero then call set_power_off
;;
;;		ft with chup/chdn removed
;;		independent ftup/ftdn added
;;		this required double sided remote handset pcb
;;
;;		clr timeout instruction added in stop_blink subroutine
;;		due to problem if in blinking display mode(FT/ST) any other
;;		key is pressed then stop_blink will set onofdly to ff
;;		this will stop blinking but timeout is left as it is.
;;		when FT/ST mode is selected again in rem_act routine
;;		as timeout is not zero, onoffdly or initial value display
;;		will not take place,inc/dec value is displayed on FND and
;;		no blinking of FT/ST value.
;;
;;		fav up/fav dn routines are made auto inc/dec routines
;;		by modifying program in rem_act
;;
;;		if fav up/fav dn is called but no channel with fav bit exists
;;		then proggram stops at last channel. but due to a minor program
;;		bug channel byte holds previos value even though display is
;;		current channel. This causes problem if chup/dn is pressed then
;;		channel number moved is more than one as channel byte and
;;		display channel is different.
;;		problem solved by moving "sta channel" before cmp last_channel
;;		in next_fav and prev_fav subroutines
;;
;;		similary if favup is pressed is continously then scan stops at
;;		first channel. problem solved by moving "jsr cur2last" from
;;		rem_act to keyproc(next_fav and prev_fav). Also to avoid
;;		dead loop second line in routine is marked as next_fav1 and
;;		down in the routine if channel is not found with fav bit on then
;;		program is branched to next_fav1. This avoids calling cur2last
;;		routine every time
;;
;;		CHECK SUM 685F
;;
;; V2.2		to match ftup/dn,sleepup/dn with blinking speed
;;		timint routine is modified by setting a flag upd_blink_disp
;;		when display is switched off
;;		in rem_act routine of ftup/dn/sleepup/dn that flag is sensed
;;		whenever set up/dn routie is called which will update the
;;		display also. flag is reset after updating up/dn value.
;;		rem routines do nor care for byte cnt in repeat flags.
;;
;;		in rem_act program,instructions to check repeat flags
;;		removed. This is done to save space and as program checks for
;;		byte count only,repeat is not necessary
;;
;;		local up/dn will work as local up/dn or fav up/dn. This
;;		action will depend upon remote switch and not on
;;		pressing of localup/dn together at power on.
;;
;; 29.3.95	during timer display if timer key is pressed again then stop
;;		blink but display is of timer value and not of channel
;;		this causes confusion
;;		problem rectified by replaing stop_blink to update_disp
;;		if wrong key is pressed any time
;;
;;		during ft dispaly if ft is released and pressed again
;;		value is incremented by 2 as next release will call
;;		proc_ft  immediately. problem rectified by going to kftupdly1
;;		in place of calling proc ft up
;;
;;		local panel mode is toggled and displayed also in blinking
;;		mode for few secs. program modified in rem_act
;;
;;
;;		CHECKSUM VER 2.2	7F81 (30.3.95)
;;
;;		stdsetop moved before org 20h to avoid bug in assembler
;;		assemble was using 3 bytes if stdsetop was after lda $00
;;		and 2 bytes if stdsetop is before lda $00 instruction
;;
;;		port c values are set before programming ddrc port
;;		as required. previous vertion was setting ddrc first and then
;;		setting output port
;;
;;		at first time power on-set_power_off is called twice to
;;		avoid possibility of relay remaining on
;;
;;		cur2last program moved to first page rom to save space.
;;
;;		ver 2.21
;;
;;		new key codes for single sided 21 keys pcb used
;;		div ratio and div_ratio+1 cleared to avoid invalid
;;		data in these two bytes at power on to be treated
;;		as ba byte and relay remain on some times
;;
;;		ch_favbit was 5, changed to 7
;;		if channel number is 32 or above then during save last ch
;;		routine channel number is saved in location 0
;;		by transferring last channel number to offset
;;		then in disp routing as offset has bit 5 high
;;		due to channel number morew than 32, dot
;;		of fav ch blinks for a while. to avoid this blinking dot
;;		fav ch bit is set to 7
;;
;;		for setting same speed of ch up/down from remote as local
;;		panel repeat count reduced from 5 and 3 to 4 and 2
;;		VER 2.22 checksum 7757 date 12.4.95
;;
;;
;; ver 2.23    tuning freq changed from 611.75/612.75 to 596.75/611.75/612.75
;;	       based on tuner_lo and irq line
;;	       now samsung ctpb33ae/34ae/chinese/hwalin/eastern
;;	       CHECKSUM 795B dated 20.4.95
;;
;;		bug in timer program. first minute takes too long
;;		problem is due to sex variable not cleared to zero at power on
;;		or during timer setting. so first minute may take as long as
;;		255 secs till sex counter reaches to a value of 60t
;;		problem solved by adding clr sex in timer routine in rem_act
;;		program.
;;		CHECKSUM 7A69 dated 21.4.95(fnd normal) 2.24
;;		CHECKSUM 755F dated 21.4.95(fnd reverse) 2.25
;;
;;		bug in timer routine
;;		if only one singke key is entered like 1 for 01 minute
;;		then sex counter is not initalized
;;		causing problem in first count down
;;		problem rectified by adding clr sex after first key also
;;
;;		CHECKSUM      dated 26.4.95(fnd normal)
;;		CHECKSUM 7594 dated 26.4.95(fnd reverse) 2.26

$set	       keys_21	; for single sided 21 keys handset
$setnot        keys_27	; for double sided 27 keys handset

$setnot        fnd_normal
$set	       fnd_reverse

$setnot        ir_low	; setnot for sony -  set for mce
$setnot        mhz480	; set for 480 - setnot for 455

$setnot        skipcust  ; set for skipping set not for exact codes

$setnot		relay12
$set		relay9


custcode	equ	00h	; 85 for eastern 00 for new handset
custcode1	equ	41h	; 84 for eastern 41 for new handset

min_ch		equ	02t
max_ch		equ	68t

;; start date - 27.6.94

$include	"stdp9.asm"
$include	"stdsetop.asm"

	org	20h

tim_tbl equ	*

$if	mhz480
off_s12 equ	*-tim_tbl
tim_s12 fdb	4265t-426t	 ;		  fdb	  0fa0h
	fdb	4265t+426t	 ;		  fdb	  1388h

off_s23 equ	*-tim_tbl
tim_s23 fdb	2132t-213t	 ;		 fdb	 07d0h
	fdb	2132t+213t	 ;		 fdb	 09c4h

off_s78 equ	*-tim_tbl
tim_s78 fdb	19195t-1919t	 ;		 fdb	 3800h
	fdb	19195t+1919t	 ;		 fdb	 6200h

off_s89 equ	*-tim_tbl
tim_s89 fdb	4265t-426t	 ;		 fdb	 0fa0h
	fdb	4265t+426t	 ;		 fdb	 1388h

off_s90 equ	*-tim_tbl
tim_s90 fdb	1066t-106t	 ;		 fbd	03e8h
	fdb	1066t+106t	 ;		 fdb	 04e2h

off_s08 equ	*-tim_tbl
tim_s08 fdb	42656t-4265t	;		fdb	0afc8h
	fdb	42656t+4265t	;		fdb	0c738h

off_0	equ	*-tim_tbl
tim_0	fdb	533t-53t	 ;		 fdb	 01f4h
	fdb	533t+53t	 ;		 fdb	 0271h

off_1	equ	*-tim_tbl
tim_1	fdb	1066t-106t	 ;		 fdb	 0426h
	fdb	1066t+106t	 ;		 fdb	 04a3h
$elseif
off_s12 equ	*-tim_tbl
tim_s12 fdb	0fa0h
	fdb	1388h

off_s23 equ	*-tim_tbl
tim_s23 fdb	07d0h
	fdb	09c4h

off_s78 equ	*-tim_tbl
tim_s78 fdb	3800h
	fdb	6200h

off_s89 equ	*-tim_tbl
tim_s89 fdb	0fa0h
	fdb	1388h

off_s90 equ	*-tim_tbl
tim_s90 fdb    03e8h
	fdb    04e2h

off_s08 equ	*-tim_tbl
tim_s08 fdb	0afc8h
	fdb	0c738h

off_0	equ	*-tim_tbl
tim_0	fdb	01f4h
	fdb	0271h

off_1	equ	*-tim_tbl
tim_1	fdb	0426h
	fdb	04a3h
$endif


$if	fnd_normal
dat_fnd:	db	0c0h,0f9h,0a4h,0b0h,099h,092h,082h,0f8h
		db	080h,098h
dot_on		equ	7fh
blank:		equ	0ffh
dat_a		equ	088h
dat_f		equ	08eh
dat_c		equ	0c6h
dat_h		equ	089h
$endif

$if	fnd_reverse
dat_fnd		db	03h,09fh,25h,0dh,99h,49h,41h,1fh
		db	01h,19h
dot_on		equ	0feh
blank:		equ	0ffh
dat_a:		equ	11h
dat_f		equ	71h
dat_c		equ	63h
dat_h		equ	91h
$endif

;; save current channel number to last channel number
cur2last:	lda	channel
		sta	last_channel
		rts





	org	100h

main:	jmp	start
$include	"plltable.asm"
$include	"iic.asm"
$include	"keyproc.asm"
$include	"disp.asm"
$include	"eeprom.asm"
$include	"rem_act.asm"
$include	"timint.asm"
;; init eeprom port settings
;; init iic bus port settings
;; init disp port settings
;; if power switch pressed at power on : clear eeprom : set default values
;; set channel number = 00
;; get rom data which contains mainly last channel selected at power off
;; copy this data to channel number
;; set poweron_offb bits as 1 and call proc_power routine
;;	this will put the system into standby mode

start:	rsp
	clr	status
	lda	#0ffh	; porta is display port as output port
	sta	ddra
	lda	#0fh	; set sda/scl/grid0/grid 1 high
	sta	portc
	lda	#07fh
	sta	ddrc	; portc as output port sda(H)-scl(H)-grid0(H)-grid1(H)
			; csmem(L)-clkmem(L)-dimem(L). input port-domem
init_power:
	clr	div_ratio  ; clera div_ratio and +1
	clr	div_ratio+1 ; to avoid invalid freq info
	jsr	set_power_off ; ensure that freq info is not treated
			      ; as ba byte due to un defined data at power on

;; init_tuner routine added on 4.3.95 for multi tuner program
;; modified further for 611.75/128,612.75/128,612.75/256,596.75/128
;; tuner_lo	irq	freq	psc
;; HIGH		HIGH	612.75	128
;; HIGH		LOW	612.75	256
;; LOW		HIGH	611.75	128
;; LOW		LOW	596.75	128

init_tuner	lda	#613t%256t
		brset	tuner_lo,tunerd,sel613 ; if high freq is 612.75
					       ; psc depends upon irq line
sel596_612:	deca			       ; if low freq is 611.75 or 596.75
		bih	sel612		       ; depending upn irq line
		lda	#597t%256t	       ; if irq high then select 611.75
sel612:		sta	lom		       ; and psc of 128
		bra	selpsc128
sel613:		sta	lom

;; if tuner_lo is high freq is 612.75 psc depends upon irq line
;; if tuner_lo is low freq is 611.75/596.75 depending upon irq line,psc is 128
;; if tuner_psc is high
;; set steps/mhz = 4.def offset = 14, max offset = 28
;; if tuner_psc is low
;; set steps/mhz = 2,def offset = 7, max offset = 14
;;
chk_n_set_psc	bih	selpsc128	; tuner_psc is irq line
selpsc256	ldx	#2
		lda	#7
		bra	set_values
selpsc128	ldx	#4
		lda	#14t
set_values:	stx	sm
		sta	def_offsetm
		asla
		sta	max_offsetm

set_tcr:
$if	ir_low
	lda	#0c2h		; input capture interrupt enable,+ edge
$elseif
	lda	#0c0h		; input capture interrupt enable,- edge
$endif
	sta	tcr		; output compare interrupt enable
	jsr	set_power_off
	jsr	timena
	cli			; enable interrupts


sense_power:	brset	swpower,kbd,init_channel
		jsr	clear_rom
init_channel:	clr	timeout
		clr	channel
		jsr	get_channel_info
set_channel:	lda	offset			; pick up channel number
		and	#ch_bits		; from offset of 0th channel
		sta	channel
		sta	last_channel
		brclr	7,offset,chkbd		; if msb of loc 0 high then
		bset	favch_chb,status	; set favch_chb high in status

;; check for key press
;; if yes wait and try again
;;	else chkbd again
;; if still pressed
;;	analyse

chkbd:		clr	repeat_keym
		lda	#repeat_cnt	; initial repeat speed setting
		sta	repeat_cntm	; for remote opperation
		lda	#local_dly
		sta	local_dlym
		brclr	new_data,status,chkbd1
		jsr	rem_act
chkbd1:		bsr	sense_kbd
		beq	chkbd
		bsr	dly50
		bsr	sense_kbd
		beq	chkbd

;; analysis
;; if power key pressed got proc_power
;;	and wait till key is released( no auto repeat function in power key)
;; if any other key check standby mode
;; if mcu is in standby mode ignore key and keep scanning for other kbd entries
;; if chup goto local_up routine
;;	on coming back goto chkbd routine(wait till rel and auto repeat
;;	is taken care in local up routine)
;; if chdn goto local_dn routine
;;	on coming back goto chkbd routine as auto repeat and wait till rel
;;	is taken care in local dn routine

chk_power:	brset	swpower,kbd,is_power_on
		jsr	proc_power
		bra	waitilrel
is_power_on:	brset poweron_offb,status,chk_up
		bra	chkbd
chk_up:		brset	swchup,kbd,chk_dn
		jsr	local_up
		bra	chkbd

chk_dn:		brset	swchdn,kbd,chkbd
		jsr	local_dn
		bra	chkbd


waitilrel:	bsr	sense_kbd
		bne	waitilrel
		bsr	dly50
		bsr	sense_kbd
		bne	waitilrel
		bra	chkbd

;; get kbd value
;; check if all keys not pressed
;; return
sense_kbd:	lda	kbd
		and	#def_keys
		cmp	#def_keys
		rts

small_dly:	lda	#10t
smalloop:	deca
		bne	smalloop
		rts


; dly50 : small delay of 50 msec
; spoils a and x register
dly50:	lda	#20h
outlp:	clrx
innrlp: decx
	bne	innrlp
	deca
	bne	outlp
	rts

;; dly500 - long delay
;; if kbd not pressed return
;; this delay is based on value stored in local_dlym
;; which after 10 up/dn operation is reduced to half then
;; speed of local up/dn is also increased

dly500: ldx	local_dlym	; pick up ff or 7f based on local speed reqd
dly500_out:bsr	sense_kbd
	beq	dly500_over
	clra
dly500_in:nop
	nop
	nop
	nop
	deca
	bne	dly500_in
	decx
	bne	dly500_out
dly500_over: rts

	org	1ff0h

disp_blank:	lda	#blank
		sta	segunit
		sta	segten
		rts

	org	1ff8h


	fdb	timint
	fdb	hwirq_int
	fdb	swirq_int
	fdb	start
