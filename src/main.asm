    org 0x6000

    DEVICE ZXSPECTRUMNEXT

    CSPECTMAP "project.map"


start:
				
	;select slot #0
	ld a, 0
	ld bc, $303b
	out (c), a


	;send pattern data
	ld hl,static_npcs1
	ld bc,0x005b
	otir

	;out 0x57, 32:  x position in 32
	;out 0x57, 32:  y position in 32
	;out 0x57, 0:  no palette offset and no rotate and mirrors flags
	;out 0x57, 130:  sprite visible and show pattern #0

	ld bc, $57
	ld a, (px)
	out (c), a                                      ; x pos is 16 bit number, if over 255 msb stored below
	ld a,(py)
	out (c), a                                      ; y pos

			

	; bits 7-4 pallete offset
	; bit 3 x mirror
	; bit 2 y mirror
	; bit 1 rotate
	; bit 0 x msb
	; off  xf yf r xmsb
	; 0000 0  0  0 0

	ld a, %00000000
	out (c), a
			
	; pattern and visibility

	ld a, %10000000

	; 10000000 = 128
	; bit 7 visible flag
	; bit 6 reserved
	; bits 5-0 pattern index 0-64
	; v r index
	; 1 0 000001

	out (c), a

	;out 0x243b, 21:  select register #21

	ld bc, $243b
	ld a, 21
	out (c), a

	;out 0x253b, 1:  all sprites visible

	ld bc, $253b
	ld a, 1
	out (c), a

	jp main_loop

main_loop:

	call update
	call draw

	ld bc,GAME_SPEED
	call wait

	jp main_loop


wait:
	dec bc
	ld a,b
	cp 0
	jp nz, wait
	ret
update:
	


	ld a,(current_direction)
	cp RIGHT
	jp z, move_right
	cp LEFT
	jp z, move_left

	
	ret


draw:
	;select slot #0
	ld a, 0
	ld bc, $303b
	out (c), a

	;send pattern data
	ld hl,static_npcs1
	ld bc,0x005b
	otir


	;out 0x57, 32:  x position in 32
	;out 0x57, 32:  y position in 32
	;out 0x57, 0:  no palette offset and no rotate and mirrors flags
	;out 0x57, 130:  sprite visible and show pattern #0
	ld bc, $57
	ld a, (px)
	out (c), a                                      ; x pos is 16 bit number, if over 255 msb stored below
	ld a,(py)
	out (c), a                                      ; y pos


	; ; bits 7-4 pallete offset
	; ; bit 3 x mirror
	; ; bit 2 y mirror
	; ; bit 1 rotate
	; ; bit 0 x msb
	; ; off  xf yf r xmsb
	; ; 0000 0  0  0 0

	ld a,(current_direction)
	cp LEFT
	push af
	call z,reset_flip_bit
	pop af
	cp RIGHT 
	push af
	call z,set_flip_bit
	pop af


	ld a,%11000000
	out (c),a

	ld a,%00110100
	out (c),a

	; ret



set_flip_bit:
	ld a, %00001000 ;todo set only that bit
	out (c), a
	ret

reset_flip_bit:
	ld a, %00000000
	out (c), a
	ret




move_right:
	ld a,(px)
	add a,1
	cp 254
	jp nc, flip_direction
	ld (px),a
	ret


move_left:
	ld a,(px)
	sub 1
	cp 17
	jp c, flip_direction
	ld (px),a
	ret




flip_direction:
	ld a,(current_direction)
	cp LEFT
	jp z,set_direction_right
	cp RIGHT
	jp z,set_direction_left
	ret

set_direction_right:
	ld a,RIGHT
	ld (current_direction),a
	ret

set_direction_left:
	ld a,LEFT
	ld (current_direction),a
	ret

;DIRECTIONS:
LEFT equ 0
RIGHT equ 1


current_direction db LEFT

static_npcs1:
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $C4, $C4, $C4, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $FA, $FA, $89, $FA, $FA, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $FA, $FA, $89, $FA, $FA, $FA, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $FA, $89, $89, $FA, $FA, $FA, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $C4, $C4, $C4, $C4, $C4, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $FA, $00, $C4, $C4, $C4, $00, $FA, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $FA, $00, $C4, $C4, $C4, $00, $FA, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $C4, $C4, $C4, $00, $00, $C4, $C4, $00, $00, $00, $00;
	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00;




py db 104
px db 160



GAME_SPEED equ 10000



STACK_SIZE: equ 10    ; in words
stack_bottom:
    ds    STACK_SIZE*2, 0
stack_top:  db 0  ; WPMEM


    SAVENEX OPEN "main.nex", start, stack_top
    SAVENEX CORE 2, 0, 0        ; Next core 2.0.0 required as minimum
    SAVENEX CFG 7;,0,0,0   ; Border color
    SAVENEX AUTO
    ; SAVENEX CLOSE