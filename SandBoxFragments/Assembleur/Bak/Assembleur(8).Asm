.686
.model flat,stdcall 
option casemap:none

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
	
	image_x			dd	 	270
	image_y			dd	 	240
	
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
	
	result1			REAL4 	?
	result2			REAL4 	?
	result3			REAL4 	?
	result4			REAL4 	?
	result5			REAL4 	?
	
.code 

start: 
	
	mov x, 0
	mov y, 0
				
			;fld image_x									;initialisation d'image_x
			;fadd x2
			;fsub x1
			;fimul zoom
			;fstp image_x
	
			;fld image_y									;initialisation d'image_y
			;fadd y2
			;fsub y1
			;fimul zoom
			;fstp image_y
						
			pour_x:										;boucle for: tant que x< image_x par pas de 1
				
				mov y, 0
											
				pour_y:								;boucle for: tant que y<image_y par pas de 1
					
					fld c_r							;definition du c r�el
					fadd x
					fidiv zoom
					fadd x1
					fstp c_r
				
					fld c_i							;d�finition du c ir�el
					fadd y
					fidiv zoom
					fadd y1
					fstp c_i
			
					mov z_r, 0						;initialisation de variables
					mov z_i, 0
					mov i, 0
			
					tantque:						;boucle while: z_r� + z_i� <4 et i<iteration_max
			
						mov result1, 0				;initialisation de variables n�cessaires aux calculs des formules
						mov result2, 0
						mov result3, 0
						
						fld i
						fild iteration_max
						fcomip st(0), st(1)
						fstp result2	
						jl fin_tantque
				
						fld tmp						;initialisation de tmp
						fadd z_r
						fstp tmp
				
						fld z_r						;formule z_r = z_r� - z_i� + c_r
						fmul z_r
						fld z_i
						fmul z_i
						fsubp st(1), st(0)
						fadd c_r
						fstp z_r
					
						fld z_i						;formule z_i = 2*z_i*tmp + c_i
						fimul deux
						fmul tmp
						fadd c_i
						fstp z_i

						inc i						;incr�mentation de i
						
						fld z_r						;formule z_r� + z_i�
						fmul z_r
						fld z_i
						fmul z_i
						fadd st(0), st(1)
						fstp result1
					
						cmp result1, 4				;condtion tant que
						jl fin_tantque
						
					fin_tantque:
			
					;si
					fld i
					fild iteration_max
					fcomip st(0), st(1)
					fstp result3
					je sinon
					;invoke SetPixel,hdc,x,y,00FF000h	; affiche un point � la coordonn�e (x,y) 	
			
					sinon:
						;invoke SetPixel,hdc,x,y,0F000FFh	; affiche un point � la coordonn�e (x,y) 	
			
					inc y
					
					mov result1, 0
					
					fld image_y
					fld y
					fcomip st(0), st(1)
					fstp result1
					jl fin_pour_y
					
				fin_pour_y:
				
				inc x
				
				mov result1, 0
				
				fld image_x
				fld x
				fcomip st(0), st(1)
				fstp result1
				jl fin_pour_x				
						
			fin_pour_x:
	
;	inkey  ; attente d'un appui de touche par l'utilisateur (met le programme en pause).
    
    push 0 
    call ExitProcess 
    
end start 