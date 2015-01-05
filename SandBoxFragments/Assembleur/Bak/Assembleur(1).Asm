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
	x1				REAL8 	-2.1
	x2				REAL8 	0.6
	y1				REAL8 	-1.2
	y2				REAL8 	1.2
	
	image_x			dd	 	270
	image_y			dd	 	240
	
	zoom			dd 		100
	iteration_max 	dd 		50
	deux 			dd 		2
	quatre			dd		4
	
.data? 
	z_r 			REAL8 	?
	z_i 			REAL8 	?
	c_r 			REAL8 	?
	c_i 			REAL8 	?
	tmp				REAL8 	?
	
	i 				dd	 	?
	x				dd 		?
	y				dd 		?
	
	result1			REAL8 	?
	result2			REAL8 	?
	result3			REAL8 	?
	result4			REAL8 	?
	result5			REAL8 	?
	
.code 

start: 
	
	mov x, 0
				
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
					
					fld c_r							;definition du c réel
					fadd x
					fidiv zoom
					fadd x1
					fstp c_r
				
					fld c_i							;définition du c iréel
					fadd y
					fidiv zoom
					fadd y1
					fstp c_i
			
					fldz							;initialisation de variables
					fst z_r
					fstp z_i
					mov i, 0
			
					tantque:						;boucle while: z_r² + z_i² <4 et i<iteration_max
			
						fldz						;initialisation de variables nécessaires aux calculs des formules
						fst result1
						fst result2
						fst result3
						fstp result4
						
						fld i
						fild iteration_max
						fcomip st(0), st(1)
						fstp result2	
						jl fin_tantque
				
						fld tmp						;initialisation de tmp
						fadd z_r
						fstp tmp
				
						fld z_r						;formule z_r = z_r² - z_i² + c_r
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

						inc i						;incrémentation de i
						
						fld z_r						;formule z_r² + z_i²
						fmul z_r
						fld z_i
						fmul z_i
						fadd st(0), st(1)
						fstp result1
								
						fld result1					;condtion tant que
						fld quatre
						fcomip st(0), st(1)
						fstp result3
						jl fin_tantque
						
					fin_tantque:
			
					;si
					fld i
					fild iteration_max
					fcomip st(0), st(1)
					fstp result4
					je sinon
					;invoke SetPixel,hdc,x,y,00FF000h	; affiche un point à la coordonnée (x,y) 	
			
					sinon:
						;invoke SetPixel,hdc,x,y,0F000FFh	; affiche un point à la coordonnée (x,y) 	
			
					inc y
					
					fldz
					fstp result1
					
					fld image_y
					fld y
					fcomip st(0), st(1)
					fstp result1
					jl fin_pour_y
					
				fin_pour_y:
				
				inc x
				
				fldz
				fstp result1
				
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