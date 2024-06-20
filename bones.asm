.686
.model	flat, stdcall
option	casemap :none

USE_BMP = 1

include	resID.inc
include algo.asm
include spiral.asm
include textscr_mod.asm
include aboutbox.asm

AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
ENDM

.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	invoke	InitCommonControls
	invoke LoadBitmap,hInstance,400
	mov hIMG,eax
	invoke CreatePatternBrush,eax
	mov hBrush,eax
	invoke CreateSolidBrush,000000FFh
	mov hBackbrush,eax
	AllowSingleInstance addr WindowTitle
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset DlgProc, 0
	invoke	ExitProcess, eax

DlgProc proc hDlg:HWND,uMessg:UINT,wParams:WPARAM,lParam:LPARAM
LOCAL X:DWORD
LOCAL Y:DWORD
LOCAL ps:PAINTSTRUCT
LOCAL hdd:HDC

	.if [uMessg] == WM_INITDIALOG
 
 		push hDlg
 		pop xWnd
		mov eax, 466
		mov nHeight, eax
		mov eax, 250
		mov nWidth, eax                
		invoke GetSystemMetrics,0                
		sub eax, nHeight
		shr eax, 1
		mov [X], eax
		invoke GetSystemMetrics,1               
		sub eax, nWidth
		shr eax, 1
		mov [Y], eax
		invoke SetWindowPos,xWnd,0,X,Y,nHeight,nWidth,40h
            	
		invoke LoadIcon,hInstance,200
		invoke SendMessage, xWnd, WM_SETICON, 1, eax
		invoke SetWindowText,xWnd,addr WindowTitle
		invoke CreateSpiral,xWnd
		invoke ScrollerInit,xWnd
		invoke GetUserName,offset Userbuff,offset usrsize
		invoke SetDlgItemText,xWnd,IDC_NAME,offset Userbuff
		invoke SendDlgItemMessage, xWnd, IDC_NAME, EM_SETLIMITTEXT, 41, 0
		invoke CreateFontIndirect,addr TxtFont
		mov hFont,eax
		invoke CreateFontIndirect,addr TxtFont2
		mov hFont2,eax
		invoke GetDlgItem,xWnd,IDC_NAME
		mov hName,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,xWnd,IDC_SERIAL
		mov hSerial,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		
		invoke ImageButton,xWnd,24,199,600,602,601,IDB_ABOUT
		mov hAbout,eax
		invoke ImageButton,xWnd,233,199,700,702,701,IDB_EXIT
		mov hExit,eax
		
		invoke MAGICV2MENGINE_DllMain,hInstance,DLL_PROCESS_ATTACH,0
		invoke V2mPlayStream, addr v2m_Data,TRUE
		invoke V2mSetAutoRepeat,1
		
		invoke GenKey,xWnd
		
	.elseif [uMessg] == WM_LBUTTONDOWN

		invoke SendMessage, xWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0

	.elseif [uMessg] == WM_CTLCOLORDLG

		return hBrush

	.elseif [uMessg] == WM_PAINT
                
		invoke BeginPaint,xWnd,addr ps
		mov hdd,eax
		invoke GetClientRect,xWnd,addr r3kt
		invoke FrameRect,hdd,addr r3kt,hBackbrush
		invoke PintaObjeto
        invoke BitBlt,hdd,240,29,sWidth,sHeight,bufDIBDC,0,0,SRCCOPY
        invoke SelectObject,hdd,htxt
		invoke SetTextColor,hdd,White
		invoke SetBkMode,hdd,TRANSPARENT
		invoke SelectObject,hdd,hFont2
		invoke lstrlen,offset AppName
		invoke TextOut,hdd,82,128,offset AppName,eax
		invoke EndPaint,xWnd,addr ps                   
    
    .elseif [uMessg] == WM_TIMER
    	
		invoke InvalidateRect,xWnd,addr r3kt,NULL
	 
    .elseif [uMessg] == WM_CTLCOLOREDIT
    
		invoke SetBkMode,wParams,TRANSPARENT
		invoke SetTextColor,wParams,White
		invoke GetWindowRect,hDlg,addr WndRect
		invoke GetDlgItem,hDlg,IDC_NAME
		invoke GetWindowRect,eax,addr NameRect
		mov edi,WndRect.left
		mov esi,NameRect.left
		sub edi,esi
		mov ebx,WndRect.top
		mov edx,NameRect.top
		sub ebx,edx
		invoke SetBrushOrgEx,wParams,edi,ebx,0
		mov eax,hBrush
		ret  
	
	.elseif [uMessg] == WM_CTLCOLORSTATIC
	
		invoke SetBkMode,wParams,TRANSPARENT
		invoke SetTextColor,wParams,White
		invoke GetWindowRect,xWnd,addr XndRect
		invoke GetDlgItem,xWnd,IDC_SERIAL
		invoke GetWindowRect,eax,addr SerialRect
		mov edi,XndRect.left
		mov esi,SerialRect.left
		sub edi,esi
		mov ebx,XndRect.top
		mov edx,SerialRect.top
		sub ebx,edx
		invoke SetBrushOrgEx,wParams,edi,ebx,0
		mov eax,hBrush
		ret
	.elseif [uMessg] == WM_COMMAND
        
		mov eax,wParams
		mov edx,eax
		shr edx,16
		and eax,0ffffh
		.if edx == EN_CHANGE
			.if eax == IDC_NAME
				invoke GenKey,xWnd
			.endif
		.endif
		.if eax == IDB_ABOUT
	    	invoke DialogBoxParam,0,IDD_ABOUT,xWnd,offset AboutProc,0
		.elseif eax == IDB_EXIT || eax == IDCANCEL
			invoke SendMessage,xWnd,WM_CLOSE,0,0
		.endif 
             
	.elseif [uMessg] == WM_CLOSE
		invoke V2mStop
  		invoke MAGICV2MENGINE_DllMain,hInstance,DLL_PROCESS_DETACH,0 
		invoke KillTimer,xWnd,cdIdTimer
		invoke SelectObject,bufDIBDC,hOldDIB
		invoke DeleteDC,bufDIBDC
		invoke DeleteObject,hMainDIB
		invoke EndDialog,xWnd,0     
	.endif
         xor eax,eax
         ret
DlgProc endp

CreateSpiral proc hWnd:DWORD
LOCAL hdcc:HDC
	
	invoke    GetDC, hWnd
    mov       [hdcc], eax
	invoke    CreateCompatibleDC, [hdcc]
	mov       [bufDIBDC], eax
	invoke    CreateDIBSection, [hdcc], addr LCDBITMAPINFO, DIB_RGB_COLORS,\
                                    addr pMainDIB, NULL, NULL
    mov       [hMainDIB], eax
	invoke    SelectObject, [bufDIBDC], [hMainDIB]   ; Select bitmap into DC
	mov       [hOldDIB], eax
	invoke    Inicio
	invoke    SetTimer, hWnd, cdIdTimer, 1, NULL
	ret
CreateSpiral endp

end start