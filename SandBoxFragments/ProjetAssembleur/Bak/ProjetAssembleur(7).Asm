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
	ClassName_F 	db 		"SimpleWinClass",0 			; classe de type SimpleWinClass (fenêtre simple)
	AppName  		db 		"Assembler Project",0 
	Appxmi  		db 		"Xmin",0 
	Appxma  		db 		"Xmax",0
	Appymi  		db 		"Ymin",0
	Appyma  		db 		"Ymax",0
	Appit  			db 		"Iteration",0

	x1				REAL8 	-2.1
	x2				REAL8 	0.6
	y1				REAL8 	-1.2
	y2				REAL8 	1.2
	
	image_x			REAL8	270.0
	image_y			REAL8 	240.0
	
	zoom			dd 		100
	iteration_max 	dd 		50
	deux 			dd 		2
	quatre			dd		4

	;bouton
	ButtonClassName1 db 	"button",0					; classe de type button (bouton) 
	ButtonText1 	db 		"Dessinez",0 
	
	ButtonClassName2 db 	"button",0					; classe de type button (bouton) 
	ButtonText2 	db 		"Reperage",0
	
	ButtonClassName3 db 	"button",0					; classe de type button (bouton) 
	ButtonText3 	db 		"Remise a zero",0
	
	val				dd 		1							; valeur avec laquelle on multipliera le contenu de l'EDIT
	
	EditClassName1 	db 		"edit",0					; classe de type edit (zone d'édition de texte) 
	EditClassName2 	db 		"edit",0					; classe de type edit (zone d'édition de texte) 
	EditClassName3 	db 		"edit",0					; classe de type edit (zone d'édition de texte) 
	EditClassName4 	db 		"edit",0					; classe de type edit (zone d'édition de texte) 
	EditClassName5 	db 		"edit",0					; classe de type edit (zone d'édition de texte) 
	
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
	
	hInstance HINSTANCE 	? 
	CommandLine LPSTR 		? 
	
	;bouton
	hwndButton 		HWND 	?							; handle du bouton 
	hwndEdit1 		HWND 	?							; handle de l'EDIT
	hwndEdit2 		HWND 	?							; handle de l'EDIT
	hwndEdit3 		HWND 	?							; handle de l'EDIT
	hwndEdit4 		HWND 	?							; handle de l'EDIT
	hwndEdit5 		HWND 	?							; handle de l'EDIT

	buffer 			db 		512 dup(?) 					; Buffer pour stocker le texte qu'on inscrit dans la boîte d'édition.
	buffer2 		db		512 dup(?)
	buffer3 		db 		512 dup(?)
	buffer4 		db 		512 dup(?)
	buffer5 		db 		512 dup(?)

.const 
	ButtonID 		equ 	1         					; le n°ID du Control de type Button 
	EditID 			equ 	2          					; le n°ID du Control de type 'Zone d'édition' (de saisie de texte) 
	ButtonID2 		equ 	1   						; le n°ID du Control de type Button 
	ButtonID3 		equ 	1   						; le n°ID du Control de type Button 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    	hInstance,eax 
    invoke GetCommandLine
    mov 	CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    
    mov   	wc.cbSize, SIZEOF WNDCLASSEX				; taille de la structure de la window class
	mov   	wc.style, CS_HREDRAW or CS_VREDRAW 			; style de la fenêtre : redessinée si redim. ou mouv. horizontal ou vertical
	mov   	wc.lpfnWndProc, OFFSET WndProc				;pointeur vers la fonction de gestion de la fenêtre
	mov   	wc.cbClsExtra, NULL							; nombre de bits supplémentaires à allouer après la window class
	mov   	wc.cbWndExtra, NULL							; nombre de bits supplémentaires à allouer après l'instance de fenêtre
	push  	hInst 
    pop   	wc.hInstance 								; un handle de l'instance qui contient la fonction de gestion de la fenêtre
	mov   	wc.hbrBackground, COLOR_WINDOW+1			; handle de la class backgroune brush utilisé pour le fond de la fenêtre
	mov   	wc.lpszMenuName, NULL						; pointeur vers une chaîne précisant le nom de la ressource menu name
	mov   	wc.lpszClassName, OFFSET ClassName 			; pointeur vers le nom de la classe de la fenêtre
	
    invoke 	LoadIcon, NULL, IDI_APPLICATION				 ; arg1=handle vers le module contenant l'icone à charger, NULL pour une icone prédéfinie, arg2=nom del'icone à charger ou icone prédéfinie 
	
	mov   	wc.hIcon, eax								; un handle de la classe icon (vers une ressource de type icon)
	mov   	wc.hIconSm, eax								; un handle de la classe small icon (vers une ressource de type icon)
	
	invoke 	LoadCursor, NULL, IDC_ARROW					; arg1=handle vers le module contenant le curseur à charger, NULL pour un curseur prédéfini, arg2=nom du curseur à charger ou curseur prédéfini
	
	mov   	wc.hCursor, eax								; un handle de la classe cursor (vers une ressource de type cursor)
	
	invoke 	RegisterClassEx, addr wc					; enregistre la window class définie au-dessus

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW + WS_HSCROLL + WS_VSCROLL,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        550,600,NULL,NULL, hInst,NULL 
    
    mov   	hwnd, eax									; eax=valeur de retour de CreateWindowEx, copiée dans hwnd 
    
	invoke 	ShowWindow, hwnd, SW_SHOWNORMAL 			; handle de la fenêtre
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
    
    cmp uMsg,WM_DESTROY									; demande de fermeture de la fenêtre (clic sur croix rouge)
    je destroy
    cmp uMsg,WM_CREATE									; à la création de la fenêtre
    je create	
    cmp uMsg,WM_COMMAND									; si message reçu d'un menu ou d'un contrôle (bouton, edit, liste...)
    je command
    cmp uMsg,WM_PAINT									; message WM_PAINT envoyé à chaque rafraîchissement de la fenêtre
    je paint
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam 		; si aucun des messages précédents
    ret 
    
    destroy:
    	invoke PostQuitMessage,NULL
    	
    jmp fin_messages 


	;bouton 
	create:
    	invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName1,\
    	 
                        ADDR Appxmi,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        100,475,50,25,hWnd,EditID,hInstance,NULL	; Création du contrôle EDIT 
        mov  hwndEdit1,eax 
        invoke SetFocus, hwndEdit1 						; mise en focus du contrôle EDIT
        
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName2,\ 
                       ADDR Appxma, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        160,475,50,25,hWnd,EditID,hInstance,NULL	; Création du contrôle EDIT 
        mov  hwndEdit2,eax 
        invoke SetFocus, hwndEdit2 						; mise en focus du contrôle EDIT
        
        
 		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName3,\ 
                        ADDR Appymi,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        220,475,50,25,hWnd,EditID,hInstance,NULL	; Création du contrôle EDIT 
        mov  hwndEdit3,eax 
        invoke SetFocus, hwndEdit3 						; mise en focus du contrôle EDIT
        
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName4,\ 
                        ADDR Appyma ,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        280,475,50,25,hWnd,EditID,hInstance,NULL	; Création du contrôle EDIT 
        mov  hwndEdit4,eax 
        invoke SetFocus, hwndEdit4 						; mise en focus du contrôle EDIT
        
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName5,\ 
                        ADDR Appit,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        340,475,50,25,hWnd,EditID,hInstance,NULL	; Création du contrôle EDIT 
        mov  hwndEdit5,eax 
        invoke SetFocus, hwndEdit5 						; mise en focus du contrôle EDIT
 		
        invoke CreateWindowEx,NULL, ADDR ButtonClassName1,ADDR ButtonText1,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,500,140,25,hWnd,ButtonID,hInstance,NULL	; Création du contrôle BUTTON 
        mov  hwndButton,eax
        invoke CreateWindowEx,NULL, ADDR ButtonClassName2,ADDR ButtonText2,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        220,500,140,25,hWnd,ButtonID2,hInstance,NULL	; Création du contrôle BUTTON 
        mov  hwndButton,eax
        invoke CreateWindowEx,NULL, ADDR ButtonClassName3,ADDR ButtonText3,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        365,500,140,25,hWnd,ButtonID3,hInstance,NULL	; Création du contrôle BUTTON 
        mov  hwndButton,eax
   	jmp fin_messages
   	
    command:
        mov eax,wParam 								; récupération de l'identifiant de l'expéditeur dans eax.
        
        cmp lParam,0
        je fin_messages 							; si lParam=0 alors le message vient d'un menu : on n'en a pas ici
    												; lParam différent de 0 donc message envoyé par un Control
    	cmp ax,ButtonID								; ax = mot de poids faible de wParam = ID du contrôle qui a envoyé le message
        jne fin_messages 							; si ce n'est pas le bouton qui a envoyé le message
 													; si ax=ButtonID
        	shr eax,16 								; rotation de 16 bits à droite (poids fort devient poids faible : ax = poids fort)
           	cmp ax,BN_CLICKED						; mot de poids fort de wParam = code de notification du contrôle
        	jne fin_messages 						; si ce n'est pas un clic sur le bouton qui a envoyé le message
       												; si ax=BN_CLICKED
       			invoke GetWindowText,hwndEdit1,ADDR buffer,512		; récupération du contenu de l'EDIT dans buffer
        		invoke atol, addr buffer							; conversion du contenu du buffer en DWORD dans eax 
       			invoke GetWindowText,hwndEdit2,ADDR buffer2,512		; récupération du contenu de l'EDIT dans buffer
        		invoke atol, addr buffer2							; conversion du contenu du buffer en DWORD dans eax 
      			invoke GetWindowText,hwndEdit3,ADDR buffer2,512		; récupération du contenu de l'EDIT dans buffer
        		invoke atol, addr buffer3							; conversion du contenu du buffer en DWORD dans eax 
        		invoke GetWindowText,hwndEdit4,ADDR buffer2,512		; récupération du contenu de l'EDIT dans buffer
        		invoke atol, addr buffer4							; conversion du contenu du buffer en DWORD dans eax 
        		invoke GetWindowText,hwndEdit5,ADDR buffer2,512		; récupération du contenu de l'EDIT dans buffer
        		invoke atol, addr buffer5							; conversion du contenu du buffer en DWORD dans eax 
      			
    paint:
    	invoke BeginPaint, hWnd, ADDR ps			; lance le dessin de la fenêtre
		mov hdc, eax								; BeginPaint retourne le handle du contexte où on dessine
				
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
			
			mov x, 0
						
			pour_x:										;boucle for: tant que x< image_x par pas de 1
				
				mov y, 0
											
				pour_y:								;boucle for: tant que y<image_y par pas de 1
					
					fld c_r							;definition du c réel
					fiadd x
					fidiv zoom
					fadd x1
					fstp c_r
				
					fld c_i							;définition du c iréel
					fiadd y
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
						
						fild i
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
					fild i
					fild iteration_max
					fcomip st(0), st(1)
					fstp result4
					je sinon
						invoke SetPixel,hdc,x,y,00FF000h	; affiche un point à la coordonnée (x,y) 	
						jmp suite_si
						
					sinon:
						invoke SetPixel,hdc,x,y,0F000FFh	; affiche un point à la coordonnée (x,y) 	
				
					suite_si:
					inc y
					
					fldz
					fstp result1
					
					fld image_y
					fild y
					fcomip st(0), st(1)
					fstp result1
					jl pour_y
				
				inc x
				
				fldz
				fstp result1
				
				fld image_x
				fild x
				fcomip st(0), st(1)
				fstp result1
				jl pour_x				
	
        invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fenêtre
        	
   	fin_messages:
    	xor    eax,eax 
    	ret 
	WndProc endp 
      	
end start