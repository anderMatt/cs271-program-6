TITLE Program 6      (program6.asm)

; Author: Matthew Anderson			anderma8@oregonstate.edu
; Course: CS 271 - Program 6        Date: March 8, 2018
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
inputErrMsg		BYTE	"You must enter a positive integer! Try again: ",0

ansStr1			BYTE	"There are ",0
ansStr2			BYTE	" combinations of ",0
ansStr3			BYTE	" items from a set of ",0
ansStr4			BYTE	".",0

incorrectStr	BYTE	"You need to hit the books and study some more!",0
correctStr		BYTE	"Well done, you answered correctly!",0
playAgainStr	BYTE	"Would you like to play again? (y/n): ",0 
playAgainErr	BYTE	"Value other than 'y' or 'n' entered, so I'm going to exit!",0
goodbyeStr		BYTE	"Goodbye!",0
playAgainBuffer	BYTE	?

nVal			DWORD	?
rVal			DWORD	?
usrAnswer		DWORD	?

theAnswer		DWORD 0


.code
main PROC

	call	Randomize			;Seed random number generator.
	call	Introduction

play:

	push	OFFSET nVal
	push	OFFSET rVal
	call	ShowProblem

	;Calculate the answer.
	push	nVal
	push	rVal
	push	OFFSET theAnswer
	call	Combinations

	;Get user's answer.
	push	OFFSET	usrAnswer
	call	GetData
	call	CrLf

	;Report answer.
	push	nVal
	push	rVal
	push	theAnswer
	push	usrAnswer
	call	ShowResults

	;Ask if user wants another problem.
	call	AskPlayAgain
	jz		play

	call	CrLf
	mWriteStr goodbyeStr
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

	call	CrLf
	call	CrLf
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

	jz		convertInput			

	;User entered a non-numeric string. Print error, and try again.
	call	CrLf
	mWriteStr	inputErrMsg
	jmp		getInput

convertInput:	
	
	push	OFFSET usrAnswerStr
	push	eax					;Number of digits in entered string.
	push	edi					;Output variable.
	call	StringToNumber

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

;--------------------------------------------------
StringToNumber PROC
;
; Generates the numeric value of a string representation
; of a positive integer.
;
; Receives stack parameters (@s, n, @o).
;	@s: string representation of positive integer.
;	n: number of characters before null-terminator.
;	@o: output variable to store numeric value.
;
;--------------------------------------------------
	push	eax
	push	esi
	push	ecx
	push	ebx
	push	ebp

	mov		ebp, esp

	mov		esi, [ebp + 32]		;Load address of string.
	mov		ecx, [ebp + 28]		;Load number of characters.
	mov		edi, [ebp + 24]		;Load output variable.

	xor		eax, eax			;Holds numeric value.

convertChar:
	mov		ebx, 10
	mul		ebx

	push	eax					;Save current value before loading next byte.
	lodsb

	movzx	ebx, al
	sub		ebx, 48				;Convert char to numeric value.

	pop		eax
	add		eax, ebx			;Add digit to accumulating value.

	loop	convertChar

	mov		[edi], eax			;Save numeric value to output variable.

	pop		ebp
	pop		ebx
	pop		ecx
	pop		esi
	pop		eax

	ret 12

StringToNumber ENDP


;--------------------------------------------------
Combinations PROC
;
; Calculates the answer to an nCr problem, using the
; formula n!/(r!(n-r)!)
;
; Accepts the stack parameters(n, r, @answer)
;	n: Value of n.
;	r: Value of r.
;	@answer: Address to store the answer.
;
;--------------------------------------------------

	pushad
	mov		ebp, esp

	mov		eax, [ebp + 44]		;Load n.
	mov		edi, [ebp + 36]		;Load address.

nFac:
	;Calculate n!
	push	eax
	push	edi
	call	Factorial			

	mov		eax, [edi]			;EAX contains n!

rFac:
	;Calculate r!
	mov		ecx, 0
	mov		[edi], ecx			;Reset for next factorial calculation.
	mov		ebx, [ebp + 40]		;Load r

	push	ebx
	push	edi
	call	Factorial

	mov		ebx, [edi]			;EBX contains r!

nMinRFac:

	;Calculate (n-r)!
	mov		ecx, [ebp + 44]		;load n.
	mov		edx, [ebp + 40]		;load r.
	sub		ecx, edx			;ECX = (n-r)

	mov		edx, 0
	mov		[edi], edx			;Reset for next factorial combination.
	push	ecx
	push	edi
	call	Factorial			

	mov		ecx, [edi]			;ECX = (n-r)!

finalAnswer:

	;Calculate n!/r!(n-r)!

	push	eax					;Save n!
	mov		eax, ebx			;EAX = r!
	mul		ecx					;ECX = (n-r)!

	mov		ebx, eax			;EBX = r!(n-r)!
	pop		eax					;restore n!

	div		ebx					
	;mov		edi, [ebp + 36]		;Load output address.
	mov		[edi], eax			;Store answer

	popad

	ret 12
Combinations ENDP

;--------------------------------------------------
Factorial PROC
;
; Calculates the factorial of an integer, n.
;
; Accepts the stack parameters (n, @answer)
;	n: Number to compute factorial of.
;	@answer: Address to store answer.
;--------------------------------------------------
	push	eax
	push	ebx
	push	ebp
	mov		ebp, esp

	mov		ebx, [ebp + 20]		;Load n.
	mov		edi, [ebp + 16]		;Load output address.

	cmp		ebx, 0				;Base case.
	je		base

	cmp		ebx, 1				;Base case.
	je		base

recurse:

	dec		ebx					;Recursive call with n-1.
	push	ebx
	push	edi
	call	Factorial

	mov		ebx, [ebp + 20]		;Load this stack frame's value of n.
	mov		edi, [ebp + 16]		;This is (n-1)!

	mov		eax, [edi]
	mul		ebx					;n * (n-1)!
	mov		[edi], eax
	jmp		quit

base:
	inc DWORD PTR[edi]			;Needed in case N starts off as zero. Otherwise, exits when N reaches 1.

quit:
	pop		ebp
	pop		ebx
	pop		eax

	ret 8

Factorial ENDP

;--------------------------------------------------
ShowResults PROC
;
; Displays the answer to the nCr problem, and determines
; if the user answered correctly.
;
; Accepts the stack parameters (n, r, answer, guess)
;	n: The value of n used for the nCr problem.
;	r: The value of r used for the nCr problem.
;	answer: Correct answer to the nCr problem.
;	guess: User-entered answer to the problem.
;--------------------------------------------------
	push	ebp
	mov		ebp, esp

	mWriteStr	ansStr1
	mov		eax, [ebp + 12]		;Load correct answer.
	call	WriteDec

	mWriteStr	ansStr2
	mov		eax, [ebp + 16]		;Load r.
	call	WriteDec

	mWriteStr	ansStr3
	mov		eax, [ebp + 20]		;Load n.
	call	WriteDec
	mWriteStr	ansStr4

validate:
	
	mov		eax, [ebp + 12]    ;Correct answer.
	mov		ebx, [ebp + 8]	   ;User's answer.

	cmp		eax, ebx		   ;Compare user answer to correct answer.
	je		correct

	call	CrLf
	mWriteStr incorrectStr
	jmp		return

correct:
	call	CrLf
	mWriteStr correctStr

return:

	call	CrLf
	call	CrLf
	pop		ebp
	ret 16

ShowResults ENDP

;--------------------------------------------------
AskPlayAgain PROC
;
; Asks user if they would like to solve another
; problem.
;
; Returns: ZF = 1 if user indicates they want another
; problem; else, ZF = 0.
;
;
;--------------------------------------------------
	push	eax
	push	ecx
	push	edx
	mWriteStr playAgainStr

	xor		edx, edx
	mov		edx, OFFSET playAgainBuffer
	mov		ecx, 1
	call	ReadChar			;User will enter 'Y' or 'N'. Case insensitive.

	;Check user's input.
	cmp		al, 'y'				;Entered 'y'.
	je		onDone
	cmp		al, 'Y'
	je		onDone				;Entered 'Y'.
	cmp		al, 'n'				;Entered 'n'.
	je		nEntered
	cmp		al, 'N'				;Entered 'N'.
	je		nEntered
	
	;Something other than 'y' or 'n' entered. Interpret as intention to exit.
	call	CrLf
	mWriteStr playAgainErr
	call	CrLf
	jmp		onDone

nEntered:							;Clear ZF.
	mov		eax, 0
	cmp		eax, 1
	jmp		onDone

onDone:								;Need to reset variables for next round.
	mov		edi, OFFSET usrAnswer
	mov		eax, 0
	mov		[edi], eax				;Clear user's last answer.

	mov		edi, OFFSET theAnswer	;Clear last problem's answer.
	mov		[edi], eax

	pop		edx
	pop		ecx
	pop		eax

	ret

AskPlayAgain ENDP
END main
