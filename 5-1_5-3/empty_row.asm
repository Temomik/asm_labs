.model large
; .stack
.386
.data
cmd_paramters db 100,100 dup("$")
error_msg db "Error$"
row_msg db "Rows count: $"
filled_row_msg db "Filled rows row_count: $"
empty_row_msg db "empty rows row_count: $"
buffer db 0
file_handle dw 0
negative_var dw 0
row_count dw 0
empty_row_count dw 0
filled_row_count dw 0

fread_buffer db 0
fread_row_count dw 0
fread_empty_row_count dw 0
fread_filled_row_count dw 0
fread_is_row_empty dw 0

open_file macro name,handle,type
    pusha
    xor ax,ax
    mov ah, 3dh
    mov al, type
    lea dx, name
    int 21h
    mov handle, ax
    popa
endm

close_file macro handle
    pusha
    mov bx, handle
    mov ah, 3Eh
    int 21h
    popa
endm

fread macro handle,buffer,size
    ; pusha
    mov ah, 3Fh
        lea dx, buffer
        mov cx, size
        mov bx, file_handle
        int 21h
            jc end_programm
        cmp ax, cx
    ; popa
endm

putchar macro symb  
    push bx
    push ax
    push dx  
    mov bl, symb
    mov ah,2
    xor dl,dl
    mov dl,bl
    int 21h
    pop dx
    pop ax   
    pop bx
endm

print macro tmp
    push bx
    push dx
    push cx
    push ax
    mov ah,9
    xor dx,dx
    lea dx,tmp
    int 21h
    pop ax
    pop cx
    pop dx
    pop bx
endm

println macro tmp
    print tmp
    new_line
endm

new_line macro
    putchar 0Dh
    putchar 0Ah
endm   

add_num macro first,second
    push bx
    mov bx,first
    add bx,second
    mov first,bx
    pop bx
endm

print_num macro num
    mov ax,num
    call print_num_proc
endm   

copy_variable macro first,second
    push bx
    mov bx, second
    mov first,bx
    pop bx
endm

sub_variable macro first,second
push bx
push ax
mov bx,first
mov ax,second
sub bx,ax
mov first,bx
pop ax
pop bx  

endm

fwrite_ macro handle,offs,count 
    pusha
    mov ah, 40h
    mov cx,count
    mov dx, offs
    mov bx,handle
    int 21h
    popa
endm

calculate_row_num macro handle,row,filled_row,empty_row
    push bx
    push si
    lea si,handle
    call calculate_row_num_proc
    copy_variable row,fread_row_count
    copy_variable filled_row,fread_filled_row_count
    copy_variable empty_row, fread_empty_row_count
    pop si
    pop bx
endm

.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax
    call copy_file_name_from_commandline

    open_file  [cmd_paramters+2],file_handle,0
        jc error
    calculate_row_num file_handle,row_count,filled_row_count,empty_row_count


    print row_msg
    print_num row_count
    new_line

    ; print filled_row_msg
    ; print_num filled_row_count
    ; new_line

    ; print empty_row_msg
    ; print_num empty_row_count
    ; new_line

    close_file file_handle
    jnc quit
error:
    println error_msg
quit:
mov ax, 4c00h
int 21h


 print_num_proc proc near
        mov negative_var,0
        xor cx,cx 
        cmp ax,32767
            ja negative_value
        jmp push_num_cycle
        negative_value:
            mov negative_var,1
            neg ax
        push_num_cycle:
        xor dx,dx
        mov bx,10
        div bx
        add dx,48
        inc cx
        push dx
        cmp ax,0
            jne push_num_cycle
        cmp negative_var,1
            je push_minus
            jmp print_num_cycle
        push_minus:
            push '-'
            inc cx
            jmp print_num_cycle
        print_num_cycle:
            pop bx
            putchar bl
            loop print_num_cycle
        ret
    endp

calculate_row_num_proc proc near
    start_read:
        mov fread_is_row_empty,1
    read_from_file:
        fread [si],fread_buffer,1 
            jne eof
        cmp fread_buffer,13 ;\n
            je inc_row_start
        cmp fread_buffer,10 ; \0
            je read_from_file
        mov fread_is_row_empty,0
        jmp read_from_file
    inc_row_start:
        cmp fread_is_row_empty,0
            je start_read
        add fread_row_count,1
        jmp read_from_file
    eof:
    copy_variable fread_empty_row_count,fread_row_count
    sub_variable fread_empty_row_count,fread_filled_row_count
    ret
    endp

    end_programm proc near
        println error_msg
        mov ax, 4c00h
        int 21h    
        ret
    endp

    copy_file_name_from_commandline proc near
        pusha
        mov si,81h
        mov ah,62h
        int 21h
        lea di,cmd_paramters+2
        mov es,bx
        xor cx,cx
        mov cx,128
        xor bx,bx
        space_skip:
        inc si
        copy_cycle:
        cmp byte ptr es:[si]," "
            je space_skip
        mov ax,[es:si[bx]]
        mov di[bx],ax
        ; putchar di[bx];
        inc bx
        cmp byte ptr es:si[bx],13
            jz end_
        cmp byte ptr es:si[bx],10
            jz end_
        loop copy_cycle
        end_:
        mov di[bx],'$'
        new_line
        println cmd_paramters+2
        new_line
        popa
        ret
    endp

    error_proc proc near
        println error_msg
        mov ax, 4c00h
        int 21h
    endp

end start
