.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32rt.inc 

includelib \masm32\lib\kernel32.lib

.data 
	z_r 			REAL4 0
	z_i 			REAL4 0
	c_r 			REAL4 0
	c_i 			REAL4 0
	tmp				REAL4 0
	i 				REAL4 0
	
	x				REAL4 0
	y				REAL4 0
	x1				REAL4 -2.1
	x2				REAL4 0.6
	y1				REAL4 -1.2
	y2				REAL4 1.2
	
	image_x			REAL4 0
	image_y			REAL4 0
	zoom			REAL4 100
	iteration_max 	REAL4 50
	
	result1			REAL4 0
	result2			REAL4 0
	result3			REAL4 0
	result4			REAL4 0
	result5			REAL4 0
	
.data? 
	
	
.code 

start: 

;fonction initialisation
;	initialisation PROC USES eax, ebx, ecx, edx, result1:REAL4,result2:REAL4,result3:REAL4,result4:REAL4,result5:REAL4
;		mov eax,0
;		mov ebx,0
;		mov ecx,0
;		mov edx,0
;		mov result1, 0
;		mov result2, 0
;		mov result3, 0
;		mov result4, 0
;		mov result5, 0
;		RET
;	initialisation ENDP
	
	
	;initialisation d'image_x
	mov image_x, x2
	sub image_x, x1
	mul image_x, zoom
	
	;initialisation d'image_y
	mov image_y, y2
	sub image_y, y1
	mul image_y, zoom
	
	mov x, 0
	;boucle for: tant que x< image_x par pas de 1
	pour_x:
		cmp x, image_x
		jl fin_pour_x
		
		mov y, 0
		;boucle for: tant que y<image_y par pas de 1
		pour_y:
			;definition du c réel
			mov c_r, x
			div c_r, zoom
			add c_r, x1
			
			;définition du c iréel
			mov c_i, y
			div c_i, zoom
			add c_i, y1
			
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
				mov result1, z_r
				mul result1, z_r
				mov result2, z_i
				mul result2, z_i
				add result1, result2
				
				;condtion tant que
				cmp result1, 4
				jl fin_tantque
				cmp i, iteration_max				
				jl fin_tantque
				
				;initialisation de tmp
				mov tmp, z_r
				
				;formule z_r = z_r² - z_i² + c_r
				mov result3, z_r
				mul result3, z_r
				mov result4, z_i
				mul result4, z_i
				sub result3, result4
				add result3, c_r
				mov z_r, result3
				
				;formule z_i = 2*z_i*tmp + c_i
				mov result5, z_i
				mul result5, 2
				mul result5, z_i
				mul result5, tmp
				add result5, c_i
				mov z_i, result5
				
				;incrémentation de i
				inc i
			
			fin_tantque:
			
			;si
			cmp i, iteration_max
			jne sinon
			;dessiner en noir
				
			sinon:
			;dessiner avec couleur
			
			
			inc y
		
		fin_pour_y:
		
		inc x
		
	fin_pour_x:
	
	inkey  ; attente d'un appui de touche par l'utilisateur (met le programme en pause).
    
    push 0 
    call ExitProcess 
    
end start 