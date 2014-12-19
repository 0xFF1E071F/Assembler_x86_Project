.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32rt.inc 

includelib \masm32\lib\kernel32.lib

.data 
	iteration_max 	REAL4 50
	z_r 			REAL4 0
	z_i 			REAL4 0
	i 				REAL4 0
	result1			REAL4 0
	result2			REAL4 0
	result3			REAL4 0
	
.data? 
	c_r 			REAL4 ?
	c_i 			REAL4 ?
	x 				REAL4 ?
	y 				REAL4 ?
	tmp				REAL4 ?
	
.code 

start: 

	initialisation PROC USES eax, ebx, ecx, edx, result1:REAL4,result2:REAL4,result3:REAL4
		mov eax,0
		mov ebx,0
		mov ecx,0
		mov edx,0
		mov result1, 0
		mov result2, 0
		mov result3, 0
		RET
	initialisation ENDP

	pour: 
		inc x
		inc y
		
		add c_r, x
		add c_i, y
		mov z_r, 0
		mov z_i, 0
		mov i, 0
		mov eax, y
		mov ebx, i
		mul eax, ebx
		add c, eax 
	
		tantque:
			call initialisation
			
			add result1, z_r
			mul result1, z_r
			add result2, z_i
			mul result2, z_i
			add result3, result1
			add result3, result2
			
			cmp result3, 4
			jb fin_tantque
			cmp i, iteration_max
			jb fin
		
			mov ecx, z
			mul ecx, z
			add z, ecx
			add z, c
			inc i
			jmp tantque
		fin_tantque:
	
		cmp i, iteraration_max
		je dessin
	
		dessin:
	
		fin_dessin:
	
	fin_pour:
	inkey  ; attente d'un appui de touche par l'utilisateur (met le programme en pause).
    
    push 0 
    call ExitProcess 
    
end start 