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
instruct3		BYTE	"and evaluate your answer.",0

; (insert variable definitions here)

.code
main PROC

	call	Randomize			;Seed random number generator.
	call	Introduction



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

	ret

Introduction ENDP

END main
