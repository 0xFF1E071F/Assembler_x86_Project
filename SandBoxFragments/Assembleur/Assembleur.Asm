.686
.model flat,stdcall 
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc 
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 

includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib
include masm32.inc
includelib masm32.lib

.data 
	x1				REAL4 	-2.1
	x2				REAL4 	0.6
	y1				REAL4 	-1.2
	y2				REAL4 	1.2
	
	zoom			dd 		100
	iteration_max 	dd 		50
	deux 			dd 		2
	
.data? 
	z_r 			REAL4 	?
	z_i 			REAL4 	?
	c_r 			REAL4 	?
	c_i 			REAL4 	?
	tmp				REAL4 	?
	i 				REAL4 	?
	
	x				REAL4 	?
	y				REAL4 	?
	
	image_x			dd	 	?
	image_y			dd	 	?
	
	result1			REAL4 	?
	result2			REAL4 	?
	result3			REAL4 	?
	result4			REAL4 	?
	result5			REAL4 	?
	
.code 

start: 
	
	;initialisation d'image_x
	fild image_x
	fadd x2
	fsub x1
	fimul zoom
	fistp image_x
	
	;initialisation d'image_y
	fIld image_y
	fadd y2
	fsub y1
	fimul zoom
	fistp image_y
	
	mov x, 0
	mov y, 0
	
	;boucle for: tant que x< image_x par pas de 1
	pour_x:
		mov result1, 0
		
		fild image_x
		fld x
		fcomip st(0), st(1)
		fstp result1
		jl fin_pour_x
		
		;boucle for: tant que y<image_y par pas de 1
		pour_y:
		
			;definition du c réel
			fld c_r
			fadd x
			fidiv zoom
			fadd x1
			fstp c_r
			
			;définition du c iréel
			fld c_i
			fadd y
			fidiv zoom
			fadd y1
			fstp c_i
			
			;initialisation de variables
			mov z_r, 0
			mov z_i, 0
			mov i, 0
			
			;boucle while: z_r² + z_i² <4 et i<iteration_max
			tantque:
			
				;initialisation de variables nécessaires aux calculs des formules
				mov result1, 0
				mov result2, 0
				mov result3, 0
				mov result4, 0
				mov result5, 0
				
				;formule z_r² + z_i²
				fld z_r
				fmul z_r
				fld z_i
				fmul z_i
				fadd st(0), st(1)
				fstp result1
				
				;condtion tant que
				cmp result1, 4
				jl fin_tantque
				fld i
				fild iteration_max
				fcomip st(0), st(1)
				fstp result2	
				jl fin_tantque
				
				;initialisation de tmp
				fld tmp
				fadd z_r
				fstp tmp
				
				;formule z_r = z_r² - z_i² + c_r
				fld z_r
				fmul z_r
				fld z_i
				fmul z_i
				fsubp st(1), st(0)
				fadd c_r
				fstp z_r
				
				;formule z_i = 2*z_i*tmp + c_i
				fld z_i
				fimul deux
				fmul tmp
				fadd c_i
				fstp z_i
				
				;incrémentation de i
				inc i
			
			fin_tantque:
			
			;si
			fld i
			fild iteration_max
			fcomip st(0), st(1)
			fstp result2
			jne sinon
			;dessiner en noir
				
			sinon:
			;dessiner avec couleur
			

			inc y
		
		fin_pour_y:
		
		inc x
		
	fin_pour_x:
	
;	inkey  ; attente d'un appui de touche par l'utilisateur (met le programme en pause).
    
    push 0 
    call ExitProcess 
    
end start 