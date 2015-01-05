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
AppName  db "Fractale de Mandelbrot	",0
x1 real4 -2.5
x2 real4 2.5
y1 real4 -1.2
y2 real4 1.2
plus dd 1
fois dd 2
tet dd 4



.data? 
x	dd	?
y	dd	?
image_x	real4 ?
image_y  real4 ?
c_r real4 ?
c_i real4 ?
z_r real4 ?
z_i real4 ?
i dd ?
tmp real4 ?
compa dd ?
depile dd ?
r2 real4 ?
i2 real4 ?
zoom dd ?
iteration_max dd ?
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
                        1280,720,NULL,NULL, hInst,NULL 
    
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
			mov color,0ECC426h
			mov zoom,300
        	mov iteration_max,30
				
        	;invoke EndPaint, hWnd, ADDR ps  ;fin du dessin de la fenêtre
			
	fld x2; st(0)=x2
	fsub x1; st(0)=x2-x1
	fimul zoom; st(0)=(x2-x1)*zoom0
	fstp image_x; image_x=(x2-x1)*zoom
	;Pile vide
	fld y2; st(0)=y2
	fsub y1; st(0)=y2-y1
	fimul zoom; st(0)=(y2-y1)*zoom
	fstp image_y;  image_y=(y2-y1)*zoom
	;Pile vide
	
	mov x,0
	
	boucle:
	mov y,0
	
		boucle2:
		fild x; st(0)=x
		
		fidiv zoom; st(0)=x/zoom
		
		fadd x1; st(0)=x/zoom + x1
		
		fstp c_r; c_r=x/zoom + x1, pile vide
		
		fild y; st(0)=y
		
		fidiv zoom; st(0)=y/zoom
		
		fadd y1; st(0)=y/zoom + y1
		
		fstp c_i; c_i=y/zoom + y1, pile vide
		
		fldz; st(0)=0
		
		fst z_r; z_r=0
		
		fst z_i; z_i=0
		
		fistp i; i=0, pile vide
		
			boucle3:
			
			fld z_r; st(0)=z_r
			
			fst tmp; tmp=z_r, st(0)=z_r
			
			fmul z_r; st(0)=z_r*z_r
			
			fst r2; r2=z_r*z_r, st(0)=z_r*z_r
			
			fld z_i; st(0)=z_i, st(1)=z_r²
			
			fmul z_i; st(0)=z_i², st(1)=z_r²
			
			fstp i2; i2=z_i², st(0)=z_r²
			
			fsub i2; st(0)=z_r²-z_i²
			
			fadd c_r; st(0)=z_r²-z_i²+c_r
			
			fstp z_r; z_r=z_r²-z_i²+c_r, pile vide
			
			fld tmp; st(0)=tmp
			
			fmul z_i; st(0)=tmp*z_i
			
			fimul fois; st(0)=tmp*z_i*2
			
			fadd c_i; st(0)=tmp*z_i*2+c_i
			
			fstp z_i; z_i=tmp*z_i*2+c_i, pile vide
			
			inc i
			
			fld r2; st(0)=r2
			
			fld i2; st(0)=i2, st(0)=r2
			
			faddp st(1),st(0); st(0)=r2+i2
			
			fild tet; st(0)=tet, st(1)=r2+i2
			
			fcomip st(0),st(1); st(0)=r2+i2
			
			ja si1
			
			jmp si2
			
			si1:
			fistp depile; depile=r2+i2, pile vide
			fild i; st(0)=i
			fild iteration_max; st(0)=iteration_max, st(1)=i
			fcomip st(0),st(1); st(0)=i
			jbe si2
			fistp depile; depile=i, pile vide
			jmp boucle3
			
			si2:
			fistp depile; depile=i, pile vide
			fild i; st(0)=i
			fild iteration_max; st(0)=iteration_max, st(1)=i
			fcomip st(0),st(1); st(0)=i
			jne colorfond
			
			invoke SetPixel, hdc, x, y, 00F0FFFh
			
			colorfond:
			invoke SetPixel, hdc, x, y, 000000h
		fin3:
		fistp depile; depile=i, pile vide
		fild y; st(0)=y
		fld image_y; st(0)=image_y, st(1)=y
		fcomip st(0),st(1); st(0)=y
		jbe fin2
		fistp depile; depile=y, pile vide
		inc y
		jmp boucle2
		
	fin2:
	fistp depile; depile=y, pile vide

	fild x; st(0)=x
	fld image_x; st(0)=image_x, st(1)=x
	fcomip st(0),st(1); st(0)=x
	jbe fin
	fistp depile; depile=x, pile vide
	inc x
	jmp boucle
	
	fin:
	fistp depile; poubelle=x, pile vide

	
	
	
		.while
			
		.endw
        	
    fin_messages:
    xor    eax,eax 
    ret 
WndProc endp 
      	
end start