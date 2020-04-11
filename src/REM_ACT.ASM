
;; reomote processing
;; if power off accept only power key
;; else except all keys
;; set bit 7 always high (ignore function key)
;; repeat_keym is zero when this program is called
rem_act:	lda	incode
		cmp	#k_power
		bne	chk_power_stat
;; if power key pressed
;; act only if first time pressing
;; after processing set repeat to high to avoid repeat action
;; if repeat do not act
;		brset	repeat,status,ret_remact
		jsr	proc_power
;		bset	repeat,status
ret_remact:	bclr	new_data,status
remact_over:	rts

;; if power on then proceed furter else return
;;
chk_power_stat: brset  poweron_offb,status,chk_kchup
		bra	ret_remact

;; do ch up when key is pressed first time
;; then wait for some time
;; check if remote key released ie rem_timeout reached a vlue of zero
;;	if yes return immediately
;; check for repeat flag if not set , wait
;; check for byte count if repeat_cnt not reached , wait
;; check for key code : if equal to chup then do proc_chup: clear repeat flag and wait
;; else return
chk_kchup:	cmp	#k_chup
		bne	chk_kchdn
swap_ch_up	jsr	cur2last
		jsr	proc_chup
chk_kchup_again:tst	rem_timeout
		beq	ret_chsel
;		brclr	repeat,status,chk_kchup_again
		lda	byte_cnt
		cmp	repeat_cntm
		blo	chk_kchup_again
		lda	incode
		cmp	#k_chup
		bne	ret_chsel
		bsr	one_more_key	; one more key found
		jsr	proc_chup
;		bclr	repeat,status
		clr	byte_cnt
		bra	chk_kchup_again

chk_kchdn:	cmp	#k_chdn
		bne	chk_klastch
swap_ch_dn:	jsr	cur2last
		jsr	proc_chdn
chk_kchdn_again:tst	rem_timeout
		beq	ret_chsel
 ;		brclr	repeat,status,chk_kchdn_again
		lda	byte_cnt
		cmp	repeat_cntm
		blo	chk_kchdn_again
		lda	incode
		cmp	#k_chdn
		bne	ret_chsel
		bsr	one_more_key	; one more key pressed
		jsr	proc_chdn
  ;		bclr	repeat,status
		clr	byte_cnt
		bra	chk_kchdn_again

ret_chsel:	jsr	save_last_ch
		bra	ret_remact

;; last channel
;; swap last_channel and channel
;; call proc_channel to display and tune to channel
;; save in eeprom

chk_klastch:	cmp	#k_lastch
		bne	chk_kfavsel
		lda	last_channel
		ldx	channel
		sta	channel
		stx	last_channel
		jsr	proc_channel	; with channel to be selected in A
		bra	ret_chsel

;; inc repeat_keym for every repeat action
;; if counr reches equal to a fixed value
;; then change repeat_cntm to repeat_cnt_fast for fast move
;; and also local_dlym to local_dly_fast for fast move
one_more_key:	inc	repeat_keym
		lda	#repeat_keyfast
		cmp	repeat_keym
		bne	ret_one_more
		lda	#repeat_cnt_fast
		sta	repeat_cntm
		lda	#local_dly_fast
		sta	local_dlym
ret_one_more:	rts
;; fav select/deselect
;; toggle ch_favbit in offset byte
;; save this info in eeprom and update display also

chk_kfavsel:	cmp	#k_favsel
		bne	chk_kfavup
		brset	ch_favbit,offset,clr_favsel
set_favsel:	bset	ch_favbit,offset
		bra	save_favsel
clr_favsel:	bclr	ch_favbit,offset
save_favsel:	jsr	set_channel_info
		jsr	update_disp
		jmp	ret_remact

chk_kfavup:	cmp	#k_favup
		bne	chk_kfavdn
		jsr	next_fav
chk_kfavup_again:tst	 rem_timeout
		beq	ret_chsel
;		brclr	repeat,status,chk_kfavup_again
		lda	byte_cnt
		cmp	repeat_cntm
		blo	chk_kfavup_again
		lda	incode
		cmp	#k_favup
		bne	ret_chsel
		jsr	next_fav
;		bclr	repeat,status
		clr	byte_cnt
		bra	chk_kfavup_again


chk_kfavdn:	cmp	#k_favdn
		bne	chk_kftup
		jsr	prev_fav
;		jmp	ret_remact
chk_kfavdn_again:tst	 rem_timeout
		beq	ret_chsel
;		brclr	repeat,status,chk_kfavdn_again
		lda	byte_cnt
		cmp	repeat_cntm
		blo	chk_kfavdn_again
		lda	incode
		cmp	#k_favdn
		bne	ret_chsel
		jsr	prev_fav
;		bclr	repeat,status
		clr	byte_cnt
		bra	chk_kfavdn_again

;; ft up reoutine
;; check for key code
;; if ok ie equal to ftup then continue
;; check timeout
;; if zero this is first time press then pick up original value and display
;; if not zero then increment ft value by calling proc_ftup
;; wait till remote time out ie no valid key found for some time
;; if keys are continously received then keep on checking for repeatkey
;;	and byte count. if bute count is equal to pre define repeat_cnt
;;	then do ftup again and clear repeat bit and byte count
;;	then keep on waiting if another repeat is required or key is
;;	released

chk_kftup:	cmp	#k_ftup
		bne	chk_kftdn
		tst	timeout
		beq	kftup_disp	; if first press then just disp
					; original value of ft
;		jsr	proc_ftup
		bra	kftup_dly1	; if key pressed during ft routine
					; then goto kftup_dly1
kftup_disp:	jsr	start_ft_blink	; sets variable for ft blinking

kftup_dly:	tst	rem_timeout
		bne	kftup_dly1
		bra	ret_ft
kftup_dly1:	brclr	upd_blink_data,status,kftup_dly
		lda	incode
		cmp	#k_ftup
		beq	kdoftup
		bra	ret_ft
kdoftup:	jsr	proc_ftup
		bclr	upd_blink_data,status
		bra	kftup_dly

ret_ft:		jsr	set_channel_info
		jmp	ret_remact


chk_kftdn:	cmp	#k_ftdn
		bne	chk_timer_key
		tst	timeout
		beq	kftdn_disp
;		jsr	proc_ftdn
		bra	kftdn_dly1
kftdn_disp:	jsr	start_ft_blink	; set variables for ft blinking
kftdn_dly:	tst	rem_timeout
		bne	kftdn_dly1
		bra	ret_ft
kftdn_dly1:	brclr	upd_blink_data,status,kftdn_dly
		lda	incode
		cmp	#k_ftdn
		beq	kdoftdn
		bra	ret_ft
kdoftdn:	jsr	proc_ftdn
		bclr	upd_blink_data,status
		bra	kftdn_dly


chk_timer_key:	cmp	#k_timer
		bne	chk_local_fav
		lda	#2		; start blinking
		sta	onoffdly
		jsr	sleep_dly	; display sleep mins value
					; also set time for blinking
		jsr	wait_for_next	; get first key in A
		cmp	#0ah		; is it numeric
		blo	first_time_found ; yes this is first key
wrong_num_key:	jsr	update_disp	; no-stop blinking and disp ch num
		jmp	ret_remact
first_time_found:sta	sleep_mins	; store it in sleep_mins
		jsr	sleep_dly	; and display the value
		clr	sex
		bsr	wait_for_next	; get second key in A
		cmp	#09t		;
		bhi	wrong_num_key	; no - wrong second key
		sta	temp		; yes - save in temp
		lda	sleep_mins	; pick up first key
		ldx	#10t		; multiply by 10
		mul			; add second key
		add	temp
		sta	sleep_mins	; store in sleep_mins
		clr	sex		; start minute counting from this time
		jsr	sleep_dly	; blink for more time
		jmp	ret_remact	; back to main program


;; wait for fixed number of hsecs
;; and see if any numeric key is rcvd
;; if yes return with number in A
;; if no return with FF in A
wait_for_next:	bclr  new_data,status
		lda	half_secs
		add	#key_gap_hsecs
		sta	wait_till_hsecs
wait_till_next: lda	half_secs
		cmp	wait_till_hsecs
		bne	is_next_rcvd
		lda	#0ffh
		rts
is_next_rcvd:	brclr	new_data,status,wait_till_next
		lda	incode
		jsr	chk_num
		rts

;; if localfav key is pressed then toogle msb of 0th byte of eeprom
;; save channel into temp and again recall it
chk_local_fav:	cmp	#k_localfav
		bne	chk_num_key
		tst	timeout
		beq	local_fav_disp
		lda	channel		; if already in blink mode
		sta	temp		; get channel info of 0th byte
		clr	channel
		jsr	get_channel_info
		bclr	7,offset	; save reverse of current mode
		brset	favch_chb,status,save_eeprom
		bset	7,offset
save_eeprom:	jsr	set_channel_info ; into eeprom
		lda	temp		 ; and get back offset value
		sta	channel		 ; of channel
		jsr	get_channel_info
		brset	favch_chb,status,disp_ch ; toggle local mode
		bra	disp_fa
local_fav_disp: lda	#2		; start blinking
		sta	onoffdly
		brset	favch_chb,status,disp_fa ; disp current value

disp_ch		lda	#dat_C		; disp CH on display
		sta	segten
		lda	#dat_H
		sta	segunit
		bclr	favch_chb,status
		bra	disp_fach_over

disp_fa		lda	#dat_F		; disp FA on display
		sta	segten
		lda	#dat_A
		sta	segunit
		bset	favch_chb,status

disp_fach_over: jsr	only_dly
		jmp	ret_remact
;; is it numeric key(first)
;; if no exit
;; if yes save in rem_channel
;; wait till ticks+key_gap_ticks
;; or second key rcvd ( indicated by new_data settinbg in status
;; if second key is also numeric key
;; cal rem_channel=first key *10+second key
;; if second key is non numeric or second key not rcvd then rem channel=first key


chk_num_key:	bsr	chk_num
		cmp	#0ah
		blo	num_key_found
		jmp	ret_remact
num_key_found:	sta	rem_channel
		jsr	stop_blink
		jsr	disp_blank	; blank display
		ldx	rem_channel	; display one digit (key no)
		lda	dat_fnd,x
		sta	segunit
		bsr	wait_for_next	; get next key
		cmp	#0ah		; is it numeric
		blo	cal_channel2	; yes - calculate  2 keys
		lda	rem_channel	; no - calculate  1 key
		bra	cal_channel1
cal_channel2:	sta	temp
		lda	rem_channel
		ldx	#10t
		mul
		add	temp
cal_channel1:	cmp	#min_ch		; if ch number is between ch_min
		blo	rem_chan_nok	 ; and ch_max then proc_channel
		cmp	#max_ch		; else ignore entries
		bhi	rem_chan_nok

rem_chan_ok:	sta	temp		; save channel number in tem,p
		jsr	cur2last	; copy channel to last channel
		lda	temp		; select new channel
		jsr	proc_channel	; witch channel number in A reg
		jmp	ret_chsel
rem_chan_nok:	jsr	update_disp
		jmp	ret_remact



;;chk_num
;; check if numeric key pressed num key code in a register
;; if not return as it is without spoiling a register
;; if yes A REG contains key code 0-9
chk_num:	ldx	#0ah
next_num:	cmp	numtable-1,x
		beq	key_found
		decx			; all ten keys compared
		bne	next_num	; no try next key
		rts			; yes,return with same code in A
key_found	txa			; key found
		deca			; return with numeic 00-09 in A
		rts
