.const
sWidth				equ  200
sHeight				equ  89
cdXSize             EQU  640         ;cdYSize*1.6
cdYSize             EQU  400
cdIdTimer           EQU  1
DIB_RGB_COLORS      EQU  0
cdne                EQU  25

.data
LCDBITMAPINFO   BITMAPINFOHEADER < sizeof BITMAPINFOHEADER,cdXSize,-cdYSize,1,32,0,0,0,0,0,0>
fGrad2Rad       dd             0.01745329251994329576923690768489
iNicio          dd             0

.data?
CommandLine      DD            ?
vdSeed           dd            ?
vdxClient        dd            ?
vdyClient        dd            ?
bufDIBDC         dd            ?
pMainDIB         dd            ?
hMainDIB         dd            ?
hOldDIB          dd            ?
SpiralDC		 dd	?
SpiralThread	 dd ?
hDc				 dd ?

.code
ClearMainDib PROC
    cld
    mov             eax, 0
    mov             edi, dword ptr [pMainDIB]
    mov             ecx, 640*400
    rep             stosd
    ret
  ClearMainDib ENDP
  
  DrawSpiral PROC uses ebx ecx edx, angulo:DWORD, color:DWORD
    local        Phase1:DWORD, Phase2:DWORD, EjeX:DWORD, EjeY:DWORD, cont:DWORD
    mov          edi, dword ptr [pMainDIB]
    push         dword ptr [angulo]
    pop          dword ptr [Phase1]
    mov          dword ptr [Phase2], 0
    mov          dword ptr [cont], 0
    @Bucle:
      ; EjeX = MidX + Phase2*sin(Phase1*cdGrad2Rad)
      fild         dword ptr [Phase1]         ; st0 = Phase1
      fmul         dword ptr [fGrad2Rad]      ; st0 = Phase1*pi/180
      fsin                                    ; st0 = sin(Phase1)
      fimul        dword ptr [Phase2]
      push         710/7
      fiadd        dword ptr [esp]
      pop          eax
      fistp        dword ptr [EjeX]
      ; EjeY = MidY + Phase2*cos(Phase1*cdGrad2Rad)
      fild         dword ptr [Phase1]         ; st0 = Phase1
      fmul         dword ptr [fGrad2Rad]      ; st0 = Phase1*pi/180
      fcos                                    ; st0 = cos(Phase1)
      fimul        dword ptr [Phase2]
      push         310/7
      fiadd        dword ptr [esp]
      pop          eax
      fistp        dword ptr [EjeY]
      ;
      cmp          dword ptr [EjeX], 0
      jl           @NoSePinta
      cmp          dword ptr [EjeX], 640
      jge          @NoSePinta
      cmp          dword ptr [EjeY], 0
      jl           @NoSePinta
      cmp          dword ptr [EjeY], 400
      jge          @NoSePinta
        mov          eax, cdXSize
        mul          dword ptr [EjeY]
        add          eax, dword ptr [EjeX]
        shl          eax, 2
        mov          ebx, dword ptr [color]
        mov          dword ptr [edi+eax], ebx
      @NoSePinta:
      inc          dword ptr [Phase1]
      inc          dword ptr [Phase2]
      inc          dword ptr [cont]
      cmp          dword ptr [cont], 1000
    jnz          @Bucle
    ret
  DrawSpiral ENDP

  PintaObjeto PROC
    local        k:DWORD
    call         ClearMainDib
    push         dword ptr [iNicio]
    pop          dword ptr [k]
    mov          ecx, dword ptr [iNicio]
    mov          edx, ecx
    add          edx, cdne
    @Bucle:
      invoke       DrawSpiral, ecx, 04C00000h
      mov          eax, ecx
      add          eax, 60
      invoke       DrawSpiral, eax, 04C00000h
      mov          eax, ecx
      add          eax, 120
      invoke       DrawSpiral, eax, 04C00000h
      mov          eax, ecx
      add          eax, 180
      invoke       DrawSpiral, eax, 04C00000h
      mov          eax, ecx
      add          eax, 240
      invoke       DrawSpiral, eax, 04C00000h
      mov          eax, ecx
      add          eax, 300
      invoke       DrawSpiral, eax, 04C00000h
      inc          ecx
      cmp          ecx, edx
    jnz          @Bucle
    mov          eax, [iNicio]
    xor          edx, edx
    mov          ebx, 360
    inc          eax
    div          ebx
    mov          [iNicio], edx
    ret
  PintaObjeto ENDP
  
  Inicio PROC uses ecx edi
    ret
   Inicio ENDP