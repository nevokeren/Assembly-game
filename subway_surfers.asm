IDEAL

MODEL small

STACK 100h

DATASEG

	;colors
		linescolor db 15
		backgroundcolor db 8
		player db 10
		block_color db 6
	;lines
		leftline dw 40
		middleline1 dw 90
		middleline2 dw 140
		bottomline dw 190
	;loop data
		loop_ dw 00
		loop1 dw 50
	;blocks data
		blocks_highest_x dw 00
		max_block dw 00
	;randoms
		random dw 00

CODESEG

start:
	mov ax, @data
	mov ds, ax

;set grafic mode
	mov ax, 13h
	int 10h

call base_color

JMP Wait_For_Data

PROC base_color
	mov cx, 320
	mov al, [backgroundcolor]
	mov dx, 40
	mov bh, 0h
	mov ah, 0ch
color_background:
	int 10h
	inc dx
	cmp dx, 190
	JNE color_background
	mov dx, 40
	dec cx
	cmp cx, -1
	JNE color_background

;the upper line
	mov cx, 320
draw_upper_line:
	mov bh, 0h
	mov dx, [leftline]
	mov al, [linescolor]
	mov ah, 0ch
	int 10h
	dec cx
	cmp cx, -1
	JNE draw_upper_line

;the 1 middle line
	mov cx, 320
draw_middle_line1:
	mov bh, 0h
	mov dx, [middleline1]
	mov al, [linescolor]
	mov ah, 0ch
	int 10h
	dec cx
	cmp cx, -1
	JNE draw_middle_line1

;the 2 middle line
	mov cx, 320
draw_middle_line2:
	mov bh, 0h
	mov dx, [middleline2]
	mov al, [linescolor]
	mov ah, 0ch
	int 10h
	dec cx
	cmp cx, -1
	JNE draw_middle_line2

;the bottom line
	mov cx, 320
draw_bottom_line:
	mov bh, 0h
	mov dx, [bottomline]
	mov al, [linescolor]
	mov ah, 0ch
	int 10h
	dec cx
	cmp cx, -1
	JNE draw_bottom_line

;create player in the middle
create_the_player:
	mov cx, 300
	mov dx, 110
	mov bh, 00h
	mov al, [player]
	mov ah, 0ch
color_player:
	int 10h
	dec cx
	cmp cx, 295
	JNE color_player
	inc dx
	mov cx, 300
	cmp dx, 120
	JNE color_player
	ret
ENDP base_color

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC move_down
; move down
	mov bh, 00h
	mov cx, 296
	mov dx, 0
	mov ah, 0dh
;;;find player top y
player_top_y:			
	inc dx
	dec cx
	int 10h
	cmp al, [block_color]
	JNE nxt
	call break
nxt:
	inc cx
	int 10h
	cmp al, [player]
	JNE player_top_y
	mov cx, 296
	mov ah, 0ch
	mov bh, 00h
	cmp dx, 160
	JNE cnte
	call WaitForData
cnte:

	mov [loop_], dx
	add [loop_], 60
color1:
	mov al, [player]
	int 10h
	dec cx
	cmp cx, 295
	JNE color1
	mov cx, 300
	sub dx, 10
	cmp dx, 90
	JE delete_line1
	cmp dx, 140
	JE delete_line1
	mov al, [backgroundcolor]
	JMP delete1
delete_line1:
	mov al, [linescolor]
delete1:
	int 10h
	dec cx
	cmp cx, 295
	JNE delete1
;;;line down
	add dx, 11
	mov cx, 300
;;;delay
	push dx
	mov dx, 7500
	call delay
	pop dx

	cmp dx, [loop_]
	JNE color1
	ret
ENDP move_down

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC move_up
; move up
	mov bh, 00h
	mov cx, 296
	mov dx, 200
	mov ah, 0dh

;;;find player min y
player_y:			
	dec dx
	dec cx
	int 10h
	cmp al,[block_color]
	JNE nxt1
	call break
nxt1:
	inc cx
	int 10h
	cmp al, [player]
	JNE player_y
	mov cx, 300
	mov ah, 0ch
	mov bh, 00h
	cmp dx, 69
	JNE cnt
	call randomize_blocks
cnt:
	mov [loop_], dx
	sub [loop_], 60
	JMP color
color:
	mov al, [player]
	int 10h
	dec cx
	cmp cx, 295
	JNE color
	mov cx, 300	
	add dx, 10
	cmp dx, 90
	JE delete_line
	cmp dx, 140
	JE delete_line
	mov al, [backgroundcolor]
	JMP delete
delete_line:
	mov al, [linescolor]
delete:
	int 10h
	dec cx
	cmp cx, 295
	JNE delete
	mov cx, 300
	push bx
	mov bx, 0
	sub dx, 10
	mov al, [player]
c1:   ;;;count to 9999 to create delay
	inc bx
	cmp bx, 7000
	JNE c1
;;;line up
	dec dx
	cmp dx, [loop_]
	pop bx
	JNE color
	call randomize_blocks
	ret
ENDP move_up

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC WaitForData
;create randoms
create_randoms:
randstart:
	mov ah,0h ; interrupts to get system time
	int 1ah
	mov ax,dx
	xor dx,dx
	mov cx,6
	div cx ;  dx contains the remain of the division - from 0 to 9
	add dx,1
	mov [random], dx
cc:
	cmp dx, 1
	JE blocks
	JMP wait_
	cmp dx, 2
	JE blocks
	JMP wait_
	cmp dx, 3
	JE blocks
	sub dx, 3
	mov [random], dx
	JNE cc
blocks:
	call randomize_blocks
	
;wait for data
wait_:
	mov  ah, 00h
    int  16h
	cmp ah, 48h
	JNE next
	call move_up
	JMP randomize_blocks
next:
	cmp ah, 50h
	JE call_move_down
	JMP randomize_blocks
call_move_down:
	call move_down
	call randomize_blocks
	JMP create_randoms
ENDP WaitForData

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC randomize_blocks
	mov cx, 320
	mov dx, 60
	mov ah, 0dh
	mov bh, 0h
find:					;find last block
	dec cx
	cmp cx, 0
	JNE a
	add dx, 50
	cmp dx, 160
	JE j
	call jenerate_block
	ret
j:
	mov cx, 320
	JMP find
a:
	int 10h
	cmp al, [block_color]
	JNE find
	cmp dx, 60
	JNE cmpr
	call higher_block

cmpr:
	cmp dx,110
	JNE r
	call middle_block
r:
	ret
ENDP randomize_blocks

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC higher_block
	inc cx
	mov dx, 50
	mov ah, 0ch
	mov bh, 0h
	mov al, [block_color]
color_block:			;color next block's row
	int 10h
	inc dx
	cmp dx, 80
	JNE color_block
delete_blocks_back:
	sub cx, 60
	cmp cx, 0
	JNL w
	call wait_
w:

	JMP g
call_WaitForData:
	call WaitForData
g:
	mov dx, 50
	mov ah, 0ch
	mov bh, 00h
	mov al, [backgroundcolor]
l:
	int 10h
	inc dx
	cmp dx, 80
	JNE l
	ret
ENDP higher_block

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC middle_block
	mov cx, 320

	mov dx, 110
	mov ah, 0dh
	mov bh, 0h
	int 10h
	inc cx
	mov dx, 100
	mov ah, 0ch
	mov bh, 0h
	mov al, [block_color]
color_block1:			;color next block's row
	int 10h
	inc dx
	cmp dx, 130
	JNE color_block1
delete_blocks_back1:
	sub cx, 60
	cmp cx, 0
	JNL not_wait
	call wait_
not_wait:
	JMP s
call_WaitForData1:
	call WaitForData
s:
	mov dx, 100
	mov ah, 0ch
	mov bh, 00h
	mov al, [backgroundcolor]
t:
	int 10h
	inc dx
	cmp dx, 130
	JNE t
	JMP wait_
	ret
ENDP middle_block

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC jenerate_block
	mov dx, [random]
	cmp dx, 1
	JNE cmpr2
	mov dx, 50
	mov [max_block], 100
	mov al, [block_color]
	mov ah, 0ch
	mov bh, 00h
	mov cx, 1
jenerate:
	int 10h
	inc dx
	cmp dx, [max_block]
	JNE jenerate
	ret
cmpr2:
	cmp dx, 2
	JNE cmpr3
	mov cx, 1
	mov dx, 120
	mov [max_block], 170
	JMP jenerate
cmpr3:
	mov cx, 1
	mov dx, 190
	mov [max_block], 240
	JMP jenerate
ENDP jenerate_block

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PROC break
	mov ah, 0ch
	mov bl, 00h
	mov al, 0
	mov cx, 0
	mov dx, 0
black:
	int 10h
	inc dx
	cmp dx, 200
	JNE black
	mov dx, 0
	inc cx
	cmp cx, 320
	JNE black
	JMP break
ENDP break

PROC delay
	push bx
	mov bx, 0
d:
	inc bx
	cmp bx, dx
	JNE d
	pop bx
	ret
ENDP delay

exit:
	mov ax, 4c00h
	int 21h

END start