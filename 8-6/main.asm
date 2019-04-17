.model tiny
.code
.386
org 100h
start:
      jmp begin
 
     
;source - number of register, reciver - register for result value 
get_part_time macro source,receiver
      mov al, source
      out 70h, al       ;print register into port
      in al, 71h        ;get info from register
      mov receiver, al
endm
 
 
 
;value - bcd number, source - place for result  
bcd_to_int macro value, source
      pusha                     
      
      mov al,value
      and al,00001111b    ;younger 4 bits
      add al, '0'         ;from string to number
      mov cs:source[2], al     ;write first digit into time string

      mov al,value
      shr al, 4           ;>>4, now we have older 4 bits
      add al, '0'         ;string into number
      mov cs:source[0], al    ;write secind digit
        
      popa     
endm

time_str db '0',2Eh,'0',2Eh,':',2Eh,'0',2Eh,'0',2Eh,':',2Eh,'0',2Eh,'0', 2Eh
old_handler dd ?
coordinate dw 0
pos_x dw ?
pos_y dw ?
error_message db 'Invalid command line parameters!', 0dh, 0ah, '$'

get_time proc
      pusha  
      
      get_part_time 0,dl ; seconds
      bcd_to_int dl,time_str[12]
      
      get_part_time 2,dl ; minutes
      bcd_to_int dl,time_str[6]
      
      get_part_time 4,dl ; hours
      bcd_to_int dl,time_str[0]

      popa
      ret
endp

output_time proc
      pusha
      pushf
      push ds
      push es

      mov ax, 0B800h      ;segment of display
      mov es, ax         

      mov ax, cs
      mov ds, ax          ;code segment into data (cause constants in .code)
      mov di, coordinate
      lea si, time_str
      mov cx, 16

      cld                  ;df=0
      rep movsb            ;si->di

      pop es
      pop ds
      popf
      popa
      ret
endp


skip_space macro str 
      local skip_space            ;local variable  
      
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
            
      cmp byte ptr es:[si],10           ;new line
            je skip_letters_end       
            
      cmp byte ptr es:[si],13           ;begin of line
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
      sub dl,'0'                ;convert into num 
      
      add ax, dx       
      jo error                  
      
      mov num,ax
      inc bx
      jmp convert_to_num_cycle  
      
      convert_to_num_cycle_end:
      popa
endm 
 
 
 
 
get_coordinates_from_cmd proc near
      mov si,81h                    ;cmd text
      
      skip_space si                 
      
      convert_to_num si,pos_x       ;input first number with str->num
      
      cmp pos_x,72
      jg error               
      
      skip_letters si
      ; add si,1
      skip_space si         
      
      convert_to_num si,pos_y
      cmp pos_y,24
      jg error
      
      
      xor ax,ax
      mov ax,pos_y
      mov dx,160
      imul dx        
      jo error
      add ax, pos_x
      add ax, pos_x
      ;sub ax,2
      
      mov coordinate,ax
      ret
endp




int_handler proc far    ;interrupt handler
   cli
   
   call get_time
   call output_time
   jmp cs:old_handler
    
   sti 
   iret
endp


begin:
      call get_coordinates_from_cmd  
       
      mov ax, 351Ch     ;get old handler (result in bx)
      int 21h            
      
      mov word ptr old_handler, bx     ;save old handler
      mov word ptr old_handler + 2, es

      mov ax, 251Ch                    ;tell dos to set new handler from dx
      lea dx, int_handler
      int 21h

      jmp finish

error:

      mov ah, 9
      lea dx, error_message      ;out error
      int 21h
      jmp end_main


finish:
       mov ax, 3100h   ;keep resident
       mov dx, (begin - start + 10Fh) / 16   ;size of resident part
       int 21h
       ret
       
end_main:
       mov ah, 4ch
       int 21h

end start