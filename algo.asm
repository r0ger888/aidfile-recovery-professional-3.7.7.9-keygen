
include biglib.inc
includelib biglib.lib

GenKey		PROTO	:DWORD
StrArrange  PROTO	:DWORD

.data
NameBuffer	db 256	dup(0)
SrlBuffer	db 256  dup(0)
RSAEnk		dd 256	dup(0)
NameBlack	db "CANNOT GENERATE KEY!",0
NoName		db "insert ur name",0
ExpD		db "812C261071413717F2D765F3EAA6F339",0
ExpN		db "3C598F56EF7BA5CD51EE89EF52B1E2B",0
Blklist1	db "brothersoft",0
Blklist2	db "Giveawayoftheday",0
Blklist3	db "Martik-Scorp Giveaway",0
Blklist4	db "Vovan",0
Blklist5	db "SoftVipDownload",0

.data?
_D	dd 	?
_N	dd	?
Chipertxt1	dd	?
Chipertxt2	dd	?

.code
GenKey proc hWin:DWORD

	invoke RtlZeroMemory,offset NameBuffer,sizeof NameBuffer
	invoke GetDlgItemText,hWin,IDC_NAME,offset NameBuffer,sizeof NameBuffer
	test eax,eax
	jz _noname
	mov ebx,5
	mov edi, offset Blklist1
	
part_1:
	push offset NameBuffer
	push edi
	call lstrcmpA
	test eax,eax
	jz _blacklist
	push edi
	call BlackList
	lea eax,[eax+1]
	lea edi,[eax+edi]
	dec ebx
	jnz short part_1
	invoke _BigCreate,0
	mov Chipertxt1,eax
	invoke _BigCreate,0
	mov _D,eax
	invoke _BigCreate,0
	mov _N,eax
	invoke _BigCreate,0
	mov Chipertxt2,eax
	invoke _BigIn,offset ExpD,16,_D
	invoke _BigIn,offset ExpN,16,_N
	invoke StrArrange,offset NameBuffer
	lea edi, RSAEnk
	invoke _BigInB256,offset NameBuffer,eax,Chipertxt1
	invoke _BigPowMod,Chipertxt1,_N,_D,Chipertxt2
	invoke _BigOutB16,Chipertxt2,edi
	invoke _BigDestroy,Chipertxt1
	invoke _BigDestroy,_D
	invoke _BigDestroy,_N
	invoke _BigDestroy,Chipertxt2
	xor ebx,ebx
	xor ecx,ecx
	lea esi,SrlBuffer
	mov bl,2Dh
	
part_2:
	lea edx,[ecx*4]
	mov eax,[edx+edi]
	lea edx,[ecx+ecx*4]
	mov [edx+esi],eax
	mov [edx+esi+4],ebx
	add ecx,1
	cmp ecx,8
	jb short part_2
	mov [edx+esi+4],bh
	invoke SetDlgItemText,hWin,IDC_SERIAL,esi
	jmp short _ret
	
_blacklist:
	invoke SetDlgItemText,hWin,IDC_SERIAL,offset NameBlack
	jmp short _ret
	
_noname:
	invoke SetDlgItemText,hWin,IDC_SERIAL,offset NoName
	jmp short _ret
	
_ret:
	ret
GenKey endp

BlackList proc near

arg_0		=	dword ptr 8

		mov     eax, [esp+arg_0]
		lea     edx, [eax+3]
		push    ebp
		push    edi
		mov     ebp, 80808080h

loc_40135E:
		mov     edi, [eax]
		add     eax, 4
		lea     ecx, [edi-1010101h]
		not     edi
		and     ecx, edi
		and     ecx, ebp
		jnz     short loc_4013AA
		mov     edi, [eax]
		add     eax, 4
		lea     ecx, [edi-1010101h]
		not     edi
		and     ecx, edi
		and     ecx, ebp
		jnz     short loc_4013AA
		mov     edi, [eax]
		add     eax, 4
		lea     ecx, [edi-1010101h]
		not     edi
		and     ecx, edi
		and     ecx, ebp
		jnz     short loc_4013AA
		mov     edi, [eax]
		add     eax, 4
		lea     ecx, [edi-1010101h]
		not     edi
		and     ecx, edi
		and     ecx, ebp
		jz      short loc_40135E

loc_4013AA:                             ; CODE XREF: sub_401350+1Fj

		test    ecx, 8080h
		jnz     short loc_4013B8
		shr     ecx, 10h
		add     eax, 2
		
loc_4013B8:                             ; CODE XREF: sub_401350+60j
		shl     cl, 1
		sbb     eax, edx
		pop     edi
		pop     ebp
		retn    4
BlackList endp

StrArrange proc _strbuffer:DWORD

		mov eax,[_strbuffer]
		sub eax,4

part_1: 
		add eax, 4
		cmp byte ptr [eax], 0
		jz  short part_4
		cmp byte ptr [eax+1], 0
		jz  short part_3
		cmp byte ptr [eax+2], 0
		jz  short part_2
		cmp byte ptr [eax+3], 0
		jnz short part_1
		sub eax, [_strbuffer]
		add eax, 3
		ret

part_2: 
		sub eax, [_strbuffer]
		add eax, 2
		ret

part_3: 
		sub eax, [_strbuffer]
		add eax, 1
		ret

part_4: 
		sub eax, [_strbuffer]
		ret

StrArrange endp