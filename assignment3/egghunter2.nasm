; author ron chan
; compile
; nasm -f egghunter.nasm
; ld egghunter.o -o egghunter
; objdump -d egghunter



global _start			

section .text
_start:	
	xor eax,eax
