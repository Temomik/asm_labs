.model tiny
.code
.386
org 100h
start:
      jmp begin

get_cmos_value macro source,receiver
      mov al, source
      out 70h, al
      in al, 71h    
      mov receiver, al
endm

bcd_to_decimal macro bcd_num, source
      pusha
      mov al,bcd_num
      and al,00001111b
      add al, '0'
      mov cs:source[2], al 

      mov al,bcd_num
      shr al, 4
      add al, '0'
      mov cs:source[0], al      
      popa     
endm

time_str db '0',2Eh,'0',2Eh,':',2Eh,'0',2Eh,'0',2Eh,':',2Eh,'0',2Eh,'0', 2Eh
old_handler dd ?
position dw 0
rawPositionX dw ?
rawPositionY dw ?
msg_err db 'parametrs must be like x y,', 0dh, 0ah, 'where 0 <= x < 73 and 0 <= y < 25', 0dh, 0ah, '$'

get_time proc
      pusha
      get_cmos_value 0,dl ; sec
      bcd_to_decimal dl,time_str[12]
      
      get_cmos_value 2,dl ; min
      bcd_to_decimal dl,time_str[6]
      
      get_cmos_value 4,dl ; hour
      bcd_to_decimal dl,time_str[0]

      popa
      ret
endp

output_time proc
      pusha
      pushf
      push ds
      push es

      mov ax, 0B800h     
      mov es, ax         

      mov ax, cs
      mov ds, ax
      mov di, position
      lea si, time_str
      mov cx, 16

      cld
      rep movsb

      pop es
      pop ds
      popf
      popa
      ret
endp


int_handler proc far

      call get_time
      call output_time

;    call cs:old_handler
   ; pushf   ; look what's there

   ; jmp cs:old_handler
   iret
endp


begin:
      mov si,80h
      mov dl,[si]
      
      mov position,100  
       
      mov ax, 351Ch
      int 21h
      mov word ptr old_handler, bx
      mov word ptr old_handler + 2, es

      mov ax, 251Ch
      lea dx, int_handler
      int 21h

      ; mov ax,251ch
      ; mov dx,word ptr old_handler+2
      ; mov ds,dx
      ; mov dx,word ptr cs:old_handler
      ; int 21h
 
      ; jmp cs:old_handler
      jmp finish


error:

      mov ah, 9
      lea dx, msg_err
      int 21h


finish:
      ; mov ax, 3100h
      ; mov dx, (begin - start + 10Fh) / 16
      ; int 21h
       ret

end start