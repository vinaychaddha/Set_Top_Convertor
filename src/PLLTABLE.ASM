

;; for samsung tuner
;; freq step is 250 KHz
;; for if = 611.75 MHz min div_ratio = 2447
;; for 48.25 KHz it is 2447+48.25*4 - 5 ie 47 MHz
;; default offset is 5 ie 47 + 1.25 or 48.25 MHz
;; range is 0 to 28
;; range is from standard 00 to standard 28 (-1.25  MHz to +5.75 MHz)


E1     equ    41t
E2     equ    48t
E3     equ    55t
E4     equ    62t
E5     equ    175t
E6     equ    182t
E7     equ    189t
E8     equ    196t
E9     equ    203t
E10    equ    210t
E11    equ    217t
E12    equ    224t
X      equ    69t	;13
Y      equ    76t	;14
Z      equ    83t	;15
Z_1    equ    90t	;16
Z_2    equ    97t	;17
S01    equ    105t	;18
S02    equ    112t	;19
S03    equ    119t	;20
S04    equ    126t	;21
S05    equ    133t	;22
S06    equ    140t	;23
S07    equ    147t	;24
S08    equ    154t	;25
S09    equ    161t	;26
S10    equ    168t	;27
S11    equ    231t	;28
S12    equ    238t	;29
S13    equ    245t
S14    equ    252t	;31	if channel number is 00-31 then MSB is 00
S15    equ    259t	;32	if channel number is 32-64 then MSB is 01
S16    equ    266t
S17    equ    273t
S18    equ    280t	;35
S19    equ    287t
S20    equ    294t	;37
S21    equ    303t
S22    equ    311t
S23    equ    319t	;40
S24    equ    327t
S25    equ    335t
S26    equ    343t
S27    equ    351t
S28    equ    359t
S29    equ    367t
S30    equ    375t	;47
S31    equ    383t
S32    equ    391t
S33    equ    399t	;50
S34    equ    407t
S35    equ    415t
S36    equ    423t
S37    equ    431t
S38    equ    439t
S39    equ    447t
S40    equ    455t	;57
S41    equ    463t	;58
E21    equ    471t	;59
E22    equ    479t	;60
E23    equ    487t	;61
E24    equ    495t	;62
E25    equ    503t	;63
E26    equ    511t	;64   256-512
E27    equ    519t	;65
E28    equ    527t	;66
E29    equ    535t	;67
E30    equ    543t	;68
E31    equ    551t	;69
E32    equ    559t	;70
E33    equ    567t	;71
E34    equ    575t	;72
E35    equ    583t	;73
E36    equ    591t	;74
E37    equ    599t	;75
E38    equ    607t	;76
E39    equ    615t	;77
E40    equ    623t	;78
E41    equ    631t	;79
E42    equ    639t	;80
E43    equ    647t	;81
E44    equ    655t	;82
E45    equ    663t	;83
E46    equ    671t	;84
E47    equ    679t	;85
E48    equ    687t	;86
E49    equ    695t	;87
E50    equ    703t	;88
E51    equ    711t	;89
E52    equ    719t	;90
E53    equ    727t	;91
E54    equ    735t	;92
E55    equ    743t	;93
E56    equ    751t	;94
E57    equ    759t	;95
E58    equ    767t	;96
E59    equ    775t	;97
div_table:



;; following equates added on 4.3.95 to convert table to freq only
;; from div ratio calculation
;; also equates for various types of tuner removed on 4.3.95

LO	equ	0
d_o	equ	0
s	equ	1
;; to reduce space from plltable
;; only lsb is defined
;; msb is calculated as per following rule
;; if channel number is less than 32 (00-31) then MSB is 00
;; if channel number is less than 65 (32-64) then MSB is 01
;; if channel number is more than 64 (65-68) than MSB is 02

    db	  (LO+E2)*s-d_o
    db	  (LO+E3)*s-d_o
    db	  (LO+E4)*s-d_o
    db	  (LO+E5)*s-d_o
    db	  (LO+E6)*s-d_o
    db	  (LO+E7)*s-d_o
    db	  (LO+E8)*s-d_o
    db	  (LO+E9)*s-d_o
    db	  (LO+E10)*s-d_o
    db	  (LO+E11)*s-d_o
    db	  (LO+E12)*s-d_o
    db	  (LO+X)*s-d_o
    db	  (LO+Y)*s-d_o
    db	  (LO+Z)*s-d_o
    db	  (LO+Z_1)*s-d_o
    db	  (LO+Z_2)*s-d_o
    db	  (LO+S01)*s-d_o
    db	  (LO+S02)*s-d_o
    db	  (LO+S03)*s-d_o
    db	  (LO+S04)*s-d_o
    db	  (LO+S05)*s-d_o
    db	  (LO+S06)*s-d_o
    db	  (LO+S07)*s-d_o
    db	  (LO+S08)*s-d_o
    db	  (LO+S09)*s-d_o
    db	  (LO+S10)*s-d_o
    db	  (LO+S11)*s-d_o
    db	  (LO+S12)*s-d_o
    db	  (LO+S13)*s-d_o
    db	  (LO+S14)*s-d_o
    db	  (LO+S15)*s-d_o
    db	  (LO+S16)*s-d_o
    db	  (LO+S17)*s-d_o
    db	  (LO+S18)*s-d_o
    db	  (LO+S19)*s-d_o
    db	  (LO+S20)*s-d_o
    db	  (LO+S21)*s-d_o
    db	  (LO+S22)*s-d_o
    db	  (LO+S23)*s-d_o
    db	  (LO+S24)*s-d_o
    db	  (LO+S25)*s-d_o
    db	  (LO+S26)*s-d_o
    db	  (LO+S27)*s-d_o
    db	  (LO+S28)*s-d_o
    db	  (LO+S29)*s-d_o
    db	  (LO+S30)*s-d_o
    db	  (LO+S31)*s-d_o
    db	  (LO+S32)*s-d_o
    db	  (LO+S33)*s-d_o
    db	  (LO+S34)*s-d_o
    db	  (LO+S35)*s-d_o
    db	  (LO+S36)*s-d_o
    db	  (LO+S37)*s-d_o
    db	  (LO+S38)*s-d_o
    db	  (LO+S39)*s-d_o
    db	  (LO+S40)*s-d_o
    db	  (LO+S41)*s-d_o
    db	  (LO+E21)*s-d_o
    db	  (LO+E22)*s-d_o
    db	  (LO+E23)*s-d_o
    db	  (LO+E24)*s-d_o
    db	  (LO+E25)*s-d_o
    db	  (LO+E26)*s-d_o
    db	  (LO+E27)*s-d_o
    db	  (LO+E28)*s-d_o
    db	  (LO+E29)*s-d_o
    db	  (LO+E30)*s-d_o
;   db	  (LO+E31)*s-d_o
;   db	  (LO+E32)*s-d_o
;   db	  (LO+E33)*s-d_o
;   db	  (LO+E34)*s-d_o
;   db	  (LO+E35)*s-d_o
;   db	  (LO+E36)*s-d_o
;   db	  (LO+E37)*s-d_o
;   db	  (LO+E38)*s-d_o
;   db	  (LO+E39)*s-d_o
;   db	  (LO+E40)*s-d_o
;   db	  (LO+E41)*s-d_o
;   db	  (LO+E42)*s-d_o
;   db	  (LO+E43)*s-d_o
;   db	  (LO+E44)*s-d_o
;   db	  (LO+E45)*s-d_o
;   db	  (LO+E46)*s-d_o
;   db	  (LO+E47)*s-d_o
;   db	  (LO+E48)*s-d_o
;   db	  (LO+E49)*s-d_o
;   db	  (LO+E50)*s-d_o
;   db	  (LO+E51)*s-d_o
