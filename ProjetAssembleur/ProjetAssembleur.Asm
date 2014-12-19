.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32rt.inc 

includelib \masm32\lib\kernel32.lib

.data 
	iteration_max db 50
	z db 0
	i db 0
	
.data? 
	c db ?
	x db ?
	y db ?

.code 
start: 
	add c, x
	mov eax, y
	mov ebx, i
	mul eax, ebx
	add c, eax 
	
	tantque:
		cmp z, 2
		cmp i, iteration_max
		mov ecx, z
		mul ecx, z
		
	fin:
	
	inkey  ; attente d'un appui de touche par l'utilisateur (met le programme en pause).
    
    push 0 
    call ExitProcess 
    
end start 