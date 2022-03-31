; simple test for cga graphics

  org 0100h

start:
  mov [stackptr],sp

  ; cga mode
  mov ah,00h
  mov al,04h
  int 10h

  ; draw
  call drawmap
  call drawplayer
  call refresh

  call mainloop

quit:
  mov sp,[stackptr]

  ; text mode
  mov ah,00h
  mov al,03h
  int 10h
         
  ; exit
  mov ah,4Ch
  mov al,00h
  int 21h

; main execution loop
mainloop:
  mov ah,08h
  int 21h

  cmp al,0
  jnz mainloopnz

  mov ah,08h
  int 21h

  mov cl,[player]
  mov ch,[player+1]

  ; udlr is 0, then H/P/K/M

  cmp al,'H'
  jnz mainloopnu
  dec ch
  jmp mainloopmov
mainloopnu:
  cmp al,'P'
  jnz mainloopnd
  inc ch
  jmp mainloopmov
mainloopnd:
  cmp al,'K'
  jnz mainloopnl
  dec cl
  jmp mainloopmov
mainloopnl:
  cmp al,'M'
  jnz mainloopnomov
  inc cl

mainloopmov:
  cmp cl,[mapw]
  jnc mainloopnomov
  cmp ch,[maph]
  jnc mainloopnomov

  call gettile
  mov al,[bx]
  cmp al,1
  jz mainloopnomov

  ; draw tile player is moving off of
  push cx
  mov cl,[player]
  mov ch,[player+1]
  call gettile
  call getscreenxy
  mov ah,0
  mov al,[bx]
  shl ax,5
  add ax,maptiledata
  mov si,ax
  call drawtile
  pop cx

  mov [player],cl
  mov [player+1],ch

  call drawplayer
  call refresh

mainloopnomov:
  jmp mainloop

mainloopnz:
  cmp al,'q'
  jnz mainloop
  ret

; load address of tile (CL,CH) into bx
gettile:
  push cx
  inc cl
  inc ch
  mov bx,map-1
gettile0:
  inc bx
  dec cl
  jnz gettile0
  mov cl,[mapw]
  dec ch
  jnz gettile0
  pop cx
  ret

; draw player
drawplayer:
  mov si,playertiledata
  mov cl,[player]
  mov ch,[player+1]
  call getscreenxy
  call drawtile
  ret

; draw map
drawmap:
  mov bx,map
  mov cx,0
drawmap0:
  mov ah,0
  mov al,[bx]
  shl ax,5
  mov si,maptiledata
  add si,ax

  call getscreenxy

  call drawtile

  inc bx
  inc cl
  cmp cl,[mapw]
  jnz drawmap0
  mov cl,0
  inc ch
  cmp ch,[maph]
  jnz drawmap0

  ret

; load di with (CL*4+CH*8*80) - uses di,ax
getscreenxy:
  mov ah,0
  mov al,ch
  shl ax,5
  mov di,ax
  mov ah,0
  mov al,ch
  shl ax,3
  add ax,di
  shl ax,4
  mov di,ax
  mov ah,0
  mov al,cl
  shl ax,2
  add di,ax

  ret

; copy screen from 0B800h to 0BA00h
refresh:
  push es
  push ds

  mov ax,0B800h
  mov ds,ax
  mov ax,0BA00h
  mov es,ax

  mov si,0
  mov di,0
  mov cx,200*80
refresh0:
  movsb
  dec cx
  jnz refresh0

  pop ds
  pop es
  ret

; draw 16x8 tile from SI to 0B800h:DI - uses ax,si,di
drawtile:
  mov ax,0B800h
  mov es,ax

  mov al,4
  mov ah,8
drawtile0:
  movsb
  dec al
  jnz drawtile0
  mov al,4
  add di,76
  dec ah
  jnz drawtile0

  mov ax,0
  mov es,ax

  ret
  
stackptr:
  dw 0

; level data
player:
  db 1,3

mapw:
  db 12
maph:
  db 8
map:
  db 0,0,0,0,0,0,0,0,0,0,0,0 
  db 0,0,0,0,1,1,1,1,1,1,0,0
  db 0,0,0,0,1,2,2,2,2,1,0,0
  db 0,0,0,0,1,2,2,2,2,1,0,0
  db 0,0,0,0,1,1,2,1,1,1,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0

; graphics data
playertiledata:
  db 00000000b,10101000b,00000000b,00000000b
  db 00000010b,10101010b,00000000b,00000000b
  db 00000000b,10100100b,01100000b,00000000b
  db 00000010b,10000000b,00100000b,00000000b
  db 00000000b,10101010b,10000000b,00000000b
  db 00000010b,10010110b,10100100b,00000000b
  db 00000010b,10101010b,10101010b,00000000b
  db 00001010b,10101010b,10101010b,00000000b

maptiledata:
  db 00000000b,00000000b,00000000b,00000000b
  db 00000100b,00000000b,00000001b,00000000b
  db 00010001b,00000001b,00000000b,00000000b
  db 00000000b,00000100b,00000000b,00000000b
  db 00000000b,00000100b,00000000b,00000000b
  db 00010000b,00000000b,00000000b,00010000b
  db 00000000b,00000000b,00000000b,01000100b
  db 00000000b,00000000b,00000000b,00000000b

  db 11111111b,11111111b,11111111b,11111111b
  db 10111010b,10101010b,10111010b,10101010b
  db 11111111b,11111111b,11111111b,11111111b
  db 10101010b,10111010b,10101010b,10111010b
  db 11111111b,11111111b,11111111b,11111111b
  db 10111010b,10101010b,10111010b,10101010b
  db 11111111b,11111111b,11111111b,11111111b
  db 10101010b,10111010b,10101010b,10111010b

  db 00000000b,00101000b,00101000b,00101000b
  db 00101000b,00101000b,00000000b,00101000b
  db 00101000b,00101000b,00101000b,00101000b
  db 00101000b,00101000b,00101000b,00101000b
  db 00101000b,00101000b,00101000b,00101000b
  db 00101000b,00000000b,00101000b,00000000b
  db 00101000b,00101000b,00101000b,00101000b
  db 00101000b,00101000b,00101000b,00101000b
