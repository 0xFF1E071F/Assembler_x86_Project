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
AppName  db "Fenêtre de dessin",0
X1 real8 -2.1
x2 real8 0.6
y1 real8 -1.2
y2 real8 1.2
zoom real8 50.0
iteration_max dd 50
plus dd 1
fois dd 2



.data? 
x	dd	?
y	dd	?
xx dd ?
yy dd ?
image_x	dd ?
image_y  dd ?
c_r dd ?
c_i dd ?
z_r dd ?
z_i dd ?
i dd ?
tmp dd ?
comparaison dd ?
r2 dd ?
i2 dd ?
color dd ?
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
			mov color, 0000FFh
			
			fld x2
	fsub X1
	fmul zoom
	fstp  image_x
	
	fld y2
	fsub y1
	fmul zoom
	fstp image_y
	
	mov xx,0
	mov yy,0
	boucle:
	mov eax,xx
	cmp eax,image_x
	jae fin
		boucle2:
		mov eax,yy
		cmp eax,image_y
		jae fin2
		fld xx
		fdiv zoom
		fadd X1
		fstp c_r
		fld yy
		fdiv zoom
		fadd y1
		fstp c_i
		mov z_r,0
		mov z_i,0
		mov i,0
			boucle3:
	
			fild z_r
			fstp tmp
			fild z_i
			fimul z_i
			fist i2
			fild z_r
			fimul z_r
			fisub i2
			fiadd c_r
			fist r2
			fistp z_r
			fild tmp
			fimul z_i
			fimul fois
			fiadd c_i
			fist i2
			fistp z_i
			fild i
			fiadd plus
			fistp i
			fild r2
			fiadd i2
			fistp comparaison
			mov eax,comparaison
			cmp eax,4
			jae si1
			mov eax,i
			cmp eax,iteration_max
			jae si1
			jmp boucle3
			
			si1:
			mov eax,i
			cmp eax,iteration_max
			je si2
			jne fin3
			si2:
			
		fin3:
		fild yy
		fiadd plus
		fistp yy
		jmp boucle2
	fin2:
	fild xx
	fiadd plus
	fistp xx
	jmp boucle
	
	fin:
	
				
        	invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fenêtre
        	
    fin_messages:
    xor    eax,eax 
    ret 
WndProc endp 
      	
end start