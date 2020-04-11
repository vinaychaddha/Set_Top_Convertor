

	org	80h
itemp		db	00	; reqd in timint
temp		db	00	; cnvrt
temp1		db	00	; slow_down routine
;; used in display and convert to bcd programs
units		db	00
tens		db	00
segunit		db	00
segten		db	00


ticks		db	00
half_secs	db	00
sex		db	00
mins		db	00		; added on 20.3.95 for sleep
sleep_mins	db	00		; timer function
timeout		db	00
onoffdly	db	00

count		db	00		; number of bits in serial tx to eeprom

iic_buff	db	00	;; iic buff for mc44802
co_byte		db	00	;; five bytes
ba_byte		db	00
div_ratio	db	00,00

;; following 5 byets added on 4.3.95 for multi tuner facility
def_offsetm	db	00	;; default offset value
max_offsetm	db	00	;; maximum offset
lom		db	00	;; local osc LSB only MSB is always 2
				;; possible values are 100 or 101
				;; as msb is 2 or 512
sm		db	00	;; steps/mhz

offset		db	00,00,00; channel offset value
ch_offbit	equ	1fh	; <4:0>  channel offset 00 to 1f
ch_favbit	equ	07	; <7>	 fav ch
ch_lockbit	equ	06	; <6>	 ch locked
ch_otherbits	equ	0e0h	; all bits except offset bits

channel		db	00		; channel number
ch_bits		equ	7fh		; bits used for channel number

blink_count	db	00		; used in timint ocint

status		db	00
poweron_offb	equ	07
dispon_offb	equ	06
upd_blink_data	equ	05		; set to 1 during disp_off routine
					; rem_act will look for one
					; call proc_ftup/dn etc..
					; and set it to 0 again
new_data	equ	04
repeat		equ	03
first_power_on	equ	02		; set 1 during set_power_on called by
					; remote or local power up routine
					; added for channel locking at cold
					; power on only as reqd by tuner mfrs.
favch_chb	equ	01		; if high local updn are fav updn
					; if low local updn are ch updn

data		db	00
decode		db	00
incode		db	00
ftimel		db	00
ftimeh		db	00
stimedh		db	00
stimedl		db	00
bit_cnt		db	00
rem_timeout	db	00
byte_cnt	db	00
wait_till_hsecs db	00	; used for second numeric key
rem_channel	db	00
last_channel	db	00
repeat_cntm	db	00	; memory value of repeat cnt
repeat_keym	db	00	; count for repeat key sequence
repeat_keyfast	equ	06t	; after 6 keys goto fast mode
repeat_cnt	equ	04	; after this count got next channel
repeat_cnt_fast equ	02	; fast change

local_dlym	db	00	; hold local delay loop value
local_dly	equ	0ffh	; normal delay
local_dly_fast	equ	07fh	; delay for fast local up/dn

rem_timeout_cnt equ	30t	; wait for 30 oci and then say no key
repeat_tocnt	equ	50t	; wait for 50 oci and then say no key
				; value longer as repeat gap is more
key_gap_hsecs	equ	04t	; wait for second numeric key for 4 half secs
				; ie 2 secs app

;; tuner type equates added on 4.3.95
tunerd		equ	portd
tunerc		equ	ddrd
tuner_lo	equ	5	; low	612.75 high 611.75
;tuner_psc	equ	irq	; low	256    high 128

;; key board equtes
kbd		equ	portb
kbdc		equ	ddrb

swpower		equ	07
swchup		equ	06
swchdn		equ	05
def_keys	equ	0e0h	  ; bit 7,6,5 high



;; disp equtes

dispontime	equ	50t	; disp on for 50 * timer overflow interrupt
dispofftime	equ	50t	; disp off for 50 * timer overflow period
time_dly	equ	10t	; disp blinks for 10 times after ft+/ft- key
				; is released

cdisp		equ	ddra
ddisp		equ	porta
segport		equ	porta
segportc	equ	ddra
cgrid		equ	portc
dgrid		equ	ddrc
gridport	equ	portc
gridportc	equ	ddrc
grid_unit	equ	2	; units
grid_ten	equ	3	; tens
grid_pos	equ	0ch    ; bit  2,3 high
;; iic equates
sda		equ	0
scl		equ	1
iicport		equ	portc
iicont		equ	ddrc

$if		relay12
relay_pos	equ	40h		  ; pin no 12/44802 is for relay
relay_bit	equ	06h
$endif

$if		relay9
relay_pos	equ	04h		; pin no 9/44802 is for relay
relay_bit	equ	02h
$endif



;; equates for eeprom

csmem		equ	4
clkmem		equ	5
dimem		equ	6
domem		equ	7
drom		equ	portc
crom		equ	ddrc

ewen		equ	30h
ewds		equ	00h
eread		equ	80h
ewrite		equ	40h
ewrall		equ	01h
eerase		equ	0c0h
eeral		equ	20h
ewral		equ	10h


