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
ClassName_F db "SimpleWinClass",0 	; classe de type SimpleWinClass (fen�tre simple)
AppName  db "Assembleur projet",0 
Appxmi  db "Xmin",0 
Appxma  db "Xmax",0
Appymi  db "Ymin",0
Appyma  db "Ymax",0
Appit  db "Iteration",0

;bouton
ButtonClassName1 db "button",0	; classe de type button (bouton) 
ButtonText1 db "Dessinez",0 

ButtonClassName2 db "button",0	; classe de type button (bouton) 
ButtonText2 db "Reperage",0

ButtonClassName3 db "button",0	; classe de type button (bouton) 
ButtonText3 db "Remise a zero",0

EditClassName1 db "edit",0	; classe de type edit (zone d'�dition de texte) 

val	dd 1	; valeur avec laquelle on multipliera le contenu de l'EDIT

EditClassName2 db "edit",0	; classe de type edit (zone d'�dition de texte) 

EditClassName3 db "edit",0	; classe de type edit (zone d'�dition de texte) 

EditClassName4 db "edit",0	; classe de type edit (zone d'�dition de texte) 

EditClassName5 db "edit",0	; classe de type edit (zone d'�dition de texte) 


.data? 
x	dd	?
y	dd	?
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
;bouton
hwndButton HWND ?	; handle du bouton 
hwndEdit1 HWND ?	; handle de l'EDIT
hwndEdit2 HWND ?	; handle de l'EDIT
hwndEdit3 HWND ?	; handle de l'EDIT
hwndEdit4 HWND ?	; handle de l'EDIT
hwndEdit5 HWND ?	; handle de l'EDIT

buffer db 512 dup(?) 	; Buffer pour stocker le texte qu'on inscrit dans la bo�te d'�dition.


.const 
ButtonID equ 1         	; le n�ID du Control de type Button 
EditID equ 2           	; le n�ID du Control de type 'Zone d'�dition' (de saisie de texte) 

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
                        550,600,NULL,NULL, hInst,NULL 
    
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
    cmp uMsg,WM_CREATE	; � la cr�ation de la fen�tre
    je create	
    cmp uMsg,WM_COMMAND	; si message re�u d'un menu ou d'un contr�le (bouton, edit, liste...)
    je command
    cmp uMsg,WM_PAINT	; message WM_PAINT envoy� � chaque rafra�chissement de la fen�tre
    je paint
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam ; si aucun des messages pr�c�dents
    ret 
    
    destroy:
    	invoke PostQuitMessage,NULL
    	
    jmp fin_messages 


;bouton 
create:
    	invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName1,\
    	 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        100,475,50,25,hWnd,EditID,hInstance,NULL	; Cr�ation du contr�le EDIT 
        mov  hwndEdit1,eax 
        invoke SetFocus, hwndEdit1 ; mise en focus du contr�le EDIT
        
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName2,\ 
                       ADDR Appxma, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        160,475,50,25,hWnd,EditID,hInstance,NULL	; Cr�ation du contr�le EDIT 
        mov  hwndEdit2,eax 
        invoke SetFocus, hwndEdit2 ; mise en focus du contr�le EDIT
        
        
 		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName3,\ 
                        ADDR Appymi,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        220,475,50,25,hWnd,EditID,hInstance,NULL	; Cr�ation du contr�le EDIT 
        mov  hwndEdit3,eax 
        invoke SetFocus, hwndEdit3 ; mise en focus du contr�le EDIT
        
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName4,\ 
                        ADDR Appyma ,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        280,475,50,25,hWnd,EditID,hInstance,NULL	; Cr�ation du contr�le EDIT 
        mov  hwndEdit4,eax 
        invoke SetFocus, hwndEdit4 ; mise en focus du contr�le EDIT
        
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName5,\ 
                        ADDR Appit,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_CENTER or\ 
                        ES_AUTOHSCROLL,\ 
                        340,475,50,25,hWnd,EditID,hInstance,NULL	; Cr�ation du contr�le EDIT 
        mov  hwndEdit5,eax 
        invoke SetFocus, hwndEdit5 ; mise en focus du contr�le EDIT
 		
        invoke CreateWindowEx,NULL, ADDR ButtonClassName1,ADDR ButtonText1,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,500,140,25,hWnd,ButtonID,hInstance,NULL	; Cr�ation du contr�le BUTTON 
        mov  hwndButton,eax
        invoke CreateWindowEx,NULL, ADDR ButtonClassName2,ADDR ButtonText2,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        220,500,140,25,hWnd,ButtonID,hInstance,NULL	; Cr�ation du contr�le BUTTON 
        mov  hwndButton,eax
        invoke CreateWindowEx,NULL, ADDR ButtonClassName3,ADDR ButtonText3,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        365,500,140,25,hWnd,ButtonID,hInstance,NULL	; Cr�ation du contr�le BUTTON 
        mov  hwndButton,eax
   	jmp fin_messages
   	
    command:
        mov eax,wParam ; r�cup�ration de l'identifiant de l'exp�diteur dans eax.
        
        cmp lParam,0
        je fin_messages ; si lParam=0 alors le message vient d'un menu : on n'en a pas ici
    	
    	; lParam diff�rent de 0 donc message envoy� par un Control
    	cmp ax,ButtonID	; ax = mot de poids faible de wParam = ID du contr�le qui a envoy� le message
        jne fin_messages ; si ce n'est pas le bouton qui a envoy� le message
 		
 			; si ax=ButtonID
        	shr eax,16 ; rotation de 16 bits � droite (poids fort devient poids faible : ax = poids fort)
           	cmp ax,BN_CLICKED	; mot de poids fort de wParam = code de notification du contr�le
        	jne fin_messages ; si ce n'est pas un clic sur le bouton qui a envoy� le message
       			; si ax=BN_CLICKED
       			invoke GetWindowText,hwndEdit1,ADDR buffer,512	; r�cup�ration du contenu de l'EDIT dans buffer
        		invoke atol, addr buffer	; conversion du contenu du buffer en DWORD dans eax 
       			mul val	; eax = eax * val
      			invoke dwtoa, eax, addr buffer ; conversion de eax en cha�ne de caract�res dans buffer
      			invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK ; cr�aton d'une MessageBox avec buffer comme texte 
    
   
    paint:
    	   	invoke BeginPaint, hWnd, ADDR ps	; lance le dessin de la fen�tre
			mov hdc, eax	; BeginPaint retourne le handle du contexte o� on dessine
			
			mov x,0
			mov y,0
			boucle:;travailler ici!!!!!!!!!!!
				invoke SetPixel,hdc,x,y,0FF00FFh	; affiche un point � la coordonn�e (x,y) 
													; de couleur FF00FF (BBVVRR) 
													; o� BB=niveau de bleu sur 2 octets
													; o� VV=niveau de vert sur 2 octets
													; o� RR=niveau de rouge sur 2 octets
				inc x
				inc y
				cmp x,450
				jne boucle
				
        	invoke EndPaint, hWnd, ADDR ps ; fin du dessin de la fen�tre
        	
    fin_messages:
    xor    eax,eax 
    ret 
WndProc endp 
      	
end start