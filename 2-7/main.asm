    .model small
    org 100h
    .stack 100h
    .386
    .data
    input_number_msg db "Input Number!$"
    array_size_input_msg db "Input size of array!$"
    array_input_msg db "Input array!$"
    array_msg db "Array is:$"
    top_msg db "Num          Count$"
    frequent_msg db "Most frequent num!$"
    enter_msg db "  Element ready to Input!$"
    index dw 1
    array dw 32,32 dup(0) 
    repeat_arr dw 62,62 dup(0)
    char_var db 1   
    is_null db 1

    negative_var db 1
    arr_ind dw 1    
    max_arr_count dw 1 
    repeat_arr_size dw 1
    repeat_arr_size_tmp dw 1
    is_find dw 1

    repeat_check macro arr, size, rep_arr
        push cx
        push si
        push di
        push bx
        push ax
        lea si,arr
        lea di,rep_arr
        mov cx,size
        call repeat_check_proc
        pop ax
        pop bx
        pop di
        pop si
        pop  cx
        
    endm    

    out_most_frequent_num macro arr,size
        push cx
        push bx
        push si
        push ax
        mov cx,size
        lea si,arr
        call out_most_frequent_num_proc
        pop ax
        pop si
        pop bx
        pop cx
    endm

    new_line macro
        putchar 0Dh
        putchar 0Ah
    endm   

    num_input macro num
        pusha                
        push bx   
        push si
        push di
        call num_input_proc 
        pop di
        pop si    
        pop bx
        mov num,ax           
        popa
    endm

    array_input macro arr, size
        push cx
        push si
        mov cx, size
        lea si,arr
        call array_input_proc
        pop si
        pop cx
    endm
    
    array_output macro arr, size
        push cx
        push si
        mov cx, size
        lea si,arr
        call array_output_proc
        pop si
        pop cx
    endm

    print_num macro num
        mov ax,num
        call print_num_proc
    endm   

    num_input_with_range macro num, min, max   
        push cx   
        push bx
        mov cx,max
        mov bx,min
        call num_input_proc_with_range 
        mov num,ax
        pop bx
        pop cx
    endm

    move macro x,y
        push cx
        push ax
        push dx
        push bx
        mov ah,3
        int   10h
        mov ah,2
        add dx,x
        add dl,y
        int 10h 
        pop bx
        pop dx
        pop ax
        pop cx

    endm

    set_x macro x
        push cx
        push ax
        push dx
        push bx
        mov ah,3
        int   10h
        mov ah,2
        xor dl,dl
        add dl,x
        int 10h 
        pop bx
        pop dx
        pop ax
        pop cx
    endm
    getchar macro tmp
        push ax
        push dx                        
        mov ah,01h
        xor dx,dx
        int 21h
        mov tmp,al  
        pop dx
        pop ax
    endm                            

    getline macro tmp  
        push ax
        push dx                        
        mov ah,0Ah
        xor dx,dx
        lea dx,tmp  
        int 21h
        pop dx
        pop ax
        new_line
    endm

    print macro tmp
        pusha
        mov ah,9
        xor dx,dx
        lea dx,tmp
        int 21h
        popa
    endm

    println macro tmp
        push ax
        push dx
        mov ah,9
        xor dx,dx
        lea dx,tmp
        int 21h
        pop dx
        pop ax
        new_line
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


    .code
        ; org 100h
    start:
        mov ax,@data
        mov ds,ax
        int   10h

        PRINTLN array_size_input_msg
        num_input_with_range max_arr_count,1,30
        new_line
        array_input array, max_arr_count
        new_line
        println array_msg
        array_output array, max_arr_count
        new_line
        repeat_check array,max_arr_count,repeat_arr
        new_line
        mov ax, repeat_arr_size
        add ax,repeat_arr_size
        mov repeat_arr_size_tmp,ax
        array_output repeat_arr,repeat_arr_size_tmp
        new_line
        
        println frequent_msg
        println top_msg
        out_most_frequent_num repeat_arr,repeat_arr_size

        new_line
        mov ah,4ch
        int 21h
    ret          

    

    del_negative_status proc near
        cmp cx, 5
            jne del_negative_status_end
        mov negative_var, 0
        del_negative_status_end:        
        ret
    endp            

    inc_cx_backspace proc near   
        cmp cx,4
        jng inc_cx_end
        mov cx,4
        inc_cx_end:   
            inc cx 
        ret
    endp    

    negative_input_proc proc near
        cmp cx,5
            jne delete_minus   
        cmp negative_var,0
            je negative_status_set  
        delete_minus:  
            move -1,0
            call clear_cell_proc
            jmp negative_input_end      
        negative_status_set:
            mov negative_var,1
        negative_input_end:
        ret
    endp 

    clear_cell_proc proc near
        putchar ' '         
        move -1,0
        ret
    endp

    num_input_proc proc near
        mov arr_ind,2
        repeat:
        mov is_find,0
        new_line
        println input_number_msg
        mov negative_var,0
        xor ax,ax
        xor bx,bx
        mov cx,5
        arr_input:
        getchar char_var
            cmp byte ptr char_var, '-'
                je negative_input
            cmp byte ptr char_var, 48
                je zero_inp
            cmp byte ptr char_var, 13
                je arr_input_end
            cmp byte ptr char_var, 8
                je  backspace_press
            cmp byte ptr char_var, 47
                jna  del_symbol_start
            cmp byte ptr char_var,58
                ja del_symbol_start
            jmp del_symbol_end
            del_symbol_start:
                move -1,0
                jmp del_cell
            negative_input:
                call negative_input_proc
            jmp arr_input
            backspace_press: 
                cmp cx,5
                    je zero_refresh
                zero_refresh_end:
                call del_negative_status
                call inc_cx_backspace
                push dx
                push bx
                mov bx,10
                div bx 
                pop bx
                pop dx
                jmp del_cell             
            
            del_cell:
                call clear_cell_proc
            jmp arr_input
            del_symbol_end:
            cmp cx,0
                je del_symbol_start
            xor bx,bx
            mov dx,10
            imul dx        
            jo repeat
            ;jo repeat
            mov bl, [char_var]
            sub bl,48
            add ax, bx       
            jo repeat
            ; cmp ax,32767
            cmp negative_var, 1
                je check_max          
            cmp ax,32767
                ja repeat                          
            check_max_end:
            ; jc repeat
            dec cx
            jz arr_input     
        jmp arr_input
        check_max:
            cmp ax,32768
                ja repeat
            jmp check_max_end
        
        zero_add:
        cmp is_find,1
            je zero_add_
            mov is_find,1
            inc cx
        jmp del_symbol_end

        zero_inp:
        cmp cx,5
            je zero_add
        cmp ax,0
            jne del_symbol_end
        zero_add_:
            move -1,0
            call clear_cell_proc
        jmp arr_input
        zero_refresh:
            mov is_find,062
        jmp zero_refresh_end
        arr_input_end:
        cmp is_find,1
            je continue_input
        cmp cx,5
            je repeat
        cmp negative_var,1
            jne continue_input
        neg ax
        continue_input:
            push bx
            mov bx, arr_ind
            mov array[bx],ax
            add arr_ind,2
            pop bx  
        ret
    endp

    num_input_proc_with_range proc near
        num_input_proc_with_range_start:
        push cx   
        push bx
            call num_input_proc   
            pop bx             
            pop cx
            cmp ax,cx
                jg num_input_proc_with_range_start  
            cmp ax,bx
                jl num_input_proc_with_range_start
        ret
    endp

    array_input_proc proc near
        push bx
        mov bx,4
        mov dx,1  
        array_input_cycle: 
            push bx    
            new_line     
            mov index,dx     
            ; add index, 48   
            print_num [index]
            println enter_msg    
            pop bx
            num_input si[bx] 
            add bx,2  
            add dx,1
        loop array_input_cycle
        pop bx
        ret
    endp

    array_output_proc proc near
        push bx
        mov bx,4
        array_output_cycle: 
            print_num si[bx]
            putchar ' '
            add bx,2  
        loop array_output_cycle
        pop bx
        ret
    endp

    print_num_proc proc near
        mov negative_var,0
        push bx
        push dx
        push cx
        push ax
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
        pop ax
        pop cx
        pop dx
        pop bx
        ret
    endp

    repeat_check_proc proc near 
        mov repeat_arr_size, 0
        mov bx,4
        repeat_check_cycle:
            mov ax,si[bx]
            add bx,2
            push cx
            push bx
            call fill_repeat_arr_proc
            pop bx
            pop cx
            loop repeat_check_cycle
        ret
    endp 

    fill_repeat_arr_proc proc near
        mov is_find,0
        mov bx,4
        mov cx,repeat_arr_size
        cmp repeat_arr_size,0
            je not_find
        fill_repeat_arr_cycle:
            cmp ax,di[bx]
                je fill_repeat_arr_start
            add bx,4
        loop fill_repeat_arr_cycle
        jmp fill_repeat_arr_end
        
        fill_repeat_arr_start:
            mov is_find,1
            mov di[bx],ax
            inc byte ptr di[bx+2]
        jmp fill_repeat_arr_end
        not_find:
            inc repeat_arr_size
        jmp fill_repeat_arr_start

        fill_repeat_arr_end:
            cmp is_find,0
                je not_find
                
        ret
    endp

    out_most_frequent_num_proc proc near
        push cx
        mov bx,6
        mov ax,0
        find_max_repeat_cycle:
            cmp ax,si[bx]
                jna find_greater_start 
            find_greater_end:   
            add bx,4
        loop find_max_repeat_cycle
        
        pop cx
        mov bx,6
        out_most_frequent_num_cycle:
            cmp ax,si[bx]
                je out_most_frequent_num_start
            out_most_frequent_num_end:
            add bx,4
        loop out_most_frequent_num_cycle
        jmp out_most_frequent_num_proc_end
        out_most_frequent_num_start:
            push cx
            print_num si[bx-2]
            set_x 13
            print_num si[bx]
            new_line
            pop cx
        jmp out_most_frequent_num_end

        find_greater_start:
            mov ax,si[bx]
        jmp find_greater_end
        out_most_frequent_num_proc_end:
        ret
    endp
    end start                 