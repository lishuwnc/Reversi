;Reversi_main
;Author: wangningchen, wangchengpeng
;Create: 2015/3/18
;Last modify: 2015/3/18
;Main logic entry

;--------------------------------------------------------------------------
include \masm32\include\masm32rt.inc

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
include logic.inc


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
IDB_MAIN   equ 1
IDB_BITMAP1 equ 101	;background
IDB_BITMAP2 equ 102 ;Black
IDB_BITMAP3 equ 103 ;White

.data
weightMatrix DWORD 8, 1, 6, 5, 5, 6, 1, 8
             DWORD 1, 1, 5, 4, 4, 5, 1, 1
			 DWORD 6, 5, 3, 2, 2, 3, 5, 6
			 DWORD 5, 4, 2, 1, 1, 2, 4, 5
			 DWORD 5, 4, 2, 1, 1, 2, 4, 5
			 DWORD 6, 5, 3, 2, 2, 3, 5, 6
			 DWORD 1, 1, 5, 4, 4, 5, 1, 1
			 DWORD 8, 1, 6, 5, 5, 6, 1, 8 
ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "��Ů�� Ů��Ů ľ��",0
intX db 0
intY db 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hBitmap1 dd ?
hBitmap2 dd ?
hBitmap3 dd ?

gridLen dd 50		;the length of grid
gridOffsetX dd 50	;offset x to window
gridOffsetY dd 50	;offset y to window

;--------------------------------------------------------------------------
.code
start:
	

	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

	;call main

	exit



WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND

	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW  and  not WS_MAXIMIZEBOX and not WS_THICKFRAME,50,\ ;CW_USEDEFAULT,\
           50,670,489,NULL,NULL,\
           hInst,NULL

	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   LOCAL rect:RECT
   LOCAL pos:POINT

   .if uMsg==WM_CREATE
	  invoke LoadBitmap,hInstance,IDB_BITMAP1
      mov hBitmap1,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP2
      mov hBitmap2,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP3
      mov hBitmap3,eax
	  
   .elseif uMsg==WM_PAINT
      invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
      invoke SelectObject,hMemDC,hBitmap1
      invoke GetClientRect,hWnd,addr rect
      invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY

	  ;invoke SelectObject,hMemDC,hBitmap2
      ;invoke GetClientRect,hWnd,addr rect
      ;invoke BitBlt,hdc,100,100,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
	  ;invoke BitBlt,hdc,150,100,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
	  ;invoke BitBlt,hdc,200,100,rect.right,rect.bottom,hMemDC,0,0,SRCAND
	  ;
	  ;invoke SelectObject,hMemDC,hBitmap3
      ;invoke GetClientRect,hWnd,addr rect
      ;invoke BitBlt,hdc,250,100,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
	  ;invoke BitBlt,hdc,300,100,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
	  ;invoke BitBlt,hdc,350,100,rect.right,rect.bottom,hMemDC,0,0,SRCAND
      invoke DeleteDC,hMemDC

	.elseif uMsg == WM_LBUTTONDOWN

	  invoke GetClientRect,hWnd,addr rect
	  invoke InvalidateRect, hWnd, addr rect, 0

	  invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
	  invoke SelectObject,hMemDC,hBitmap2

	  invoke GetCursorPos,addr pos
	  invoke ScreenToClient,hWnd,addr pos


	  .if pos.x > 50 && pos.y > 50
		sub pos.x, 50
		sub pos.y, 50
	  .else
	    ret
	  .endif

	  push eax
	  mov eax, 0
	  .while pos.x > 46
		sub pos.x, 46
		inc eax
	  .endw
	  
	  push ebx
	  mov ebx, 0
	  .while pos.y > 46
		sub pos.y, 46
		inc ebx
	  .endw
	  
	  mov pos.x, eax
	  mov pos.y, ebx
	  
	  pop eax
	  pop ebx
	  
	  mov eax, 46
	  mul pos.x
	  mov pos.x, eax
	  
	  mov eax, 46
	  mul pos.y
	  mov pos.y, eax
	  
	  add pos.x, 46
	  add pos.y, 46
	  


	  

      invoke BitBlt,hdc,pos.x,pos.y,rect.right,rect.bottom,hMemDC,0,0,SRCAND
      invoke DeleteDC,hMemDC

   .elseif uMsg == WM_RBUTTONDOWN

	  invoke GetClientRect,hWnd,addr rect
	  invoke InvalidateRect, hWnd, addr rect, 0

	  invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
	  invoke SelectObject,hMemDC,hBitmap3

	  invoke GetCursorPos,addr pos
	  invoke ScreenToClient,hWnd,addr pos

      invoke BitBlt,hdc,pos.x,pos.y,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
      invoke DeleteDC,hMemDC

	.elseif uMsg==WM_DESTROY
      invoke DeleteObject,hBitmap1
		invoke PostQuitMessage,NULL
	  invoke DeleteObject,hBitmap2
		invoke PostQuitMessage,NULL
	  invoke DeleteObject,hBitmap3
		invoke PostQuitMessage,NULL
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp

end start
