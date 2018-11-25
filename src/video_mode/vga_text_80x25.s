.section .boot, "awx"
.intel_syntax noprefix
.code16

config_video_mode:
    mov ah, 0
    mov al, 0x03 # 80x25 16 color text
    int 0x10
    ret

.code32

vga_map_frame_buffer:
    mov eax, 0xb8000
    or eax, (1 | 2)
    mov ecx, 0xb8000
    shr ecx, 12
    mov [_p1 + ecx * 8], eax
    ret

# print a string and a newline
# IN
#   esi: points at zero-terminated String
vga_println:
    push eax
    push ebx
    push ecx
    push edx

    call vga_print

    # newline
    mov edx, 0
    mov eax, vga_position
    mov ecx, 80 * 2
    div ecx
    add eax, 1
    mul ecx
    mov vga_position, eax

    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

# print a string
# IN
#   esi: points at zero-terminated String
# CLOBBER
#   ah, ebx
vga_print:
    cld
vga_print_loop:
    # note: if direction flag is set (via std)
    # this will DECREMENT the ptr, effectively
    # reading/printing in reverse.
    lodsb al, BYTE PTR [esi]
    test al, al
    jz vga_print_done
    call vga_print_char
    jmp vga_print_loop
vga_print_done:
    ret


# print a character
# IN
#   al: character to print
# CLOBBER
#   ah, ebx
vga_print_char:
    mov ebx, vga_position
    mov ah, 0x0f
    mov [ebx + 0xb8000], ax

    add ebx, 2
    mov [vga_position], ebx

    ret

vga_position:
    .double 0
