TITLE Program 6      (program6.asm)

; Author: Matthew Anderson			anderma8@oregonstate.edu
; Course: CS 271 - Program 6        Date: March 5, 2018
;
; Description: Presents the user with an nCr combinatorics problem,
;  and evaluates the entered answer. 'n' will be a random number in [3, 12],
;  and 'r' will be a random number in [1, n]. Repeats until user decides to
;  exit. Demonstrates recursive implementation of calculating nCr.

INCLUDE Irvine32.inc

N_MIN = 3
N_MAX = 12
R_MIN = 1				;R_MAX depends on user input.
INPUT_BUFFER_SIZE = 11	;Size of user answer input buffer.

;--------------------------------------------------
mWriteStr MACRO buffer				
;
; This macro prints a string. Accepts location
; of the string buffer.
;
; Implementation borrowed from Week 9 class 
;  lectures.
;--------------------------------------------------
	push	edx
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx

ENDM
;--------------------------------------------------


.data
programName		BYTE	"Combinatorics Quiz",0
myName			BYTE	"Written By: Matthew Anderson",0
instruct1		BYTE	"I will ask you to calculate the number of possible",0
instruct2		BYTE	"combinations of r items taken from a set of n items (nCr),",0
instruct3		BYTE	"and check that your answer is correct.",0

nStr			BYTE	"Number of elements in the set: ",0
rStr			BYTE	"Number of elements to choose from the set: ",0
problemPrompt	BYTE	"How many ways can you choose? ",0
usrAnswerStr	BYTE	INPUT_BUFFER_SIZE DUP(?)

nVal			DWORD	?
rVal			DWORD	?
usrAnswer		DWORD	?


.code
main PROC

	call	Randomize			;Seed random number generator.
	call	Introduction

	push	OFFSET nVal
	push	OFFSET rVal
	call	ShowProblem

	push	OFFSET	usrAnswer
	call	GetData
	call	CrLf


	exit	; exit to operating system
main ENDP

;--------------------------------------------------
Introduction PROC
;
; Prints a greeting message and program
; instructions.
;
;--------------------------------------------------
	mWriteStr	programName
	call		CrLf
	mWriteStr	myName
	call		CrLf
	call		CrLf
	mWriteStr	instruct1
	call		CrLf
	mWriteStr	instruct2
	call		CrLf
	mWriteStr	instruct3
	call		CrLf
	call		CrLf

	ret

Introduction ENDP


;--------------------------------------------------
ShowProblem PROC
;
; Generates an nCr combinatorics problem for the user
; to solve. 'n' is a randomly generated number in
; [N_MIN, N_MAX]. 'r' is a randomly generated number
; in [R_MIN, n].
;
; Receives the stack parameters (@n, @r).
;	@n: the address to store the generated value
;	 of n.
;	@r: the address to store the generated value
;	 of r.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp
	
	;To generate 'n', we need to pass N_MAX - N_MIN + 1 to RandomRange.
genN:
	mov		eax, N_MAX
	sub		eax, N_MIN
	inc		eax

	call	RandomRange			;Generate 'n'.
	add		eax, N_MIN			;Get generated value into valid range.

	mov		edi, [ebp + 12]		;Load @n.
	mov		[edi], eax			;Save 'n'

printN:							;Print number of elements.
	mWriteStr nStr
	call	WriteDec
	call	CrLf

genR:
	sub		eax, R_MIN			;Pass 'n' - R_MIN + 1 to RandomRange. EAX contains 'n'.
	inc		eax

	call	RandomRange
	add		eax, R_MIN			;EAX contains 'r'.

	mov		edi, [ebp + 8]
	mov		[edi], eax			;Save 'r'.

printR:
	mWriteStr rStr
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		ebp
	ret 8
	
ShowProblem ENDP

;--------------------------------------------------
GetData PROC
;
; Prompts user to enter their answer to the nCr
; problem. Validates the entered string into
; the numeric value it represents.

; Receives the stack parameters (@a).
;	@a: Address to store user's answer.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 8]		;EDI contains destination address.

	mWriteStr problemPrompt

getInput:
	mov		edx, OFFSET usrAnswerStr
	mov		ecx, INPUT_BUFFER_SIZE - 1
	call	ReadString			;usrAnswerStr contains entered string.

	push	OFFSET usrAnswerStr
	push	eax					;Size of input string.
	call	IsNumeric
	
	pop	ebp

	ret 4

GetData ENDP


;--------------------------------------------------
IsNumeric PROC
;
; Checks if a string represents a valid POSITIVE 
; integer.

; Receives the stack parameters (@a, size).
;	@a: Address of the string.
;	size: size of the string.
;
; Returns: ZF = 1 if the string represents a valid
; integer; else, ZF = 0.
;--------------------------------------------------
	push	esi
	push	ecx
	push	eax
	push	ebx
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 28]		;ESI contains address of string.
	mov		ecx, [ebp + 24]		;ECX contains size of string.
	cld

	;Check if string is empty. If yes, set ZF = 0 and finish.
	cmp		ecx, 0
	je		emptyStr

nextDigit:
	lodsb						;AL contains next character.

	;Valid numeric characters will have ASCII codes in [48, 57].
	cmp		al, 48
	jl		finished			;ZF = 0
	cmp		al, 57
	jg		finished			;ZF = 0

	loop	nextDigit

	xor		eax, eax
	cmp		eax, 0				;Set ZF = 1, since string is valid integer representation.
	jmp		finished

emptyStr:	;String was empty. Set ZF = 0, since this isn't valid numeric representation.
	xor		eax, eax
	cmp		eax, 1

finished:
	pop		ebp
	pop		ebx
	pop		eax
	pop		ecx
	pop		esi

	ret		8

IsNumeric ENDP
END main
