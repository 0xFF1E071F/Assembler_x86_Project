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
	ClassName	db "Parent Claas Name",0
	ClassName_F db "SimpleWinClass",0 	; classe de type SimpleWinClass (fenêtre simple)
	AppName  db "Assembleur projet",0 

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
	x	dd	?
	y	dd	?
	hInstance HINSTANCE ? 
	CommandLine LPSTR ? 

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
	mov   	wc.style, CS_HREDRAW or CS_VREDRAW ; style de la fenêtre : redessinée si redim. ou mouv. horizontal ou vertical
	mov   	wc.lpfnWndProc, OFFSET WndProc	;pointeur vers la fonction de gestion de la fenêtre
	mov   	wc.cbClsExtra, NULL	; nombre de bits supplémentaires à allouer après la window class
	mov   	wc.cbWndExtra, NULL	; nombre de bits supplémentaires à allouer après l'instance de fenêtre
	push  	hInst 
    pop   	wc.hInstance ; un handle de l'instance qui contient la fonction de gestion de la fenêtre
	mov   	wc.hbrBackground, COLOR_WINDOW+1	; handle de la class backgroune brush utilisé pour le fond de la fenêtre
	mov   	wc.lpszMenuName, NULL	; pointeur vers une chaîne précisant le nom de la ressource menu name
	mov   	wc.lpszClassName, OFFSET ClassName ; pointeur vers le nom de la classe de la fenêtre
	
    invoke 	LoadIcon, NULL, IDI_APPLICATION ; arg1=handle vers le module contenant l'icone à charger, NULL pour une icone prédéfinie, arg2=nom del'icone à charger ou icone prédéfinie 
	
	mov   	wc.hIcon, eax	; un handle de la classe icon (vers une ressource de type icon)
	mov   	wc.hIconSm, eax	; un handle de la classe small icon (vers une ressource de type icon)
	
	invoke 	LoadCursor, NULL, IDC_ARROW	; arg1=handle vers le module contenant le curseur à charger, NULL pour un curseur prédéfini, arg2=nom du curseur à charger ou curseur prédéfini
	
	mov   	wc.hCursor, eax	; un handle de la classe cursor (vers une ressource de type cursor)
	
	invoke 	RegisterClassEx, addr wc	; enregistre la window class définie au-dessus

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW + WS_HSCROLL + WS_VSCROLL,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        450,450,NULL,NULL, hInst,NULL 
    
    mov   	hwnd, eax	; eax=valeur de retour de CreateWindowEx, copiée dans hwnd 
    
	invoke 	ShowWindow, hwnd, SW_SHOWNORMAL ; handle de la fenêtre
											; mode d'affichage de la fenêtre
    
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
    
    cmp uMsg,WM_DESTROY	; demande de fermeture de la fenêtre (clic sur croix rouge)
    je destroy
    cmp uMsg,WM_PAINT	; message WM_PAINT envoyé à chaque rafraîchissement de la fenêtre
    je paint
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; si aucun des messages précédents
    ret 
    
    destroy:
    	invoke PostQuitMessage,NULL
    	
    jmp fin_messages 

    paint:
    	   	invoke BeginPaint, hWnd, ADDR ps	; lance le dessin de la fenêtre
			mov hdc, eax	; BeginPaint retourne le handle du contexte où on dessine
			
			mov x,0
			mov y,0	
				
			;initialisation d'image_x
			mov image_x, x2
			sub image_x, x1
			mul image_x, zoom
	
			;initialisation d'image_y
			mov image_y, y2
			sub image_y, y1
			mul image_y, zoom
	
			;boucle for: tant que x< image_x par pas de 1
			pour_x:
				cmp x, image_x
				jl fin_pour_x
		
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
					invoke SetPixel,hdc,x,y,0FF00FFh		; affiche un point à la coordonnée (x,y) 
													; de couleur FF00FF (BBVVRR) 
													; où BB=niveau de bleu sur 2 octets
													; où VV=niveau de vert sur 2 octets
													; où RR=niveau de rouge sur 2 octets
				
				
					sinon:
						;dessiner avec couleur
			
			
				inc y
		
			fin_pour_y:
		
			inc x
		
		fin_pour_x:
				
       	invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fenêtre
        	
    fin_messages:
    xor    eax,eax 
    ret 
WndProc endp 
      	
end start