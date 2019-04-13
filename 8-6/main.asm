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
matrix  db 15,4000 dup(15)

time_str db '0',2Eh,'0',2Eh,':',2Eh,'0',2Eh,'0',2Eh,':',2Eh,'0',2Eh,'0', 2Eh
old_handler dd ?
position dw 0
x_position dw ?
y_position dw ?
msg_err db 'Wrong parametrs,', 0dh, 0ah, 'input 0 <= x < 72 and 0 <= y < 24', 0dh, 0ah, '$'

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

skip_space macro str 
      local skip_space
      skip_space:
      inc si
      cmp byte ptr es:[si]," "
      je skip_space
endm

skip_letters macro str 
      local skip_letters,skip_letters_end
      skip_letters:
      inc si
      cmp byte ptr es:[si]," "
            je skip_letters_end
      cmp byte ptr es:[si],10
            je skip_letters_end
      cmp byte ptr es:[si],13
            je skip_letters_end
      jmp skip_letters
      skip_letters_end:
endm

convert_to_num macro str, num 
      local convert_to_num_cycle,convert_to_num_cycle_end
      pusha
      xor bx,bx
      xor ax,ax
      convert_to_num_cycle:
      cmp byte ptr str[bx],'9'
            jg error
      cmp byte ptr str[bx],'3'
            ; jl error
      cmp byte ptr str[bx]," "
            je convert_to_num_cycle_end
      cmp byte ptr str[bx],13
            je convert_to_num_cycle_end
      cmp byte ptr str[bx],10
            je convert_to_num_cycle_end
      mov dx,10
      imul dx        
            jo error
      xor dx,dx
      mov dl, si[bx]
      sub dl,'0'
      add ax, dx       
            jo error
      mov num,ax
      inc bx
      jmp convert_to_num_cycle
      convert_to_num_cycle_end:
      popa
endm

get_position proc near
      mov si,81h
      skip_space si
      convert_to_num si,x_position
      cmp x_position,72
            jg error
      skip_letters si
      ; add si,1
      skip_space si
      convert_to_num si,y_position
      cmp y_position,24
            jg error
      
      
      xor ax,ax
      mov ax,y_position
      mov dx,160
      imul dx        
            jo error
      add ax, x_position
      add ax, x_position
      sub ax,2
      mov position,ax
      ret
endp


int_handler proc far
      cli
      call get_time
      call output_time
      jmp cs:old_handler
      sti
   iret
endp


begin:      
      call get_position

      mov ax, 351Ch
      int 21h
      mov word ptr old_handler, bx
      mov word ptr old_handler + 2, es

      mov ax, 251Ch
      lea dx, int_handler
      int 21h

      jmp set_res

error:

      mov ah, 9
      lea dx, msg_err
      int 21h
      jmp end_

set_res:
      mov ax, 3100h
      mov dx, (begin - start + 10Fh) / 16
      int 21h  
      ret
end_:
      mov ah,4ch
      int 21h
end start