
clear_rom:	bsr	prom_enable
		lda	#eeral
		bsr	rom_tx
		bsr	wait_write_over
		lda	#ewral
		bsr	rom_tx
		lda	def_offsetm
		bsr	write_rom_byte
		lda	def_offsetm
		bsr	write_rom_byte
		bsr	wait_write_over
		bsr	prom_disable
		rts

prom_enable:	lda	#ewen
prom_ena_dis:	bsr	rom_tx
		bclr	csmem,drom
		bclr	dimem,drom
		rts

prom_disable:	lda	#ewds
		bra	prom_ena_dis

get_channel_info:lda	 channel
		lsra			; divide channel number by two
		and	#ch_bits
		ora	#eread
		bsr	rom_tx
		jsr	rom_rx		; read first byte
		sta	offset+1	; and store in offset
		jsr	rom_rx		; read second byte
		sta	offset+2	; and store in offset+1
		bclr	csmem,drom	; deselect chip
		bclr	dimem,drom
		brset	0,channel,get_odd_channel ; is channel even or odd
get_even_channel:lda	offset+1	; even copy first byte to offset
		bra	upd_offset
get_odd_channel:lda    offset+2        ; odd,copy second byte to offset
upd_offset:	sta	offset
		rts

wait_write_over:bclr	csmem,drom	; clear csmem and start write cycle
		bclr	dimem,drom
		nop
		nop
		nop
		nop
		bset	csmem,drom	; set csmem high
		nop			; and wait for domem to go high
		nop			; indicating that write cycle is over
wait_till_rdy:	brset	domem,drom,rom_write_over
		bra	wait_till_rdy
rom_write_over: rts


rom_tx:		bclr	csmem,drom	; csmem,clkmem and dimem are all low
		bclr	dimem,drom
		bclr	clkmem,drom
		bset	csmem,drom	; chip selected
		nop
		nop
		bset	clkmem,drom	; optional leading clock with
		nop			; dimem set to zero
		bclr	clkmem,drom
		nop
		nop
		bset	dimem,drom	; leading 1 clocked in
		nop
		nop
		bset	clkmem,drom
		nop
		nop
		bclr	clkmem,drom
		nop
		nop
write_rom_byte: ldx	#8
		stx	count
write_rom_bit:	rola			; msb to carry
		bcs	carry_1
carry_0:	bclr	dimem,drom	; set data to 0 if msb is zero
		bra	dt_rdy
carry_1:	bset	dimem,drom	; set data to 1 if msb is one
dt_rdy:		nop
		nop
		bset	clkmem,drom	; clock in data
		nop
		nop
		bclr	clkmem,drom
		dec	count
		bne	write_rom_bit
		rts



;; last channel being viewed saved in location zero
;; copy channel to offset and set channel = 0
;; save channel number(at location offset) at rom loaction 0
;; restore channel number from offset
;; restore offset by calling get_channel_info

save_last_ch:	lda	channel
		sta	offset
		brclr	favch_chb,status,save_at00
		bset	7,offset	;msb high if favch_chb high in status
save_at00:	clr	channel
		bsr	set_channel_info
		lda	offset
		and	#ch_bits
		sta	channel
		jsr	get_channel_info	; get offset info again
		rts

set_channel_info:jsr	prom_enable	; enable rom writing
		lda	offset
		brset	0,channel,set_odd_channel	; even/odd channel?
set_even_channel:sta	 offset+1	; even copy offset to first byte
		bra	set_channel_num
set_odd_channel:sta	offset+2	; odd copy offset to second byte
set_channel_num:lda	channel		; erase byte
		lsra			; divide channel number by two
		and	#ch_bits
		ora	#eerase
		bsr	rom_tx
		bsr	wait_write_over ; wait till writing is over
		lda	channel		; write byte at channel/2
		lsra			; address
		and	#ch_bits
		ora	#ewrite
		bsr	rom_tx
		lda	offset+1	; without leading zero/one
		bsr	write_rom_byte
		lda	offset+2	; get offset+1
		bsr	write_rom_byte	 ; and write to eeprom
		jsr	wait_write_over
		jsr	prom_disable
		rts


rom_rx:		ldx	#8
		stx	count
read_next_rom:	bset	clkmem,drom
		nop
		brset	domem,drom,dat_1
dat_0:		clc
		bra	bit_read
dat_1:		sec
bit_read:	rola
		bclr	clkmem,drom
		dec	count
		bne	read_next_rom
		rts

