.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32rt.inc 

includelib \masm32\lib\kernel32.lib

	
	
.data
HelloWorld db "Hello World!",13,10,0
consoleTitle db "Assembleur",0 
exeName db "explorer.exe",0
.data?

.code 
start: 
    push offset exeName
    call GetModuleHandle 
    push offset consoleTitle
    call SetConsoleTitle 
    
    push 100000
    call Sleep 
    inkey "press a key to continue..."
    push 0 
    call ExitProcess 
end start 