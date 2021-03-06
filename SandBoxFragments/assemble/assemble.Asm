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

	ps	PAINTSTRUCT	<0>
	hdc	HDC	0
	ClassName		db 		"Parent Claas Name",0
	ClassName_F 	db 		"SimpleWinClass",0 	; classe de type SimpleWinClass (fen�tre simple)
	AppName  		db 		"Assembler Project",0 
	Appxmi  		db 		"Xmin",0 
	Appxma  		db 		"Xmax",0
	Appymi  		db 		"Ymin",0
	Appyma  		db 		"Ymax",0
	Appit  			db 		"Iteration",0

	x1				REAL4 	-2.1
	x2				REAL4 	0.6
	y1				REAL4 	-1.2
	y2				REAL4 	1.2
	
	zoom			dd 		100
	iteration_max 	dd 		50
	deux 			dd 		2

	;bouton
	ButtonClassName1 db 	"button",0	; classe de type button (bouton) 
	ButtonText1 	db 		"Dessinez",0 
	
	ButtonClassName2 db 	"button",0	; classe de type button (bouton) 
	ButtonText2 	db 		"Reperage",0
	
	ButtonClassName3 db 	"button",0	; classe de type button (bouton) 
	ButtonText3 	db 		"Remise a zero",0
	
	EditClassName1 	db 		"edit",0	; classe de type edit (zone d'�dition de texte) 
	
	val				dd 		1	; valeur avec laquelle on multipliera le contenu de l'EDIT
	
	EditClassName2 	db 		"edit",0	; classe de type edit (zone d'�dition de texte) 
	
	EditClassName3 	db 		"edit",0	; classe de type edit (zone d'�dition de texte) 
	
	EditClassName4 	db 		"edit",0	; classe de type edit (zone d'�dition de texte) 
	
	EditClassName5 	db 		"edit",0	; classe de type edit (zone d'�dition de texte) 
	
.data? 
	z_r 			REAL4 	?
	z_i 			REAL4 	?
	c_r 			REAL4 	?
	c_i 			REAL4 	?
	tmp				REAL4 	?
	i 				REAL4 	?
	
	x				REAL4 	?
	y				REAL4 	?
	
	image_x			REAL4 	?
	image_y			REAL4 	?
	
	result1			REAL4 	?
	result2			REAL4 	?
	
	hInstance HINSTANCE 	? 
	CommandLine LPSTR 		?


.const 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    
    mov   	wc.cbSize, SIZEOF WNDCLASSEX	; taille de la structure de la window class
	mov   	wc.style, CS_HREDRAW or CS_VREDRAW ; style de la fen�tre : redessin�e si redim. ou mouv. horizontal ou vertical
	mov   	wc.lpfnWndProc, OFFSET WndProc	;pointeur vers la fonction de gestion de la fen�tre
	mov   	wc.cbClsExtra, NULL	; nombre de bits suppl�mentaires � allouer apr�s la window class
	mov   	wc.cbWndExtra, NULL	; nombre de bits suppl�mentaires � allouer apr�s l'instance de fen�tre
	push  	hInst 
    pop   	wc.hInstance ; un handle de l'instance qui contient la fonction de gestion de la fen�tre
	mov   	wc.hbrBackground, COLOR_WINDOW+1	; handle de la class backgroune brush utilis� pour le fond de la fen�tre
	mov   	wc.lpszMenuName, NULL	; pointeur vers une cha�ne pr�cisant le nom de la ressource menu name
	mov   	wc.lpszClassName, OFFSET ClassName ; pointeur vers le nom de la classe de la fen�tre
	
    invoke 	LoadIcon, NULL, IDI_APPLICATION ; arg1=handle vers le module contenant l'icone � charger, NULL pour une icone pr�d�finie, arg2=nom del'icone � charger ou icone pr�d�finie 
	
	mov   	wc.hIcon, eax	; un handle de la classe icon (vers une ressource de type icon)
	mov   	wc.hIconSm, eax	; un handle de la classe small icon (vers une ressource de type icon)
	
	invoke 	LoadCursor, NULL, IDC_ARROW	; arg1=handle vers le module contenant le curseur � charger, NULL pour un curseur pr�d�fini, arg2=nom du curseur � charger ou curseur pr�d�fini
	
	mov   	wc.hCursor, eax	; un handle de la classe cursor (vers une ressource de type cursor)
	
	invoke 	RegisterClassEx, addr wc	; enregistre la window class d�finie au-dessus

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW + WS_HSCROLL + WS_VSCROLL,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        450,450,NULL,NULL, hInst,NULL 
    
    mov   	hwnd, eax	; eax=valeur de retour de CreateWindowEx, copi�e dans hwnd 
    
	invoke 	ShowWindow, hwnd, SW_SHOWNORMAL ; handle de la fen�tre
											; mode d'affichage de la fen�tre
    
    messages:
        invoke GetMessage, ADDR msg,NULL,0,0 
        cmp eax,0
        jle fin_boucle 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    jmp messages
    fin_boucle:
    mov     eax,msg.wParam 
    ret 
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    
    cmp uMsg,WM_DESTROY	; demande de fermeture de la fen�tre (clic sur croix rouge)
    je destroy
    cmp uMsg,WM_PAINT	; message WM_PAINT envoy� � chaque rafra�chissement de la fen�tre
    je paint
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; si aucun des messages pr�c�dents
    ret 
    
    destroy:
    	invoke PostQuitMessage,NULL
    	
    jmp fin_messages 

    paint:
    	invoke BeginPaint, hWnd, ADDR ps	; lance le dessin de la fen�tre
		mov hdc, eax	; BeginPaint retourne le handle du contexte o� on dessine
			
		mov x,0
		mov y,0
				
		;initialisation d'image_x
		fld image_x
		fadd x2
		fsub x1
		fimul zoom
		fstp image_x
	
		;initialisation d'image_y
		fld image_y
		fadd y2
		fsub y1
		fimul zoom
		fstp image_y
	
		;boucle for: tant que x< image_x par pas de 1
		pour_x:
			mov result1, 0
		
			fld image_x
			fld x
			fcomip st(0), st(1)
			fstp result1
			jl fin_pour_x
		
			;boucle for: tant que y<image_y par pas de 1
			pour_y:
		
				;definition du c r�el
				fld c_r
				fadd x
				fidiv zoom
				fadd x1
				fstp c_r
			
				;d�finition du c ir�el
				fld c_i
				fadd y
				fidiv zoom
				fadd y1
				fstp c_i
			
				;initialisation de variables
				mov z_r, 0
				mov z_i, 0
				mov i, 0
			
				;boucle while: z_r� + z_i� <4 et i<iteration_max
				tantque:
			
					;initialisation de variables n�cessaires aux calculs des formules
					mov result1, 0
					mov result2, 0
				
					;formule z_r� + z_i�
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
				
					;formule z_r = z_r� - z_i� + c_r
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
				
					;incr�mentation de i
					inc i
			
				fin_tantque:
			
				;si
				fld i
				fild iteration_max
				fcomip st(0), st(1)
				fstp result2
				invoke SetPixel,hdc,x,y,0FF00FFh		; affiche un point � la coordonn�e (x,y) 
													; de couleur FF00FF (BBVVRR) 
													; o� BB=niveau de bleu sur 2 octets
													; o� VV=niveau de vert sur 2 octets
													; o� RR=niveau de rouge sur 2 octets
			

				inc y
		
			fin_pour_y:
		
			inc x
		
		fin_pour_x:
				
        invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fen�tre
        	
   	fin_messages:
    	xor    eax,eax 
    	ret 
	WndProc endp 
      	
      	
end start