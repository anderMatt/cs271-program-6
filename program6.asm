TITLE Program 6      (program6.asm)

; Author: Matthew Anderson			anderma8@oregonstate.edu
; Course: CS 271 - Program 6        Date: March 5, 2018
; Description: Presents the user with an nCr combinatorics problem,
;  and evaluates the entered answer. 'n' will be a random number in [3, 12],
;  and 'r' will be a random number in [1, n]. Repeats until user decides to
;  exit. Demonstrates recursive implementation of calculating nCr.

INCLUDE Irvine32.inc

N_MIN = 3
N_MAX = 12
R_MIN = 1				;R_MAX depends on user input.

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

nVal			DWORD	?
rVal			DWORD	?


; (insert variable definitions here)

.code
main PROC

	call	Randomize			;Seed random number generator.
	call	Introduction

	push	OFFSET nVal
	push	OFFSET rVal
	call	ShowProblem


; (insert executable instructions here)

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

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
; Receives the stack parameters (@n, @r):
;	@n is the address to store the generated value
;	 of n.
;	@r is the address to store the generated value
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

END main
