.model large 
.stack 64
.data 
; screens data 
dummy db ?
S1L1 db "Please enter your name: $ "
S1L3 db "Press Enter key to continue $"
nam1 db 15,?,15 dup('$')  
nam2 db 15,?,15 dup('$')
err db "your Name must start with Char$" 
S2L1 db "To start chattig press F1 $" 
S2L2 db "To start Game press F2 $" 
S2L3 db "To Exit press ESC $" 
endchat db "Press F3 to end chatting $" 
myMess db 50,?,50 dup('$')
line db 80 dup('-'),"$"
point1 db " :0$" 
point2 db " :0$"
val db  00H 
Egame db " To end the game with $"
Pgame db " Press F4$"
rchat db " wants to chat with you$"
rgame db " wants to playing with you$"
lev db "Press 1 to choose level 1 and 2 to choose level 2$" 
cursors dw 0100H
cursorr dw 0c00h 
curss   dw  1410H
cursr   dw  1510h 
level1 db " you will play in level 1$"
level2 db " you will play in level 2$"
;player position
P1x db 0,1,0,1,2,0,1,2,3,4 ,0,1,2,0,1
P1y db 9,9,0Ah,0Ah,0Ah,0Bh,0Bh,0Bh,0Bh,0Bh,0Ch,0Ch,0Ch,0Dh,0Dh
P2x db 79,78,79,78,77,79,78,77,76,75 ,79,78,77,79,78
P2y db 9,9,0Ah,0Ah,0Ah,0Bh,0Bh,0Bh,0Bh,0Bh,0Ch,0Ch,0Ch,0Dh,0Dh
;Bullet characters
Bullet_1 DB 16d
Bullet_2 DB 17d
;-------------------
;Player1 Data  
BulletPosX_1 DB 0 
BulletPosY_1 DB 0  
BulletDoubleSpeed_1 DB 0
PlayerCantShoot_2 DB 0
PlayerDoublePoints_1 DB 0

;------------------
;Player2 Data                                                
BulletPosX_2 DB 0 
BulletPosY_2 DB 0  
BulletDoubleSpeed_2 DB 0  
PlayerCantShoot_1 DB 0
PlayerDoublePoints_2 DB 0
;--------------
 
;balloons data
BALLONS_Y DB 4 DUP(0,15)
BALLONS_X DB 40,30,60,50,20 
BALLONS_COL DB 8 DUP (0) 
BALLONS_COUNT DB 0
BALLONS_SPEED DB 1 
BALLONS_MAX DB 5
BALLONS_NEW DB 1  
BCOL_SENT   DB ?
GENARR         DB 4,1,4,3,0,4,2,1,4,3,3,0,1,4,2,3,4 
START       DB 17 
;---------------------- 
score1        db 'the score of first player is','$'
score2        db 'the score of second player is','$'
win1        db 'player 1 wins','$'
win2        db 'player 2 wins','$'    
LEVEL       DB  0

.code
main proc far 
    mov ax,@data
    mov ds,ax
     
     call P1Name  ;read name player1
     call initialise 
     begin:   
        call screen2 ; control screen 
     
     
     game:     
      ;change to text mode and draw the base of the game 
       mov ah,0         
      mov al,03h
      int 10h 
      call drawGame
      check1:
       
        call checkCollision 
        call cleanballons
 

        ; move bullet if it exists      
        call controlbullet 
        call checkCollision
        call controlbullet 
        call checkCollision     

        CALL DRAW_BALLONS
    
        call checkbuff
        
        call checkCollision
        
       
        
        call checkscore
        
        call updateScore 
        ; delay to see what has drawn 
        mov dx,0ffffh
        mov cx,2h
        mov ah,86h 
        INT 15h  
         
         
        mov ah,1  ; check for a pressed key
        int 16h 
        jz check1
        
        
        mov ah,0
        int 16h
        
        
        push ax
        ;sending pressed key
        mov dx , 3FDH		; Line Status Register
        AG:In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AG


  		mov dx , 3F8H		; Transmit data register
  		
  		mov  al,ah
  		out dx , al 

        ;check which key is pressed      
        pop ax
        
               
        call keys
          
         
        jmp check1   
        
     quit:
        call quickExit 
        
     hlt
main endp

P1Name proc  
          pusha
    jmp start1 
    ;print error messege of enter a name start with no letter 
    error1:
    mov ah ,2
    mov bh,0
    mov dx,0F1Eh
    int 10h
    mov dx ,offset err
    mov ah,9
    int 21h 
    mov dx,0ffffh
    mov cx,04h
    mov ah,86h 
    INT 15h 
    
    ;take name of player one 
    start1:
    mov ah,0         
    mov al,03h
    int 10h
    mov ah ,2
    mov bh,0
    mov dx,0A1Eh
    int 10h
    mov dx ,offset s1l1
    mov ah,9
    int 21h 
    
    mov ah ,2
    mov bh,0
    mov dx,0D1Eh
    int 10h
    mov dx ,offset s1l3
    mov ah,9
    int 21h 
    
    mov ah ,2  
    mov bh,0
    mov dx,0B25h
    int 10h
    mov dx ,offset nam1
    mov ah,0Ah
    int 21h 
    ; check first letter of name
    cmp nam1[2],64d
    jc error1 
    cmp nam1[2],91d
    jz error1
    cmp nam1[2],92d
    jz error1
    cmp nam1[2],93d
    jz error1
    cmp nam1[2],94d
    jz error1
    cmp nam1[2],95d
    jz error1 
    cmp nam1[2],96d
    jz error1
    cmp nam1[2],123d        
    jnc error1       
     popa
     ret
     
P1Name endp     
         
Screen2 proc 
    pusha 
     mov ah,0         
     mov al,03h
     int 10h 
     ; printing format of control screen 
     mov ah ,2
     mov bh,0
     mov dx,0A1Eh
     int 10h
     mov dx ,offset s2l1
     mov ah,9
     int 21h  
     
     mov ah ,2
     mov bh,0
     mov dx,0B1Eh
     int 10h
     mov dx ,offset s2l2
     mov ah,9
     int 21h
     
     mov ah ,2
     mov bh,0
     mov dx,0C1Eh
     int 10h
     mov dx ,offset s2l3
     mov ah,9
     int 21h 
     
     mov ah ,2
     mov bh,0
     mov dx,1400h
     int 10h
     mov dx ,offset line
     mov ah,9
     int 21h
   
      CHECK:
       mov dx , 3FDH		; Line Status Register
		in al , dx 
  		AND al , 1
  		JnZ CHK
  		
  		mov ah,1
  		int 16h   
        jz CHECK
        push ax
        push ax 
         
         call sendname
         
         AGAIN:
         mov dx , 3FDH		; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN
  		 pop ax   
         mov dx , 3F8H		; Transmit data register
         mov al,ah
         out dx , al 
         
         pop ax
        jmp C
        CHK:
        call getname
        mov dx , 3FDH		; Line Status Register
	 C0:in al , dx 
  		AND al , 1
  		JZ C0
        mov dx , 03F8H
  		in al , dx
  		mov ah,al
        mov dx , 03F8H
  		in al , dx
  		mov ah,al
  		
  		cmp ah,3Bh   ;F1 go to chatting screen 
        jz chattingacc
        cmp ah,3Ch  ;F2 go to game screen 
        jz gameacc 
        
        mov dx , 3FDH
        jmp c0
        
  		C:
  		
        cmp ah ,1    ;ESC  quit of program
        jz quit
        cmp ah,3Bh   ;F1 go to chatting screen 
        jz chatting00
        cmp ah,3Ch  ;F2 go to game screen 
        jz game00 
        mov ah,0      ; any thing else never mind
        int 16h 
       jmp Check         

          
      popa
      ret
      screen2 endp  

chatformat proc
  chatting:
     mov cursors,0100H
     mov cursorr , 0c00h
    
    mov ah,0         
    mov al,03h
    int 10h
    ; printing format of chatting screen 
    mov ah ,2
    mov bh,0
    mov dx,0A00h
    int 10h
    
    mov dx ,offset line
    mov ah,9
    int 21h 
            
    mov ah ,2
    mov bh,0
    mov dx,0000h
    int 10h
    ; print name of first player 
    mov dx ,offset nam1+2
    mov ah,9
    int 21h 
    
    mov ah ,2
    mov bh,0
    mov dx,0B00h
    int 10h
    ; print name of seconed player
    mov dx ,offset nam2+2
    mov ah,9
    int 21h  
    
    mov ah ,2
     mov bh,0
     mov dx,1400h
     int 10h
     mov dx ,offset line
     mov ah,9
     int 21h
     
    ; print notification  
     mov ah ,2
     mov bh,0
     mov dx,1500h
     int 10h
     mov dx ,offset endchat
     mov ah,9
     int 21h
     
      
     mov ah ,2
     mov bh,0
     mov dx,1600h
     int 10h
     mov dx ,offset s2l3
     mov ah,9
     int 21h 
     
     mov ah ,2
     mov bh,0
     mov dx,0c00h
     int 10h
     
     call chatt 
     ret
chatformat endp 

drawGame proc 
    pusha 
     ;move cursor to draw a line at bottom of playing area
     mov ah ,2
     mov bh,0
     mov dx,1300h
     int 10h
     mov dx ,offset line
     mov ah,9
     int 21h
    
     ;line above inline chat
     mov ah ,2
     mov bh,0
     mov dx,1500h
     int 10h
     mov dx ,offset line
     mov ah,9
     int 21h 
     ;line below inline chat
     mov ah ,2
     mov bh,0
     mov dx,1800h
     int 10h
     mov dx ,offset line
     mov ah,9
     int 21h 
     ; move cursor to print notification
     mov ah ,2
     mov bh,0
     mov dx,1900h
     int 10h
     
     mov dx ,offset Egame
     mov ah,9
     int 21h 
     
    
     
     mov dx ,offset nam2+2
     mov ah,9
     int 21h 
     
     mov ah ,2
     mov bh,0
     mov dx,1800h
     add dl,22d
     add dl,nam2+1
     int 10h
     mov dx ,offset Pgame
     mov ah,9
     int 21h
     
     mov ah ,2
    mov bh,0
    mov dx,1400h
    int 10h
    ; print name of first player 
    mov dx ,offset nam1+2
    mov ah,9
    int 21h 
    
    mov ah ,2
    mov bh,0
    mov dx,1500h
    int 10h
    ; print name of seconed player
    mov dx ,offset nam2+2
    mov ah,9
    int 21h 
     
   call drawplayer1
   call drawplayer2
    
    popa
    ret
drawGame endp 

upmove1 proc 
    pusha
    mov bx ,offset p1y
        mov cx,15
        inc2:dec [bx]
        add bx,1
        loop inc2
        
        popa  
        ret
        upmove1 endp
downmove1 proc
    pusha
    mov bx ,offset p1y
        dec2:inc [bx]
        add bx,1
        loop dec2 
        popa
        ret
        downmove1 endp
upmove2 proc 
    pusha
    mov bx ,offset p2y
        mov cx,15
        inc1:dec [bx]
        add bx,1
        loop inc1
        
        popa  
        ret
        upmove2 endp
downmove2 proc
    pusha
    mov bx ,offset p2y
        dec1:inc [bx]
        add bx,1
        loop dec1 
        popa
        ret
        downmove2 endp
drawplayer1 proc
    pusha 
    mov si ,offset p1x
    mov di ,offset p1y  
    mov bp,15  
 drawE1:
    
    mov ah,2          
    mov dl,[si]
    mov dh,[di]      
    int 10h    
    mov ah,9          
    mov bh,0          
    mov al,62d       
    mov cx,1         
    mov bl,0Ah        
    int 10h
    inc si
    inc di   
    dec bp
    jnz drawE1

      popa
     ret
drawplayer1 endp

deleteplayer1 proc 
    pusha
    
    mov dh ,0  
    mov bp,11h
    
 delE1:
    mov dl,0
    mov ah,2               
    int 10h 
       
    mov ah,9          
    mov bh,0          
    mov al,' '       
    mov cx,5         
    mov bl,00h        
    int 10h
    inc dh   
    dec bp
    jnz delE1 
    popa
     ret
deleteplayer1 endp

drawplayer2 proc 
  pusha      
 mov si ,offset p2x
    mov di ,offset p2y  
    mov bp,15d 
    
 drawE2:
 
    mov ah,2          
    mov dl,[si]
    mov dh,[di]      
    int 10h    
    mov ah,9          
    mov bh,0          
    mov al,60d        
    mov cx,1         
    mov bl,09h        
    int 10h
    inc si
    inc di   
    dec bp
jnz drawE2
popa  
     ret
    drawplayer2 endp
deleteplayer2 proc
    pusha
    mov si ,offset p2x
    mov di ,offset p2y  
    mov bp,15d 
    
 delE2:
 
    mov ah,2          
    mov dl,[si]
    mov dh,[di]      
    int 10h    
    mov ah,9          
    mov bh,0          
    mov al,60d        
    mov cx,1         
    mov bl,00h        
    int 10h
    inc si
    inc di   
    dec bp
jnz delE2 
popa
      ret
    deleteplayer2 endp
;-----------------------------------------------
BulletMain_1                PROC 
CALL RemoveFBulletChar_1            ;removing previous bullet to draw the new one

cmp BulletDoubleSpeed_1,0           ;checking if the double speed power up is enabled
jnz DoubleSpeed_1
jz  NormalSpeed_1 

NormalSpeed_1:
add BulletPosX_1,1     ;if it is not enabled increase the Bullet`s X pos by 1

jmp ContDrawBullet_1                 
DoubleSpeed_1:        ;if it is  enabled increase the Bullet`s X pos by 2
add BulletPosX_1,1          
CALL CheckNextChar_1
add BulletPosX_1,1          
CALL CheckNextChar_1
jmp ContDrawBullet_1 

ContDrawBullet_1:
CALL DrawBullet_1                    ;draw the bullet
CALL CheckNextChar_1
 
                       RET
BulletMain_1                ENDP    

;-----------------------------------------------
BulletMain_2                PROC 
CALL RemoveFBulletChar_2            ;removing previous bullet to draw the new one

cmp BulletDoubleSpeed_2,0           ;checking if the double speed power up is enabled
jnz DoubleSpeed_2
jz  NormalSpeed_2 

NormalSpeed_2:sub BulletPosX_2,1     ;if it is not enabled decrease the Bullet`s X pos by 1
jmp ContDrawBullet_2                 
DoubleSpeed_2:         ;if it is  enabled decrease the Bullet`s X pos by 2
sub BulletPosX_2,1    
CALL CheckNextChar_2
sub BulletPosX_2,1     
CALL CheckNextChar_2
jmp ContDrawBullet_2 

ContDrawBullet_2:
CALL DrawBullet_2                     ;draw the bullet
CALL CheckNextChar_2                  ;check if there is an obstacle
 
          
  
                           RET
BulletMain_2                ENDP  
;-------------------------------------------------
;the proc does the following conditions -> ( Player can shoot AND There isnt a bullet){Generate a bullet}
;if the bullet should be generated bl=1,else bl=0
CheckGenBullet_1         PROC
                                                                        
cmp PlayerCantShoot_1,0                   
jnz  DontAllowGenBullet_1                
                                         
cmp  BulletPosX_1,0                       
jz   AllowGenBullet_1
jnz  DontAllowGenBullet_1

AllowGenBullet_1:mov bl,1
jmp ExitCheckGenBullet_1

DontAllowGenBullet_1:mov bl,0
jmp ExitCheckGenBullet_1

ExitCheckGenBullet_1:
                        RET                          
CheckGenBullet_1        ENDP
;-------------------------------------------------  

;-------------------------------------------------
;the proc does the following conditions -> ( Player can shoot AND There isnt a bullet){Generate a bullet}
;if the bullet should be generated bl=1,else bl=0
CheckGenBullet_2         PROC
                                                                        
cmp PlayerCantShoot_2,0                   
jnz  DontAllowGenBullet_2                
                                         
cmp  BulletPosX_2,0                       
jz   AllowGenBullet_2
jnz  DontAllowGenBullet_2

AllowGenBullet_2:mov bl,1
jmp ExitCheckGenBullet_2

DontAllowGenBullet_2:mov bl,0
jmp ExitCheckGenBullet_2

ExitCheckGenBullet_2:
                        RET                          
CheckGenBullet_2        ENDP
;-------------------------------------------------  
;this procedure draws a bullet at (BulletPosX_1,BulletPosY_1)
DrawBullet_1                PROC 

cmp BulletPosY_1,0
jz eliminateerror
jnz conttDrawBullet_1
eliminateerror:
mov BulletPosx_1,0
jmp exitDrawBullet_1         

conttDrawBullet_1: 
push ds
pop es
mov bp, offset Bullet_1 
mov al, 1
mov bh, 0
mov bl, 0000_1010b       ;bullet color
mov cx, 1                ; calculate message size. 
mov dl,BulletPosX_1       ;X position
mov dh,BulletPosY_1       ;Y position
mov ah, 13h
int 10h    
exitDrawBullet_1:          
  
                            RET
DrawBullet_1                ENDP   

;--------------------------------------------------  
;-------------------------------------------------  
;this procedure draws a bullet at (BulletPosX_2,Bullet1PosY_2)
DrawBullet_2                PROC 
 
push ds
pop es
mov bp, offset Bullet_2 
mov al, 1
mov bh, 0
mov bl, 0000_1001b       ;bullet color
mov cx, 1                ; calculate message size. 
mov dl,BulletPosX_2       ;X position
mov dh,BulletPosY_2       ;Y position
mov ah, 13h
int 10h    
          
  
                            RET
DrawBullet_2                ENDP   

;--------------------------------------------------  


;-------------------------------------------------  
;Must Be called before DrawBullet_1 
;it removes the previous bullet to prepare for the next bullet to be drawn
RemoveFBulletChar_1                PROC 
mov ah,2 
mov dl,BulletPosX_1  
mov dh,BulletPosY_1 
int 10h 

mov ah,2 
mov dl,' ' 
int 21h         
  
                                  RET
RemoveFBulletChar_1                ENDP    

;--------------------------------------------------

;-------------------------------------------------  
;Must Be called before DrawBullet_2 
;it removes the previous bullet to prepare for the next bullet to be drawn
RemoveFBulletChar_2                PROC 
mov ah,2 
mov dl,BulletPosX_2  
mov dh,BulletPosY_2 
int 10h 

mov ah,2 
mov dl,' ' 
int 21h         
  
                                  RET
RemoveFBulletChar_2                ENDP    

;--------------------------------------------------

;-------------------------------------------------  
;checks if the next place the bullet hits is a ballon or not
;it return bl=0 for Empty obstacle
;it return bl=1 for normal ballon
;it return bl=2 for powerup1 ballon
;it return bl=3 for powerup2 ballon
;it return bl=4 for powerup3 ballon 
;it return bl=5 for wall 

CheckNextChar_1                PROC 

mov ah,2 
mov dl,BulletPosX_1[0]      ;moving cursor to next position of bullet
add dl,1  
mov dh,BulletPosY_1
int 10h

mov ah,8h                   ;comparing next position to character of ballons
mov bh,0
INT 10h

mov cx,ax

mov ah,2 
mov dl,BulletPosX_1      ;moving cursor to same position of bullet
mov dh,BulletPosY_1
int 10h

mov ah,8h                   ;comparing character of bullet position to character of ballons
mov bh,0
INT 10h

                           
cmp al , 4d
mov bl,BulletPosX_1                ;if balloon is in the same position of bullet
jz  checkBallonColor_1             ; check its color
cmp cl,4d
mov bl,BulletPosX_1
inc bl 
mov ah,ch                          ;if balloon is in the next position of bullet
jz checkballoncolor_1              ;check its color
jnz NotBallon_1               

checkBallonColor_1:  
mov al,bl
Call Del_By_x 
cmp ah,0Fh                   
jz NormalBallon_1
cmp ah,2 
jz Powerup1_1
cmp ah,3 
jz Powerup2_1
cmp ah,0Eh 
jz Powerup3_1
cmp ah,0Ch 
jz Powerup4_1


jmp ExitCheckNextChar_1
      
;normal ballon  (blue)               
NormalBallon_1: mov bl,1

CALL DeleteBullet_1            ;if it hits a ballon delete the bullet
CALL IncreasePlayerScore_1     ;increase player 1 score by 1 or 2 (if the double score power up is enabled)                  
CALL DecrementPowerUps_1        ;decrement the points of powerups
jmp ExitCheckNextChar_1

;power up 1    (green) (Double speed)              
Powerup1_1: mov bl,2        

CALL DeleteBullet_1        ;if it hits a wall delete the bullet
CALL DecrementPowerUps_1         ;decrement the points of powerups
mov BulletDoubleSpeed_1,3      ;enabled for next 3 bullets              
jmp ExitCheckNextChar_1

;power up 2    (cyan)  (Cant shoot)              
Powerup2_1: mov bl,3

CALL DeleteBullet_1        ;if it hits a wall delete the bullet
CALL DecrementPowerUps_1       ;decrement the points of powerups
mov PlayerCantShoot_2 , 3     ;enabled for next 10 iterations           
jmp ExitCheckNextChar_1

;power up 3    (yellow)   (Double Points)           
Powerup3_1: mov bl,4 

CALL DeleteBullet_1        ;if it hits a wall delete the bullet
CALL DecrementPowerUps_1          ;decrement the points of powerups
mov PlayerDoublePoints_1 , 3     ;enabled for next 3 bullets             
jmp ExitCheckNextChar_1

Powerup4_1: mov bl,5
CALL DeleteBullet_1        ;if it hits a wall delete the bullet
CALL DecrementPowerUps_1          ;decrement the points of powerups
CALL DecreasePlayerScore_1             
jmp ExitCheckNextChar_1

 
NotBallon_1:

    EmptyObstacle_1:mov bl,0    ;not a ballon
    cmp BulletPosX_1 , 74       ;todo change the limiit of bullet 2
    JGE Bullet1HitsLimit_1
    JLE ExitCheckNextChar_1 
    Bullet1HitsLimit_1:
    CALL DecrementPowerUps_1
    CALL DeleteBullet_1        ;Bullet1 is at its limit in its range
    jmp ExitCheckNextChar_1                      
              

ExitCheckNextChar_1: 
                             RET
CheckNextChar_1                ENDP    

;--------------------------------------------------


;-------------------------------------------------  
;checks if the next place the bullet hits is a ballon or not
;it return bl=0 for Empty obstacle
;it return bl=1 for normal ballon
;it return bl=2 for powerup1 ballon
;it return bl=3 for powerup2 ballon
;it return bl=4 for powerup3 ballon 
;it return bl=5 for wall 

CheckNextChar_2                PROC 


mov ah,2 
mov dl,BulletPosX_2[0]      ;moving cursor to next position of bullet
sub dl,1  
mov dh,BulletPosY_2
int 10h


mov ah,8h                   ;comparing the character of next position to character of ballons
mov bh,0
INT 10h

mov cx,ax

mov ah,2 
mov dl,BulletPosX_2      ;moving cursor to  position of bullet
mov dh,BulletPosY_2
int 10h

mov ah,8h                   ;comparing character of same bullet position to character of ballons
mov bh,0
INT 10h


                            
cmp al , 4d                ;checking if same character of bullet is a ballon or not
mov bl,BulletPosX_2               
jz  checkBallonColor_2        
cmp cl,4d                  ;checking if next character of bullet is a ballon or not
mov bl,BulletPosX_2
dec bl 
mov ah,ch
jz checkballoncolor_2
jnz NotBallon_2               

checkBallonColor_2:        ;checking ballon color 
mov al,bl
call Del_by_x 
cmp ah,0Fh                 ;white ballon (normal ballon)   
jz NormalBallon_2
cmp ah,2                   ;green ballon (double speed)
jz Powerup1_2
cmp ah,3                   ;cyan ballon (other player cant shoot)
jz Powerup2_2
cmp ah,0Eh                 ;yellow ballon (double points)
jz Powerup3_2
cmp ah,0Ch 
jz Powerup4_2

jmp ExitCheckNextChar_2
      
;normal ballon  (blue)               
NormalBallon_2: mov bl,1

CALL DeleteBullet_2            ;if it hits a ballon delete the bullet
CALL IncreasePlayerScore_2     ;increase player 2 score by 1 or 2 (if the double score power up is enabled)                  
CALL DecrementPowerUps_2        ;decrement the points of powerups
jmp ExitCheckNextChar_2

;power up 1    (green) (Double speed)              
Powerup1_2: mov bl,2        

CALL DeleteBullet_2        ;if it hits a ballon delete the bullet
CALL DecrementPowerUps_2         ;decrement the points of powerups
mov BulletDoubleSpeed_2,3      ;enabled for next 3 bullets              
jmp ExitCheckNextChar_2

;power up 2    (cyan)  (Cant shoot)              
Powerup2_2: mov bl,3

CALL DeleteBullet_2        ;if it hits a ballon delete the bullet
CALL DecrementPowerUps_2       ;decrement the points of powerups
mov PlayerCantShoot_1 , 3     ;enabled for next 3 bullets           
jmp ExitCheckNextChar_2

;power up 3    (yellow)   (Double Points)           
Powerup3_2: mov bl,4 

CALL DeleteBullet_2        ;if it hits a wall delete the bullet
CALL DecrementPowerUps_2          ;decrement the points of powerups
mov PlayerDoublePoints_2 , 3     ;enabled for next 3 bullets             
jmp ExitCheckNextChar_2  

Powerup4_2: mov bl,5
CALL DeleteBullet_2        ;if it hits a wall delete the bullet
CALL DecrementPowerUps_2          ;decrement the points of powerups
CALL DecreasePlayerScore_2             
jmp ExitCheckNextChar_2


 
NotBallon_2:

    EmptyObstacle_2:mov bl,0    ;not a ballon
    cmp BulletPosX_2 , 5       ;todo change the limiit of bullet 2
    JLE Bullet1HitsLimit_2
    JGE ExitCheckNextChar_2 
    Bullet1HitsLimit_2:
    CALL DecrementPowerUps_2 
    CALL DeleteBullet_2        ;Bullet1 is at its limit in its range
    jmp ExitCheckNextChar_2                      
              

ExitCheckNextChar_2: 
                               RET
CheckNextChar_2                ENDP    

;--------------------------------------------------

;-------------------------------------------------  
;this method deletes player 1 bullet 
;it should be called after the bullet hits an obstacle 
DeleteBullet_1                PROC 

CALL RemoveFBulletChar_1
mov  BulletPosX_1,0
mov  BulletPosY_1,0

                             RET
DeleteBullet_1                ENDP    

;-------------------------------------------------- 

;-------------------------------------------------  
;this method deletes player 2 bullet 
;it should be called after the bullet hits an obstacle 
DeleteBullet_2                PROC 

CALL RemoveFBulletChar_2
mov  BulletPosX_2,0
mov  BulletPosY_2,0

                              RET
DeleteBullet_2                ENDP    

;-------------------------------------------------- 
 
 
;-------------------------------------------------  
;increases player1 score by 1  or 2 (if the double score power up is enabled)
IncreasePlayerScore_1                PROC 

cmp PlayerDoublePoints_1,0          ;checking if powerup is enabled
jz  OnePoint_1
jnz TwoPoints_1

OnePoint_1:                            ;if it is not enabled
inc point1[1]                   ;increase player 1 score by 1
jmp ExitIncreasePlayerScore_1

TwoPoints_1:                            ;if it enabled
add point1[1],2                  ;increase player 1 score by 2  
jmp ExitIncreasePlayerScore_1

ExitIncreasePlayerScore_1:

                                    RET
IncreasePlayerScore_1                ENDP    

;-------------------------------------------------  
;increases player2 score by 1  or 2 (if the double score power up is enabled)
IncreasePlayerScore_2                PROC 

cmp PlayerDoublePoints_2,0          ;checking if powerup is enabled
jz  OnePoint_2
jnz TwoPoints_2

OnePoint_2:                            ;if it is not enabled
inc point2[1]                   ;increase player 2 score by 1
jmp ExitIncreasePlayerScore_2

TwoPoints_2:                            ;if it enabled
add point2[1],2               ;increase player 2 score by 2  
jmp ExitIncreasePlayerScore_2

ExitIncreasePlayerScore_2:

                                    RET
IncreasePlayerScore_2                ENDP    

;--------------------------------------------------
                
                                                                    
                                                    ;-------------------------------------------------  
;increases player1 score by 1  or 2 (if the double score power up is enabled)
DecreasePlayerScore_1                PROC 

cmp point1[1],'0'          
jz  ExitDecreasePlayerScore_1

sub point1[1],1

ExitDecreasePlayerScore_1:

                                    RET
DecreasePlayerScore_1                ENDP    

;-------------------------------------------------  
 ;-------------------------------------------------  
;increases player1 score by 1  or 2 (if the double score power up is enabled)
DecreasePlayerScore_2                PROC 

cmp point2[1],'0'        
jz  ExitDecreasePlayerScore_2

sub point2[1],1

ExitDecreasePlayerScore_2:

                                    RET
DecreasePlayerScore_2               ENDP    

;--------------------------------------------------


;--------------------------------------------------
;-------------------------------------------------  
;it decreases the number of remaining power up
;should be used when a bullet hit an obstacle
DecrementPowerUps_1                    PROC 
cmp BulletDoubleSpeed_1,0
jnz decrementDoubleSpeed_1               ;if BulletDoubleSpeed_1>0 decrement it
jz  checkDoublePoints_1
decrementDoubleSpeed_1:dec BulletDoubleSpeed_1 
jmp checkDoublePoints_1

checkDoublePoints_1:
cmp PlayerDoublePoints_1,0
jnz decrementDoublePoints_1              ;if PlayerDoublePoints_1>0 decrement it
jz  checkPlayerCantShoot_2
decrementDoublePoints_1:dec PlayerDoublePoints_1 
jmp checkPlayerCantShoot_2

checkPlayerCantShoot_2:
cmp PlayerCantShoot_2,0
jnz decrementPlayerCantShoot_2              ;if playercantshoot_1>0 decrement it
jz  ExitDecrementPowerUps_1
decrementPlayerCantShoot_2:dec PlayerCantShoot_2 
jmp ExitDecrementPowerUps_1


ExitDecrementPowerUps_1: 
                                     RET
DecrementPowerUps_1                    ENDP    

;--------------------------------------------------
;--------------------------------------------------
;-------------------------------------------------  
;it decreases the number of remaining power up
;should be used when a bullet hit an obstacle
DecrementPowerUps_2                    PROC 
cmp BulletDoubleSpeed_2,0
jnz decrementDoubleSpeed_2               ;if BulletDoubleSpeed_2>0 decrement it
jz  checkDoublePoints_2
decrementDoubleSpeed_2:dec BulletDoubleSpeed_2 
jmp checkDoublePoints_2

checkDoublePoints_2:
cmp PlayerDoublePoints_2,0
jnz decrementDoublePoints_2              ;if PlayerDoublePoints_2>0 decrement it
jz  checkPlayerCantShoot_1
decrementDoublePoints_2:dec PlayerDoublePoints_2 
jmp checkPlayerCantShoot_1

checkPlayerCantShoot_1:
cmp PlayerCantShoot_1,0
jnz decrementPlayerCantShoot_1              ;if PlayerCantShoot_1>0 decrement it
jz  ExitDecrementPowerUps_2
decrementPlayerCantShoot_1:dec PlayerCantShoot_1 
jmp ExitDecrementPowerUps_2


ExitDecrementPowerUps_2: 
                                     RET
DecrementPowerUps_2                    ENDP    

;--------------------------------------------------
    
    ; check any key pressed during playing  
keys proc 
            
        
        
        cmp ah,48h
        jnz downP2
        
        ;check if reached the down limit of screen
        cmp p1y[0],0
        jz exitkeys
        call deleteplayer1
        call upmove1 
        call drawplayer1
        jmp exitkeys
        ; check for a down arrow pressed
        downP2:
        mov cx, 15
        cmp ah,50h
        jnz exit
        
        ;check if reached the down limit of screen
        cmp p1y[13],10h
        jz exitkeys  
        call deleteplayer1
        call downmove1 
        call drawplayer1
        jmp exitkeys
         
        ; check for a F4 pressed
        exit:
        cmp ah,3Eh
        jz quit
        
        cmp ah,3Fh ; check if pause
        jz  pause  
        
        ;Nasar
   StartBullet:

    cmp ah,39h              ;if space is pressed check if the first bullet should be generated                 
    jz  BeforeGenBullet_1
    jnz exitkeys                



    BeforeGenBullet_1:
        CALL CheckGenBullet_1    ;check if player can shoot and if there isnt a bullet
        cmp bl,1
        jz GenBullet_1           ;generate bullet if the above condition is true
        jnz exitkeys

    BeforeGenBullet_2:
        CALL CheckGenBullet_2    ;check if player can shoot and if there isnt a bullet
        cmp bl,1
        jz GenBullet_2           ;generate a bullet if the above condition is true
        jnz out1 



    GenBullet_1:
        mov BulletPosX_1,7d      ;Generating bullet at (7,player1 Y position)
        mov dl,p1y[9]
        mov BulletPosY_1,dl      
        jmp exitkeys

    GenBullet_2:
        mov BulletPosX_2,71d      ;Generating bullet at (71,player2 Y position)
        mov dl,p2y[9]
        mov BulletPosY_2,dl      
        jmp out1    
    
    
     
     
     upP1:
        mov cx, 15d 
        ;check if reached the upper limit of screen
        cmp p2y[0],0
        jz back
        call deleteplayer2
        call upmove2
        call drawplayer2
        jmp out1
        
        downP1:; check for a page down pressed
        mov cx, 15d 
        ;check if reached the down limit of screen
        cmp p2y[13],10h
        jz back 
        call deleteplayer2
        call downmove2
        call drawplayer2
        jmp out1
        
      exitkeys:
        ret
    
keys endp


     
controlbullet proc
     
    CheckExistingBullet_1:
        cmp BulletPosX_1,0       ;checking if bullet_1 exists or not
        jz CheckExistingBullet_2
        jnz StartBullet1Main_1

    StartBullet1Main_1:      ;if bullet_1 exists move it to the right and check if there is an obstacle
        CALL BulletMain_1

    CheckExistingBullet_2:
        cmp BulletPosX_2,0      ;checking if bullet_2 exists or not
        jz outlable
        jnz StartBulletMain_2

    StartBulletMain_2:       ;if bullet_2 exists move it to the right and check if there is an obstacle
        CALL BulletMain_2 
    
    outlable: 
    ret
controlbullet endp    
;-------------------------------------------

DRAW_BALLONS PROC
    PUSHA    
call gen_col
;;;;;;;;;;;BLOCK 2;;;;;;;;;;;;
;DRAW BALLONS     
DRAW:    
    MOV SI,0
DRAW1:    
     MOV BL,BALLONS_MAX            ;loop on all ballons to draw them
     MOV BH,0 
     CMP SI,BX                     ;draw ballons with even index (moving down ballons)
    JZ EXITT 
    MOV BL,BALLONS_COL[SI]         ;mov ballons color to bl
    CMP BL,0 
    JZ DRAW2
    MOV DL,BALLONS_X[SI]           ;mov x coordinate to dl 
    MOV DH,BALLONS_Y[SI]           ;mov y coordinate to dh
    ADD DH,BALLONS_SPEED           ;add speed to it y position to make move down
    MOV BALLONS_Y[SI],DH
    PUSH CX
    MOV CL,15                      ;check if it reached the screen's lower border in order to delete it if it leaves the game
    CMP BALLONS_Y[SI],CL           
    POP CX
    JB D                           ;if it reached the border call delete by index o delete the ballon with index in SI
    CALL DEL_BY_INDEX
    JMP DRAW2
D:  CALL DRAW_BALLON               ;call draw ballon to draw ballon with index si in its position with its color
DRAW2:                             
    INC SI
     MOV BL,BALLONS_MAX            ;draw ballons with odd index (moving up ballons)
     MOV BH,0 
     CMP SI,BX
    JZ EXITT 
    MOV BL,BALLONS_COL[SI]         ;mov ballons color to bl
    CMP BL,0
    JZ DRAW3
    MOV DL,BALLONS_X[SI]           ;mov x coordinate to dl 
    MOV DH,BALLONS_Y[SI]           ;mov y coordinate to dh
    SUB DH,BALLONS_SPEED           ;subtract speed to it y position to make move up
    MOV BALLONS_Y[SI],DH
    PUSH CX 
    MOV CL,0                       ;check if it reached the screen's upper border in order to delete it if it leaves the game
    CMP BALLONS_Y[SI],CL 
    POP CX
    JG D2
    CALL DEL_BY_INDEX              ;if it reached the border call delete by index o delete the ballon with index in SI
    JMP DRAW3                      
D2:  CALL DRAW_BALLON              ;call draw ballon to draw ballon with index si in its position with its color 
                                   
DRAW3: 
    INC SI
    JMP DRAW1    
     
    
EXITT:       
    POPA
        
    RET
DRAW_BALLONS ENDP    

PROC GEN_COL
     MOV AL,BALLONS_COUNT
     CMP AL,BALLONS_MAX  
     JZ EXIT_TO_DRAW       
     
NEWB:
     
     MOV CL,BALLONS_NEW
     MOV CH,0
  
     
GEN:
    MOV DI,0 
   
GEN1:
    PUSH CX
    CALL RANDGEN         ;returns the random number in dl from 0 to 9
    POP CX               ;by checking this random number a random color is generated
    CMP DL,0             
    JNZ N_ZERO
                         ;if zero mov cyan to bl
    MOV BL,3
    JMP COL_DETERMINED
N_ZERO:
    CMP DL,1
    JNZ N_ONE            
                         ;if one mov green to Bl
    MOV BL,2
    JMP COL_DETERMINED
N_ONE:
    CMP DL,2
    JNZ N_TWO
                         ;if two mov yellow to BL
    MOV BL,0EH
    JMP COL_DETERMINED 
N_TWO:
    MOV AL,LEVEL
    CMP AL,1
    JNZ N_LEVEL2
    CMP DL,3
    MOV BL,0CH
    JZ COL_DETERMINED
   
N_LEVEL2:                 
                        ;if non of the above mov white to BL this makes the odds to generate
     MOV BL,0FH          ;an ordinary ballon (white) higher than power ups (other colors)
      
COL_DETERMINED: 
    ;search for a zero element in BALLONS_COL (not drawn) 
     MOV AL,BALLONS_COL[DI]
     CMP AL,0
     JZ CHANGE_COL 
     INC DI
     PUSH BX
     MOV BL,BALLONS_MAX
     MOV BH,0 
     CMP DI,BX
     POP BX
     JNZ COL_DETERMINED
     JMP EXIT_TO_DRAW
CHANGE_COL:
    PUSH CX
    MOV CX,DI
   
    POP CX
                           ;a zero element in ballons_col has been determined and its index is stored in DI
    MOV OFFSET BALLONS_COL[DI],BL ;the randomly generated color stored in bl is moved into ballons_cl[di] for the ballon to be drawn with it latter
    MOV AL,BALLONS_COUNT 
    INC AL                        ;increase ballons count
    MOV BALLONS_COUNT,AL
    LOOP GEN1        
EXIT_TO_DRAW:
    RET      
GEN_COL ENDP
  


; generate a rand no from 0 to 9 using the system time
RANDGEN proc        

;RANDSTART:
;   MOV AH, 00h  ; interrupts to get system time        
;   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
;
;   mov  ax, dx
;   xor  dx, dx
;   mov  cx, 10    
;   div  cx       ; here dx contains the remainder of the division - from 0 to 9
  
 MOV CL,START
CMP CL,17   
JNZ NO_17
MOV DL,0FFH
MOV START,DL
NO_17:
MOV DL,START
INC DL
MOV START,DL
MOV BL,DL
JMP EX_RANDGEN

 
EX_RANDGEN: 
MOV START ,BL
MOV BH,0
MOV DL,GENARR[BX]         


   
RET ; here dx contains the remainder of the division - from 0 to 9
   
RET    

RANDGEN  ENDP 

DRAW_BALLON     PROC

    mov ah,2 ;move curser position 
    mov bh,0  
    dec dl
    int 10h
    
    mov ah,9   ;draw one char
   
    mov al,4   ;char ascii
    mov cx,3
    int 10h
   
    
    ;sub dl,1h  ;change curser position
    add dh,1h
    
    mov ah,2    ;move curser position
    int 10h
    
    mov ah,9    ;draw 3 chars
    mov cx,3
    int 10h        
            
    
   ; add dl,1h
    add dh,1h
    
    mov ah,2     ;move curser position
    int 10h
    
     mov ah,9    ;draw one char
    mov cx,3
    int 10h 
    
     RET
          
DRAW_BALLON     ENDP

DEL_BY_INDEX  PROC    ;DELETE A BALLON WITH INDEX STORED IN SI
    PUSHA
    
    MOV AL,0
    MOV BALLONS_COL[SI],AL  ;MOV 0 TO THE COLOR ARRAY TO INDICATE THAT THERE IS NO BALLON DRAWN IN THAT POSITION
    MOV AX,1                ;SEE IF SI EVEN OR ODD
    AND AX,SI              
                           
    CMP AX,0
    JNZ ODD 
    MOV AL,0                ;IF EVEN SET Y TO 0
    MOV BALLONS_Y[SI],AL
    JMP R
ODD:
    MOV AL,15               ;IF ODD SET Y TO MAX 15
    MOV BALLONS_Y[SI],AL
        
    
R:  MOV AL,BALLONS_COUNT
    DEC AL
    MOV BALLONS_COUNT,AL 
    POPA  
    RET
DEL_BY_INDEX  ENDP

DEL_BY_X  PROC  ;TAKES X IN AL
    PUSHA       
                ;IN THIS PROC WE LOOP ON BALLONS TO KNOW WHICH ONE THE X IN BL BELONGS TO IN ORDER TO BE DELETED 
                ;BALLONS ARE DIAMOND SHAPED SO EACH BALLON OCCUPIES THREE X VALUES MIDDLE ONES ARE STORED IN BALLONS_X ARRAY
                ;ONCE THE BALLON IS FOUND IT IS DELETED USING ITS INDEX
    ;LOOP ON MIDDLE VALUES

    MOV BX,0  
DE1:    
    CMP BL,BALLONS_MAX
    JZ DEL2 
    CMP AL,BALLONS_X[BX]
    JZ DELETE
    INC BL
    JMP DE1
        
DEL2: ;LOOP ON LEFT VALUES
    MOV BX,0   
DE2:
    CMP BL,BALLONS_MAX
    JZ DEL3
    MOV CL,BALLONS_X[BX]
    DEC CL 
    CMP CL,AL
    JZ DELETE
    INC BL
    JMP DE2
    
DEL3:;LOOP ON RIGHT VALUES
    MOV BX,0
DE3:
    CMP BL,BALLONS_MAX
    JZ  EX1 
    MOV CL,BALLONS_X[BX]
    INC CL 
    CMP CL,AL
    JZ DELETE
    INC BL
    JMP DE3
            
    
DELETE:
    MOV SI,BX
    CALL DEL_BY_INDEX
EX1:        
    POPA
    RET
DEL_BY_X  ENDP 


cleanballons proc
           mov dx,0013h 
        l:                
          mov dl,13h
        l2:
        mov ah,2 
        int 10h
        mov ah,9          ;Display
        mov bh,0          ;Page 0
        mov al,' '        ;Letter ' '
        mov cx,1         ;1 times
        mov bl,00h        
        int 10h 
        inc dx
        cmp dl,63d 
        jnz l2
        inc dh
        cmp dh,11h
        jnz l
        
        
    mov ah,2          
    mov dl,p2x[14]
    mov dh,p2y[14]      
    int 10h    
    mov ah,9          
    mov bh,0          
    mov al,60d       
    mov cx,1         
    mov bl,09h        
    int 10h
    
    
     ret
    
    
cleanballons  endp 

updateScore proc
    
    
    ; print names and scores of 2 players  
     mov ah ,2
     mov bh,0
     mov dx,1202h
     int 10h
     mov dx ,offset nam1+2
     mov ah,9
     int 21h 
     
     mov ah ,2
     mov bh,0
     mov dx,1202h
     add dl,nam1+1
     int 10h
     mov dx ,offset point1
     mov ah,9
     int 21h
     
     mov ah ,2
     mov bh,0
     mov dx,1235h
     int 10h
     mov dx ,offset nam2+2
     mov ah,9
     int 21h
     
     mov ah ,2
     mov bh,0
     mov dx,1235h
     add dl,nam2+1
     int 10h 
     mov dx ,offset point2
     mov ah,9
     int 21h
     ret 
    
updateScore endp

checkscore proc 

                    
                cmp point1[1],'9'
                jnc endgame1      ;if  player 1 win jumb
                cmp point2[1],'9' 
                jnc endgame2      ; if player to win jumb
                jmp outing
endgame1:       
                mov ah,0
                mov al,03h
                int 10h          ; create new window
                mov ah ,2
                mov bh,0
                mov dx,051Eh     ; move  cursor
                int 10h               
                mov dx ,offset win1 
                mov ah,9
                int 21h          ;write the winner
                ;delay 
                mov dx,4B40h
                mov cx,04Ch
                mov ah,86h 
                INT 15h
                call reset                

endgame2:      
                mov ah,0
                mov al,03h
                int 10h         ; create new window
                mov ah ,2
                mov bh,0
                mov dx,051Eh
                int 10h         ; move  cursor  
                
                mov dx ,offset win2
                mov ah,9
                int 21h         ;write the winner 
                ;delay 
                mov dx,4B40h
                mov cx,04Ch
                mov ah,86h 
                INT 15h
                call reset    
                
                outing:
                ret
                
checkscore endp

reset proc 
      mov bx,14d
      
      
     mov level,0
     ;reser players score       
     mov point1[1],'0'     
     mov point2[1],'0'        
     
     ;reset players position
     mov p1y[0],9       
     mov p1y[1],9
     mov p1y[2],0Ah
     mov p1y[3],0Ah
     mov p1y[4],0Ah
     mov p1y[5],0Bh
     mov p1y[6],0Bh
     mov p1y[7],0Bh
     mov p1y[8],0Bh
     mov p1y[9],0Bh
     mov p1y[10],0Ch
     mov p1y[11],0Ch
     mov p1y[12],0Ch
     mov p1y[13],0Dh
     mov p1y[14],0Dh
     
     
     ;------------
     mov p2y[0],9       
     mov p2y[1],9
     mov p2y[2],0Ah
     mov p2y[3],0Ah
     mov p2y[4],0Ah
     mov p2y[5],0Bh
     mov p2y[6],0Bh
     mov p2y[7],0Bh
     mov p2y[8],0Bh
     mov p2y[9],0Bh
     mov p2y[10],0Ch
     mov p2y[11],0Ch
     mov p2y[12],0Ch
     mov p2y[13],0Dh
     mov p2y[14],0Dh
      
     ;-----------------
     
     mov p1x[0],0       
     mov p1x[1],1
     mov p1x[2],0
     mov p1x[3],1
     mov p1x[4],2
     mov p1x[5],0
     mov p1x[6],1
     mov p1x[7],2
     mov p1x[8],3
     mov p1x[9],4
     mov p1x[10],0
     mov p1x[11],1
     mov p1x[12],2
     mov p1x[13],0
     mov p1x[14],1
      
     
     ;------------
     mov p2x[0],79       
     mov p2x[1],78
     mov p2x[2],79
     mov p2x[3],78 
     mov p2x[4],77
     mov p2x[5],79
     mov p2x[6],78
     mov p2x[7],77
     mov p2x[8],76
     mov p2x[9],75
     mov p2x[10],79
     mov p2x[11],78
     mov p2x[12],77
     mov p2x[13],79
     mov p2x[14],78
     
     ;------------------------
     ; reset bullets data
   ;  mov BulletStartingXPos_1,15 
     mov BulletPosX_1,0 
     mov BulletPosY_1,0
     mov BulletDoubleSpeed_1,0
     mov PlayerCantShoot_2 ,0
     mov PlayerDoublePoints_1,0
      
    ; mov BulletStartingXPos_2,15 
     mov BulletPosX_2,0 
     mov BulletPosY_2,0
     mov BulletDoubleSpeed_2,0
     mov PlayerCantShoot_1 ,0
     mov PlayerDoublePoints_2,0 
     
     
     ; reset ballons 
     mov BALLONS_MAX,5
     mov BALLONS_NEW,1
     mov BALLONS_SPEED,1
     mov BALLONS_COUNT,0 
     
        mov bx,0
    lab: 
     mov BALLONS_COL [bx],0
     inc bx
     cmp bx,8
     jnz lab
     
     mov BALLONS_X[0] ,20
     mov BALLONS_X[1] ,30
     mov BALLONS_X[2] ,40
     mov BALLONS_X[3] ,50
     mov BALLONS_X[4] ,60
     
     mov bx,0
     lab1: 
     mov BALLONS_Y [bx],0
     inc bx
     mov BALLONS_Y [bx],15
     inc bx
     cmp bx,8
     jnz lab1
     mov S1L1[8],'n'  
     mov S1L1[0],'P'
         
     jmp begin
     ret
reset  endp


checkCollision proc
Cmp BulletPosX_1,0      ;checking if bullet1 exists or not
jz CheckCollision_2
CALL CheckNextChar_1    ; if it exists then we check if there is a collision or not

CheckCollision_2: 
Cmp BulletPosX_2,0      ;checking if bullet2 exists or not
jnz CallCollision_2
jz  NotaCollision

CallCollision_2:
Call CheckNextChar_2     ; if it exists then we check if there is a collision or not

NotaCollision:
ret
checkCollision endp 

quickExit proc 
    
    ; create new screen 
      mov ah,0
      mov al,03h
      int 10h
      
      
      ; print names and scores of 2 players  
     mov ah ,2
     mov bh,0
     mov dx,0710h
     int 10h
     mov dx ,offset nam1+2
     mov ah,9
     int 21h 
     
     mov ah ,2
     mov bh,0
     mov dx,0710h
     add dl,nam1+1
     int 10h
     mov dx ,offset point1
     mov ah,9
     int 21h
     
     mov ah ,2
     mov bh,0
     mov dx,0730h
     int 10h
     mov dx ,offset nam2+2
     mov ah,9
     int 21h
     
     mov ah ,2
     mov bh,0
     mov dx,0730h
     add dl,nam2+1
     int 10h 
     mov dx ,offset point2
     mov ah,9
     int 21h
      
      
      ;delay 
    mov dx,4B40h
    mov cx,04Ch        
    mov ah,86h 
    INT 15h
    call reset
    
quickExit endp 


pausegame proc
    pause:   
                mov al,0 ; to clear the previous ket
helppouse:
                call inlineChat
                mov ah,1 
                int 16h 
                cmp ah,3FH 
                jz out11
                
                mov dx , 3FDH 
                in al , dx 
  	        	AND al , 1
  		        JZ helppouse 
  		        
                mov dx , 03F8H
  		        in al , dx
  		        cmp al,3FH
  		        jz out1
  		        jnz helppouse
  		         
  		        out11:mov ah,0 
                      int 16h
 AGAIN1465:
         mov dx , 3FDH		; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN1465   
         mov dx , 3F8H
         mov al,ah	; Transmit data register
         out dx ,al
            jmp out1
             
            ret
pausegame endp  

initialise proc 
    
       mov dx,3fbh 			; Line Control Register
mov al,10000000b		;Set Divisor Latch Access Bit
out dx,al			;Out it
;Set LSB byte of the Baud Rate Divisor Latch register.
mov dx,3f8h			
mov al,0ch			
out dx,al
;Set MSB byte of the Baud Rate Divisor Latch register.
mov dx,3f9h
mov al,00h
out dx,al


mov dx,3fbh
mov al,00011011b
out dx,al

ret
initialise endp 

notifiction proc
    chattingacc:   
    
         
          mov ah ,2
          mov bh,0
          mov dx,1600h
          int 10h 
          mov dx ,offset nam2+2
          mov ah,9
          int 21h
          
           mov ah ,2
           mov bh,0
           mov dx,1600h
           add dl,nam2+1
           int 10h 
           mov dx ,offset rchat
           mov ah,9
           int 21h
           
           mov ah,0
           int 16h
           cmp ah,3Bh 
           jz chatting1
           jmp chattingacc 
           chatting1:
             call sendname 
             AGAIN00:
         mov dx , 3FDH		; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN00
  		    
         mov dx , 3F8H		; Transmit data register
         mov al,3Bh
         out dx , al 
         jmp chatting
         gameacc:
         
     
          mov ah ,2
          mov bh,0
          mov dx,1600h
          int 10h 
          mov dx ,offset nam2+2
          mov ah,9
          int 21h
          
           mov ah ,2
           mov bh,0
           mov dx,1600h
           add dl,nam2+1
           int 10h 
           mov dx ,offset rgame
           mov ah,9
           int 21h
           
           mov ah,0
           int 16h
           
           cmp ah,3Ch 
           jz game1
           jmp gameacc 
           game1:
              call sendname
              AGAIN11:
         mov dx , 3FDH		9; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN11
  		   
         mov dx , 3F8H		; Transmit data register
         mov al,3Ch
         out dx , al 
         
      ;   ;clear register  
;       mov dx , 3FDH
;       ou1:; Line Status Register
;		in al , dx 
;  		AND al , 1
;  		JZ ou1
;  		mov dx , 03F8H
;  		in al , dx
         
         ;wait for level
         mov dx , 3FDH
       ou12: 
        		; Line Status Register
		in al , dx 
  		AND al , 1
  		JZ ou12

 
  		mov dx , 03F8H
  		in al , dx 
  		push ax
  		
  		AGAIN115:
         mov dx , 3FDH		9; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN115
  		   
         mov dx , 3F8H		; Transmit data register
         mov al,' '
         out dx , al 
         
        pop ax 
         
  		cmp al,'2'
  		jz leveltwor
  		cmp al,'1'
  		jz game            
  		mov dx,3FDH       
         jmp ou12
       ret
    notifiction endp 
getname proc 
    pusha
    mov bx,0
       n2:
         mov dx , 3FDH
        		
	CHK1:in al , dx 
  		AND al , 1
  		JZ CHK1

 
  		mov dx , 03F8H
  		in al , dx 
  		mov nam2[bx] , al
        inc bx
        cmp bx,15d
     jnz n2
     popa
     ret
     getname endp 

sendname proc
    pusha  
       mov bx,0 
         lop:
          AGAIN1:
         mov dx , 3FDH		; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN1   
         mov dx , 3F8H
         mov al,nam1[bx]	; Transmit data register
         out dx ,al
         inc bx
         cmp bx,15d
         jnz lop 
     popa
        ret
    sendname endp 

waitforResp proc
game00:
       call getname
       mov dx , 3FDH 
    c00: in al , dx 
  		AND al , 1
  		JZ C00
        mov dx , 03F8H
  		in al , dx
  		cmp al,3Ch
  		jnz c00
  		wro:
  		mov ah,2          ;Move Cursor
        mov dx,1500h      ;X,Y Position
        int 10h 
  		mov ah, 9
        mov dx, offset lev ;Display string 
        int 21h
        
        mov ah,0
        int 16h 
        push ax 
        push ax
        AGAIN178:
         mov dx , 3FDH		; Line Status Register
         In al , dx 			;Read Line Status
  		 AND al , 00100000b
  		 JZ AGAIN178   
         mov dx , 3F8H
         pop ax	; Transmit data register
         out dx ,al
        
        
       mov dx , 3FDH
        		
	CHK451:in al , dx 
  		AND al , 1
  		JZ CHK451
  		mov dx , 03F8H
  		in al , dx
        
        pop ax 
        cmp al,'2'
        jz leveltwos
        cmp al,'1'
        jnz wro
        
        
        jmp game 
  		        
  		
  		
chatting00:
    call getname
    mov dx , 3FDH 
   c01: in al , dx 
  		AND al , 1
  		JZ C01
        mov dx , 03F8H
  		in al , dx
  		cmp al,3Bh
  		jnz begin
  		jz chatting
     
waitforResp endp

checkbuff proc 
    
    mov dx , 3FDH		; Line Status Register
		in al , dx 
  		AND al , 1
  		JZ out1

 
  		mov dx , 03F8H
  		in al , dx
  		 
  		cmp al,48h 
  		 jz upP1
  		cmp al,50h
         jz downP1
         
         cmp al,3Fh
        jz helppouse 
        cmp al,3Eh
        jz quit
        cmp al,39h
        jz beforeGenBullet_2 
         
     back:
     out1:
     ret
    checkbuff endp 
changelevel proc
    
     leveltwor:
     mov LEVEL,1
        jmp game   
     leveltwos:
     mov LEVEL,1
        
           
     jmp game   
         ret
    changelevel endp 
chatt proc 
ls:     
        mov dx , 3FDH		    ; Line Status Register
AGAINs: 
        In al , dx 	            ;Read Line Status
        AND al , 00100000b
      	;JZ AGAINs
        mov ah,1
        int 16h     ;take the first value stored in the buffer(al->ascii , ah->scan)
        
        jz RECIEVE
        MOV AH,0
        INT 16H  
        cmp ah,3Dh
        jz  retchat
        mov dx , 3F8H		    ; Transmit data register
        out dx , al 
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        mov dx,cursors  
        mov ah,2  
        int 10h         ;set cursor
        mov cl,al
  	    cmp cl,0Dh
  	    jz enters
  	    cmp cl,08h
  	    jz backspaces
  	    jmp normals 
  	    
enters:        
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        
        add dh,1h
        mov dl,0
        
        cmp dh,0Ah
        jz scroll_ups
        
retts:   mov ah,2  
        int 10h         ;set cursor
         
        jmp normal2s
        
backspaces:
        
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        ;-----------------------------------------------------
        cmp dx,0    ;first place in the screen (do nothing)
        jz normal2s
        cmp dl,0    ;first place in a line
        jz jumps  
        dec dl      ;decrement normally
        jmp jump2s
        jumps:
        mov dl,79   ;move to the end of the line above
        dec dh
        jump2s:
        mov ah,2  
        int 10h         ;set cursor
        
        mov si,dx       ;save cursor position 
        
        mov ah,2 
        mov dl,20h 
        int 21h       ;write space 
        
        mov dx,si        ;retrive  cursor
        
        mov ah,2  
        int 10h         ;set cursor
        jmp normal2s
  	    
normals:	
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor  
        
        cmp dl,79
        jnz rett2s
        cmp dh,09h
        jz scroll_up2s
        
        
 rett2s: mov ah,2
  		mov dl,al
  		int 21h
normal2s:  		
       mov ah,3h 
       mov bh,0h 
       int 10h        ;get cursor
       mov cursors,dx 
       jmp RECIEVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
scroll_ups: ;;;this to scroll upper part 
        pusha      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 1h               ; row top
        mov cl, 00h               ; col left
        mov dh, 9h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,9
        
        jmp retts
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scroll_up2s: ;;;this to scroll upper part 
        pusha
        mov ah,2
  		mov dl,al
  		int 21h      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 1h               ; row top
        mov cl, 00h               ; col left
        mov dh, 9h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,9
        mov dl,0
        mov ah,2
        int 10h
        jmp normal2s
        
        
RECIEVE:  
    mov dx , 3FDH		; Line Status Register
CHKr:	
    in al , dx 
  	AND al , 1
  	JZ ls
  	
     mov ah,2
     mov dx,cursorr  
     int 10h        ;set cursor
    mov dx , 03F8H
  	in al , dx 
  	cmp al,3Dh
  	jz begin
  	 ;;;;;;;;;;;;;;;;;;;   
  	    pusha
  	    mov cl,al
  	    cmp cl,0Dh
  	    jz enterr
  	    cmp cl,08h
  	    jz backspacer
  	    jmp normalr 
  	    
enterr:        
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        
        add dh,1
        mov dl,0
        
        cmp dh,14h
        jz scroll_upr
        
rettr:
        mov ah,2  
        int 10h         ;set cursor
         
        jmp normal2r
        
backspacer:
        
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        ;-----------------------------------------------------
        cmp dx,0c00h    ;first place in the screen (do nothing)
        jz normal2r
        cmp dl,0    ;first place in a line
        jz jumpr  
        dec dl      ;decrement normally
        jmp jump2r
        jumpr:
        mov dl,79   ;move to the end of the line above
        dec dh
        jump2r:
        mov ah,2  
        int 10h         ;set cursor
        
        mov si,dx       ;save cursor position 
        
        mov ah,2 
        mov dl,20h 
        int 21h       ;write space 
        
        mov dx,si        ;retrive  cursor
        
        mov ah,2  
        int 10h         ;set cursor
        jmp normal2r

  	    
normalr:
        mov ah,3h
        mov bh,0h
        int 10h        ;get cursor	
        cmp dl,79
        jnz rett2r
        cmp dh,13h
        jz scroll_up2r
        
rett2r:  mov ah,2
  		mov dl,al
  		int 21h
normal2r:
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        mov cursorr, dx
         
        jmp ls 
        
scroll_upr: ;;;this to scroll upper part 
        pusha      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 0Ch               ; row top
        mov cl, 00h               ; col left
        mov dh, 13h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,13h
        jmp rettr 
scroll_up2r: ;;;this to scroll upper part 
        pusha
        mov ah,2
  		mov dl,al
  		int 21h       
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 0Ch               ; row top
        mov cl, 00h               ; col left
        mov dh, 13h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,13h  
        mov dl,0
        mov ah,2
        int 10h
        jmp normal2r
         
        retchat:
        mov dx , 3FDH		; Line Status Register
    AGAINch:In al , dx 			;Read Line Status
  		AND al ,00100000b
  		JZ AGAINch

;If empty put the VALUE in Transmit data register
  		mov dx , 3F8H		; Transmit data register
  		mov  al,ah
  		out dx , al 

        jmp begin
     ret   
chatt endp 
inlineChat proc
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check36: 
        mov dx , 3FDH		    ; Line Status Register
AGAINss: 
        In al , dx 	            ;Read Line Status
        AND al , 00100000b
        jz receive
        mov ah,1
        int 16h     ;take the first value stored in the buffer(al->ascii , ah->scan)
        jz receive
        
        MOV AH,0
        INT 16H
                
        cmp ah,3fh 
        jnz notf5       
        mov al,ah        
        notf5:        
        mov dx , 3F8H 		    ; Transmit data register
        out dx , al
        
        cmp ah,3fh
        jz out1
     ;;;;;;;;;;;;;;;;;;;;;;;  
        PUSHA 
        MOV DX,CURSS
        mov ah,2  
        int 10h         ;set cursor
        POPA
        mov cl,al
  	    cmp cl,0Dh
  	    jz scroll_upss  ; check enter
  	    cmp cl,08h
  	    jz backspacess
  	    jmp normalss 
  	    



scroll_upss: ;;;this to scroll upper part 
        pusha      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 14h               ; row top
        mov cl, 10h               ; col left
        mov dh, 14h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,9
        
        mov dx,1410h
        mov ah,2  
        int 10h         ;set cursor  
        mov curss,dx
        jmp check36  
scroll_up2ss: ;;;this to scroll upper part 
        pusha      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 14h               ; row top
        mov cl, 10h               ; col left
        mov dh, 14h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,9
        
        mov dx,1410h
        mov ah,2  
        int 10h         ;set cursor
        mov ah,2
  		mov dl,al
  		int 21h         ; WRITE
  		mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor  
        mov curss,dx
        jmp check36         
backspacess:
        
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        ;-----------------------------------------------------
        cmp dl,10h    ;first place in a line
        jz check36  
        dec dl
        mov si,dx       ;save cursor position 
        
        mov ah,2 
        mov dl,20h 
        int 21h       ;write space 
        
        mov dx,si        ;retrive  cursor
        
        mov ah,2  
        int 10h         ;set cursor
        MOV CURSS,DX
        jmp check36
normalss:                           
        	
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor  
        
        cmp dl,79
        jz scroll_up2ss
  
        mov ah,2
  		mov dl,al
  		int 21h    ;WRITE
  		mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor  
        mov curss,dx
  		JMP check36
  		
receive:
     mov ah,2
     mov dx,cursr  
     int 10h        ;set cursor
     
     mov dx , 3FDH		; Line Status Register
CHKrr:	
    in al , dx 
  	AND al , 1
  	JZ check36

    mov dx , 03F8H
  	in al , dx 
  	
  	cmp al,3fh
  	jz out1
  	 ;;;;;;;;;;;;;;;;;;;   
  	    pusha
  	    mov cl,al
  	    cmp cl,0Dh
  	    jz scroll_uprr
  	    cmp cl,08h
  	    jz backspacerr
  	    jmp normalrr 
  	    
        
backspacerr:
        
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        ;-----------------------------------------------------
        cmp dl,10h    ;first place in a line
        jz check36  
        dec dl
        mov si,dx       ;save cursor position 
        
        mov ah,2 
        mov dl,20h 
        int 21h       ;write space 
        
        mov dx,si        ;retrive  cursor
        
        mov ah,2  
        int 10h         ;set cursor
        MOV CURSR,DX
        jmp check36

  	    
normalrr:	
        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor  
        
        cmp dl,79
        jz scroll_up2rr
          
        mov ah,2
  		mov dl,al
  		int 21h

        mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor
        mov cursr, dx
         
        jmp check36 
        
scroll_uprr: ;;;this to scroll upper part 
        pusha      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 15h               ; row top
        mov cl, 10h               ; col left
        mov dh, 15h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,9
        
        mov dx,1510h
        mov ah,2  
        int 10h         ;set cursor  
        mov cursR,dx
        jmp check36
scroll_up2rr: ;;;this to scroll upper part 
        pusha      
        mov ah, 6               ; http://www.ctyme.com/intr/rb-0096.htm
        mov al, 1               ; number of lines to scroll
        mov bh, 7               ; attribute
        mov ch, 15h               ; row top
        mov cl, 10h               ; col left
        mov dh, 15h              ; row bottom
        mov dl, 79              ; col right
        int 10h
        popa
        mov dh,9
        
        mov dx,1510h
        mov ah,2  
        int 10h         ;set cursor
        mov ah,2
  		mov dl,al
  		int 21h         ; WRITE
  		mov ah,3h 
        mov bh,0h 
        int 10h        ;get cursor  
        mov cursr,dx
        jmp check36
        
        
        ret 
inlineChat endp 
           
end main 

 
 

 

