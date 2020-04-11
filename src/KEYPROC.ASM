;; stop blinking
;; set timeout to 0 and onoffdly to ff
stop_blink:	lda	#0ffh
		sta	onoffdly
		clr	timeout
		bset	dispon_offb,status
		rts




;; proc_power
;; if poweron_offb is high ie mcu is in power on mode goto setpower off
;; if poweron_offb is low ie mcu is in power off mode goto set power on


proc_power:	brset	poweron_offb,status,set_power_off

;;set power on
;;set poweron_offb to 1
;;get channel number and put in on display and update pll ic
;; at first power on when first_power_on is low
;; call proc_chup/proc_chdn for channel locking
;; then set first_power_on bit high
;; to avoid channel locking program at subsequent power on sequences
set_power_on:	bset	poweron_offb,status
		brset	first_power_on,status,set_power_on1
		bset	first_power_on,status
		jsr	proc_chup
		jsr	proc_chdn
set_power_on1:	lda	channel		; set display on
		jsr	proc_channel	; at power on from remote/local kbd
		clr	sleep_mins	; clear sleep timer
		rts			; at power on

;;set power off
;;clear offset
;;set segdata0 and 1 as blank
;;call dispseg to remove existing data
;;clear poweron_offb to 0
;; stop blinking if display is in ft/blink mode
;; set relay off by clearing relay bit in ba byte as low
;; reconfigure pll ic
;;return
set_power_off:	clr	offset
		jsr	stop_blink
		jsr	disp_blank
		bclr	poweron_offb,status
		bclr	dispon_offb,status
		bclr	relay_bit,ba_byte
		jsr	iic_tx
		rts

;; increment channel number by 1 in proc_chup routine
;; wait for long duration
;; if key still pressed call proc_chup again
;; wait for small delay and got previous step
;; if key not pressed even after debounce period
;; update channel number in eeprom
;; and return

;; increment channel or fav channel
;; deciided by favch_chb in status
favch_ch_up:	brset	favch_chb,status,local_fav_up
		jsr	proc_chup
		bra	local_updn_dly
local_fav_up:	jsr	next_fav
local_updn_dly: jsr	one_more_key	; one more local key pressed
		jsr	dly500
		rts

local_up:	jsr	cur2last
		bsr	favch_ch_up
		jsr	dly500
chk_up_again:	brclr	swchup,kbd,do_up_again
		jsr	dly50
		brclr	swchup,kbd,do_up_again
		jsr	save_last_ch	; save channel number in eeprom
		rts			; when key is released
do_up_again:	bsr	favch_ch_up
		bra	chk_up_again


proc_ftup:	lda	offset
		and	#ch_offbit
		cmp	max_offsetm
		beq	proc_ft
		inc	offset
proc_ft:	jsr	cal_freq	; based on new offset update
		jsr	iic_tx		; pll ic div ratio
		bra	ft_dly		; display offset value and set delay

;; common program for ft up and ft dn
;; called first time when ftup/dn is pressed
;; clears blink count and upd_blink_data to ensure first increment
;; of offset value after 2 blinks
;; set onoffdly to 2 to start blinking
;; then move to ft_dly to display ft value and set timeout value to display
;; ft value on display

start_ft_blink: clr	blink_count
		bclr	upd_blink_data,status
		lda	#2
		sta	onoffdly

;; set timeout to time_dly
;; this is the time for which fine tuning info will remain on display
;; also put offset value on display instead of channel
ft_dly:		lda	offset		; display offset value on disp
		and	#ch_offbit	; by calling cnvrt
common_dly:	jsr	cnvrt
only_dly:	lda	#time_dly	;
		sta	timeout
		rts



proc_ftdn:	lda	offset
		and	#ch_offbit
		beq	proc_ft
		dec	offset
		bra	proc_ft

;; proc_sleep up
;; if sleep is already 99 then set sleep to 00
;; else increment slepp ins by 1
;; goto sleep_dly

proc_sleepup	lda	sleep_mins
		cmp	#99t
		bne	inc_sleep
		lda	#0ffh
inc_sleep	inca
		bra	upd_sleep

;; proc_sleepdn
;; if sleep already zero
;; set slepp to 99
;; else decrement sleep by 1

proc_sleepdn	lda	sleep_mins
		bne	dec_sleep
		lda	#100t
dec_sleep:	deca
upd_sleep:	sta	sleep_mins

;; set timeout to time_dly for flashing sleep time duration
;; display sleep by calling cnvrt
;; this routine executed first time sleepup/sleepdn is pressed
;; and for every subsequent sleepuup/dn pressing after sleep timer is
;; incremented or decremented

sleep_dly	lda	sleep_mins
		bra	common_dly

;; proc_chup
;; if channel = max_ch
;; set channel=min_ch
;; else channel = channel+1
;; get chnnel pll/fav ch and locked data
proc_chup:	lda	channel
		cmp	#max_ch
		bne	next_ch
		lda	#min_ch
		deca
next_ch:	inca
proc_channel:	sta	channel
		jsr	get_channel_info

;; get div_ration from table corresponding to channel number
;; add offset value to div_ratio(picked up from eeprom)
;; and get div_ratio applicable to channel

get_freq:	bsr	cal_freq

;; set address byte as c2
;; set co byte as 94h
;; ba byte is set by 01 ie switch on tuner
;; transfer this information to mc44802 ic

		jsr	iic_tx		; output to pll ic 44802

;; get channel number
;; call cnvrt to convert it to segdata and store in segunit and segten


update_disp:	jsr	stop_blink
		lda	channel		; display channel number on fnd's
		jsr	cnvrt
		rts

;; cal_freq
;; calculate div_ratio based on channel number and offset
;; and store it in div_ratio
;; following changes on 4.3.95
;; only byte of div_ratio is picked up from table based on channel number
;; for msb it is 00 for ch 02-31
;;		 01 for ch 32-64
;;		 02 for ch 65-68
;; this is done to save 67 bytes from pll table
;; also first two bytes removed from plltable on 13.3.95
;; they were co byte and byyte for ch no 1
;; now first byte is for channel number 2
;; so divtable-2,x gets correct freq of the channel in x
cal_freq:	ldx	channel		; get ch no

		lda	div_table-2,x ; get first byte and store in div_ratio+1
		sta	div_ratio+1   ; this is LSB
		lda	#relay_pos
		sta	ba_byte		; and store them in ba byte
		clra			; div ration msb is 0
		cpx	#32t	      ; for channels 02-31
		blo	msb_divratio
		lda	#02	      ; div ratio msb is 02 for
		cpx	#64t	      ; channels 65-68
		bhi	msb_divratio
		lda	#01	      ; else for ch 32-64 it is 01
msb_divratio:	sta	div_ratio	; this is div_ratio of channel displayed

;; div table contains only the frequency
;; exact div ratio is calulated by formula
;; freq+LO*steps/ratio-def_offset
;; routine added on 4.3.95


		lda	div_ratio+1	; div_ratio=freq+LO
		add	lom		; add lsb of lom 612 or 613%256
		sta	div_ratio+1
		lda	div_ratio
		adc	#2		; MSB of lom is 2 as lom is 612-613
		sta	div_ratio
		clc			; (freq+LO*2)
		rol	div_ratio+1
		rol	div_ratio
		lda	sm
		deca
		deca
		beq	freq_suboff
		clc
		rol	div_ratio+1
		rol	div_ratio
freq_suboff:	lda	div_ratio+1	; from div ratio subtract def_offsetm
		sub	def_offsetm
		sta	div_ratio+1
		lda	div_ratio
		sbc	#00
		sta	div_ratio
freq2div_over:	lda	offset		; get channel offset value
		and	#ch_offbit	; mask away lock and fav ch bits
		add	div_ratio+1
		sta	div_ratio+1	; add 00 with carry to upper byte of
		lda	div_ratio	; div_ratio. this will set fine tuned
		adc	#00		; value in div_ratio
		sta	div_ratio
		rts

;; decrement channel number by 1 in proc_chdn routine
;; give a large delay ( for first time)
;; if switch still pressed call proc_chdn again
;; wait for small delay and go back to previos step
;; if key not pressed even after debounce period
;; update eeprom for last ch being viewed
;; and return

;; decrement fav ch or ch depending upon favch_chb bit in status

favch_ch_dn:	brset	favch_chb,status,local_fav_dn
		bsr	proc_chdn
		jmp	local_updn_dly
local_fav_dn:	jsr	prev_fav
		jmp	local_updn_dly	; give delay before next call

local_dn:	jsr	cur2last	; save current channel to last channe;
		bsr	favch_ch_dn	; goto prev fav/prev ch
		jsr	dly500
chk_dn_again:	brclr	swchdn,kbd,do_dn_again
		jsr	dly50
		brclr	swchdn,kbd,do_dn_again
		jsr	save_last_ch
		rts
do_dn_again:	bsr	favch_ch_dn
		bra	chk_dn_again
;; proc_chdn
;; if channel = min_ch
;; set channel=max_ch
;; else channel=channel-1
;; proc_channel ie update pll and display and return

proc_chdn:	lda	channel
		cmp	#min_ch
		bne	prev_ch
		lda	#max_ch
		inca
prev_ch:	deca
		jmp	proc_channel





next_fav:	jsr	cur2last	; a has channel number on return
next_fav1:	cmp	#max_ch
		bne	fav_up
		lda	#min_ch
		deca
fav_up:		inca
		sta	channel
		cmp	last_channel
		beq	fav_over
		jsr	get_channel_info
		lda	channel
		brclr	ch_favbit,offset,next_fav1
		jsr	proc_channel
fav_over:	rts

prev_fav:	jsr	cur2last	; a has channel number on return
prev_fav1:	cmp	#min_ch
		bne	fav_dn
		lda	#max_ch
		inca
fav_dn		deca
		sta	channel
		cmp	last_channel
		beq	fav_over
		jsr	get_channel_info
		lda	channel
		brclr	ch_favbit,offset,prev_fav1
		jsr	proc_channel
		rts
