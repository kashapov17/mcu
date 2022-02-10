;
; work2.asm
;
; Created: 05.02.2022 17:58:37
; Author: Yaroslav
; Task: op=diff, C_size=16, A_size=B_size=8, 
;		C_start_addr=0x75, item=max, 
;		item_addr=0x8B, sort=desc
;

.dseg
.equ C_size=16
.equ A_size=8
.equ B_size=8
.org 0x60
arr_A_mem: .byte A_size
arr_B_mem: .byte B_size
.org 0x75
arr_C_mem: .byte C_size
.org 0x8B
item: .byte 1

.cseg
arr_B_raw: .db 6,2,8,9,15,0,3,5
arr_A_raw: .db 5,1,8,2,1,6,8,3

.macro LOAD_ARR_TO_MEM
	.def rsize=r22
	.def ridx=r23
	.def ritem=r24
	push rsize
	push ridx
	push ritem
	push ZL
	push ZH
	push XL
	push XH
	ldi ZL, LOW(2*@0)
	ldi ZH, HIGH(2*@0)
	ldi XL, LOW(@1)
	ldi XH, HIGH(@1)
	ldi rsize, @2
	ldi ritem, 0
	mov ridx, rsize
load_loop:
	lpm ritem, Z+
	st X+, ritem
	dec ridx
	brne load_loop
load_arr_to_mem_end:
	pop XH
	pop XL
	pop ZH
	pop ZL
	pop ritem
	pop ridx
	pop rsize
	.undef rsize
	.undef ridx
	.undef ritem
.endm

.macro MAX_FROM_ARRAY
	.def rsize=r22
	.def rmax=r23
	.def ridx=r24
	.def ritem=r25
	push rsize
	push rmax
	push ridx
	push ritem
	push ZL
	push ZH
	push XL
	push XH
	ldi ZL, LOW(@0)
	ldi ZH, HIGH(@0)
	ldi XL, LOW(@2)
	ldi XH, HIGH(@2)
	ldi rsize, @1
	mov ridx, rsize 
	ldi ritem, 0
	ld rmax, Z
find_loop:
	ld ritem, Z+
	cp rmax, ritem
	brlo set_max
	rjmp after_max_setting
set_max:
	mov rmax,ritem
after_max_setting:
	dec ridx
	brne find_loop
	rjmp max_from_array_end
max_from_array_end:
	st X, rmax
	pop XH
	pop XL
	pop ZH
	pop ZL
	pop ritem
	pop ridx
	pop rmax
	pop rsize
	.undef rsize
	.undef rmax
	.undef ridx
	.undef ritem
.endm

; insertion or selection sort (I don't know :) I just got it from my mind)
; (descending mode). best O(n) avg and worst O(n^2)
.macro SORT_ARRAY
	.def rkeyj=r22
	.def rkeyi=r21
	.def rsize=r23
	.def ridx=r24
	.def rjdx=r25
	push rkeyj
	push rkeyi
	push rsize
	push ridx
	push rjdx
	push ZL
	push ZH
	ldi ZL, LOW(@0)
	ldi ZH, HIGH(@0)
	ldi ridx, 0
	ldi rsize, @1
element_loop:
	mov rjdx, ridx
	inc rjdx
	cp ridx, rsize
	breq sort_end
	mov YH, ZH
	mov YL, ZL
	ld rkeyi, Z+
	mov XH, ZH
	mov XL, ZL
	ld rkeyj, X
swap_loop:
	cp rjdx, rsize
	breq swap_loop_end
	cp rkeyj, rkeyi
	cpse rkeyj, rkeyi
	brge swap_stage 
	rjmp swap_loop_postroutine
swap_stage:
	swp Y, X
	ld rkeyi, Y
swap_loop_postroutine:
	adiw XH:XL, 1
	ld rkeyj, X
	inc rjdx
	rjmp swap_loop
swap_loop_end:
	inc ridx
	rjmp element_loop
sort_end:
	pop ZH
	pop ZL
	pop rjdx
	pop ridx
	pop rsize
	pop rkeyi
	pop rkeyj
	.undef rkeyi
	.undef rkeyj
	.undef rsize
	.undef ridx
	.undef rjdx	
.endm

;swap two value in memory space
.macro swp
	.def rvar1=r22
	.def rvar2=r23
	push rvar1
	push rvar2
	ld rvar1, @0
	ld rvar2, @1
	st @1, rvar1
	st @0, rvar2
	pop rvar2
	pop rvar1
	.undef rvar1
	.undef rvar2
.endm

init_stack:
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16

load_arrays:
	LOAD_ARR_TO_MEM arr_B_raw, arr_B_mem, B_size
	LOAD_ARR_TO_MEM arr_A_raw, arr_A_mem, A_size

perform_task:
	MAX_FROM_ARRAY arr_B_mem, B_size, item
	SORT_ARRAY arr_A_mem, A_size
	SORT_ARRAY arr_B_mem, B_size

