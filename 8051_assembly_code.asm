;====================================================================
; DEFINITIONS
;====================================================================
ale equ p2.3
soc equ p2.0
eoc equ p2.1

;====================================================================
; VARIABLES
;====================================================================
flag equ 00h
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
      org   0000h
      ljmp   Start

      org 000bh
      sjmp T0ISR      
      
      org 001bh
      sjmp T1ISR
;====================================================================
; CODE SEGMENT
;====================================================================




      org   0030h
Start:		
mov p2,#82h         ;set p2 1st and 7th line as inputs and others as outputs
mov p1,#0ffh        ;set p1 as input port
mov p3,#00h         ;set p3 as output port
clr pt0             ;set timer0 priority 0
setb pt1            ;set timer1 priority 1
mov ie,#8ah         ;enable timer0 and timer1 interrupts
mov tmod,#12h       ;set timer1 in mode1 and timer0 in mode2
mov tl0,#0feh       ;count for 500kHz
mov th0,#0feh       ;count for reload
mov tl1,#12h        ;lower count for timer1
mov th1,#0fdh       ;upper count for timer1
setb tr0            ;start timer 0
setb tr1            ;start timer 1
clr p3.1            ;clear p3.1

back:    
clr ale                ;clear ale
clr soc                ;clear soc

setb ale              ;set ale
acall delay           ;call delay
setb soc              ;set soc
acall delay           ;call delay

clr ale               ;clear ale
clr soc               ;clear soc

again:jnb eoc,again   ;check for end of conversion
acall delay
jb p2.7,skip          ;if p2.7 high jump to skip
setb p3.0             ;set p3.0 
mov r1,p1             ;take data from port1 to r1 register
sjmp back             ;jump to back 
skip:                 
clr p3.0              ;clr p3.0
sjmp back             ;jump to back



T0ISR:                ;subroutine for T0 interrupt
cpl p2.4              ;complement p2.4
reti                  ;return from subroutine


T1ISR:               ;subroutine for T1 interrupt
cpl p3.5             ;complment p3.5
clr c                ;clear carry flag
mov a,r1             ;take data drom r1 to a register
subb a,#90h          ;subtract 90h from a 
jnc d_25             ;jump to d_25 if carry flag is zero

d_75:                ;condition for 75% duty ratio
clr tr1              ;stop timer1 
cpl flag             ;complement flag register
jnb flag,OFF         ;jump to off if flag is zero 
ON: 
mov tl1,#12h         ;set ON time period lower 
mov th1,#0fdh        ;set ON time period higher          
sjmp go_0            ;jump to go_0
OFF: 
mov tl1,#06h         ;set OFF time period
mov th1,#0ffh        ;set OFF time period
go_0:nop
setb tr1             ;start timer1
jmp skip_1           ;if d_25 is executed d_75 won't and vice versa

d_25:                ;condition for 25% duty ratio
clr tr1              ;stop timer1
cpl flag             ;complement flag register
jnb flag,OFF_1       ;jump to OFF_1 if flag is zero
ON_1:                
mov tl1,#06h         ;set ON time period lower
mov th1,#0ffh        ;set ON time period higher
sjmp go_1            ;jump to go_1
OFF_1:  
mov tl1,#12h         ;set OFF time period lower
mov th1,#0fdh        ;set ON time period higher
go_1:nop           
setb tr1             ;start timer1

skip_1:
nop
reti                 ;return from ISR        



delay:mov r0,#07h   ;delay function
go:
djnz r0,go
ret


;====================================================================
      END
