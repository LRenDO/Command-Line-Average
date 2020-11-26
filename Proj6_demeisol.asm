TITLE Project Template        (template.asm)

; Author: Ren Demeis-Ortiz
; Last Modified: 11.3.20
; OSU Email: demeisol@oregonstate.edu
; Course Number: CS271 Sec 400
; Project Number: 6          
; Due Date: 12.6.20
; Description: Prompts user to enter 10 signed dword integers. 
;		validates input and stores all values in an array. Calculates average.
;		Finally it prints the integers, sum and average.
;		Requires Irvine Library.

;_____________________ADD DESCRIPTIONS Above and below change starting outputlist variable to 0


INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt and receives string input from user.
;
; Preconditions: Pass string address for prompt and location for user input to be
;		stored by reference. Uses ReadString and WriteString from Irvine Library and
;		mDisplayString MACRO.
;
; Postconditions: User input is stored at second parameter. Registers are preserved 
;		and restored (EDX, ECX, EAX). 
;
; Receives: 
;		prompt (by reference) = address of prompt
;		buffSize = size of buffer for user input
;		input (by reference) =Address for storing user entered input 
;		charEntered (by reference) = Address for storing total characters entered
;
; Returns: 
;		input = User input
;		charEntered = Total Characters Entered by User
;		
; ---------------------------------------------------------------------------------
mGetString MACRO strAddress:REQ, buffSize:REQ, input:REQ, charEntered:REQ
	; Preserve Registers
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	; Prompt User 
	mDisplayString	strAddress

	; Get and Save User input
	MOV		EDX, input
	MOV		ECX, buffSize
	CALL	ReadString
	MOV		charEntered, EAX

	; Restore Registers
	POP		EAX
	POP		ECX
	POP		EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints to console string at address passed as parameter
;
; Preconditions: Pass string reference by parameter. Uses WriteString   
;		from Irvine Library.
;
; Postconditions: Uses EDX but preserves and restores it. Displays string.
;
; Receives:
;		strAddr (by reference) = address of string to be printed
;
; Returns: None. Displays string.
;		
; ---------------------------------------------------------------------------------
mDisplayString MACRO strAddr:REQ
	; Preserve Register
	PUSH	EDX

	; Display String
	MOV		EDX, strAddr
	CALL	WriteString

	; Restore Register
	POP		EDX
ENDM

; Constants 
BUFFERSIZE = 13		;max char for a valid SDWORD is 11 + null + 1 for validation
ARRAYLEN = 10		;length of output array
SDWMIN =	-2147483648
SDWMAX = 2147483647

.data
; Message and Title Variables
intro1			BYTE	"... By Ren Demeis-Ortiz",13,10,13,10,0
intro2			BYTE	"Functionality",13,10
				BYTE	"...",13,10
				BYTE	"...",13,10
				BYTE	"...",13,10
				BYTE	"...",13,10
				BYTE	"...",13,10
				BYTE	"...",13,10
				BYTE	"...",13,10
				BYTE	13,10,0
error			BYTE	"Woops! That wasn't a valid input. Let's try again",13,10,0
prompt1			BYTE	13,10,"Enter a signed number between -2,147,483,648" 
				BYTE	"and +2,147,483,647: ",13,10,0
listTitle		BYTE	13,10,"You Entered:",13,10,0
sumTitle		BYTE	"Sum: ",0
avgTitle		BYTE	"Average (rounded down to nearest integer): ",0
farewell		BYTE	"..., have a great day!",13,10,13,10,0

; Array and Calculation Variables
userInput		BYTE	BUFFERSIZE DUP (0)
userInputSize	DWORD	SIZEOF userInput
outputList		SDWORD	ARRAYLEN DUP (2)
typeSize		DWORD	TYPE outputList
inputLen		DWORD	?
elemPerLine		DWORD	10
sum				SDWORD	0
average			DWORD	0

.code
main PROC
 
	; Introduce Program
	PUSH	OFFSET intro1
	PUSH	OFFSET intro2
	CALL	introduction	


	mGetString OFFSET prompt1, userInputSize, OFFSET userInput, inputLen

	mDisplayString OFFSET userInput

	; Get 10 Valid Integers from User input

	; Get and Convert User Inputted String

	; Display userInput Array
	PUSH	elemPerLine
	PUSH	typeSize
	PUSH	ARRAYLEN
	PUSH	OFFSET listTitle
	PUSH	OFFSET outputList
	CALL	displayList

	; Calculate Average and Sum
	PUSH	OFFSET average
	PUSH	OFFSET sum
	PUSH	OFFSET outputList
	PUSH	ARRAYLEN
	CALL	calcAverage

	; Display Sum 

	; Display Average

	; Say farewell
	PUSH	OFFSET farewell
	CALL	displayFarewell



	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays program name, author and functionality.
;
; Preconditions: Parameters pushed on to stack in following order - intro1, intro2
;			 Requires printString MACRO.
;		
;
; Postconditions: Uses EBP but preserves and restores it.  
;
; Receives:
;		Stack Parameters: 
;				intro1 (by reference)= program name and author
;				intro2 (by reference) = program functionality
;
; Returns: None. Displays introduction.
;		
; ---------------------------------------------------------------------------------
introduction PROC
	; Set Base Pointer
	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP+12]						;address of intro1

	mDisplayString [EBP+8]						;address of intro2

	POP		EBP
	RET		8

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: getUserInput
;
; Gets prompts user to enter 10 signed numbers and stores them in an array as 
; a string.  Reprompts user for invalid entries.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			Requires mGetString MACRO and ReadVal PROC.
;		
;
; Postconditions: Uses registers but restores them (). 
;
; Receives:
;		Stack Parameters: 
;			prompt1	(by reference) = address of prompt for user to enter number
;			userInputSize = buffer size for input
;			userInput (by reference) = address for string user inputs
;			inputLen = address to store the number of characters inputted
;			signedNum (by reference) = address to store outputed SDWORD
;
; Returns: 
;		signedNum (by reference) = address to store outputed SDWORD
;		
; ---------------------------------------------------------------------------------


; ---------------------------------------------------------------------------------
; Name: readVal
;
; Converts string entered by user to signed number and validates if it is within
; range for SDWORD.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			Requires mGetString MACRO.
;		
;
; Postconditions: Uses registers but restores them (). 
;
; Receives:
;		Stack Parameters: 
;			SDWMIN = lowest signed 32 bit integer value
;			SDWMAX = greatest signed 32 bit integer value
;			prompt1	(by reference) = address of prompt for user to enter number
;			userInputSize = buffer size for input
;			userInput (by reference) = address for string user inputs
;			inputLen = address to store the number of characters inputted
;			signedNum (by reference) = address to store outputted SDWORD
;			isValid = address to store if number is written or not
;
; Returns: 
;		isValid = 1 if it is valid and was written 0 if not
;		signedNum (by reference) = address to store outputed SDWORD
;		
; ---------------------------------------------------------------------------------
	; Traverse Array
	; If User didn't input anything
	; If More than 11 Characters Entered Display Error Message and Return
	; If Not a Digit Display Error Message and Return
	; Convert to SDWORD
	; If Greater than SDMAX Display Error Message and Return
	; If Less than SDMIN Display Error Message and Return
; ---------------------------------------------------------------------------------
; Name: writeVal
;
; Converts signed DWORD and displays the value.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			Requires mdisplayString MACRO.
;		
;
; Postconditions: Uses registers but restores them (). 
;
; Receives:
;		Stack Parameters: 
;			DWORD = value to be converted and printed
;
; Returns:
;		Displays converted number using mDisplayString MACRO.
;		
; ---------------------------------------------------------------------------------
writeVal PROC
	; Preserve Registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX

	; Convert DWORD to String
	MOV		EAX, [EBP+4]					;DWORD to be converted

_NextDigit:
	; 

	; Display String
	mDisplayString	EAX
	
	;JE		_NextDigit

	; Restore Registers and Return
	POP		EDX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		4
writeVal ENDP


; ---------------------------------------------------------------------------------
; Name: displayList
;
; Prints a DWORD array to the console with one space between elements.
;
; Preconditions: 5 parameters pushed to the stack in the order listed below in 
;				Receives section.
;		
;
; Postconditions: Uses EAX, EBX, ECX, EDX, EBP, ESI but preserves and restores 
;				all of them.
;
; Receives:
;		Stack Parameters: 
;				elemPerLine = number of elements to be displayed per line
;				typeSize = size of the type
;				ARRAYLEN = number of elements in array
;				listTitle (by reference) = string title to be displayed before array
;				outputList (by reference) = array to be displayed
;
; Returns: 
;		None. Displays array.
; ---------------------------------------------------------------------------------
displayList PROC
	; Preserve Registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	PUSH	ECX
	PUSH	EBX
	PUSH	EAX
	PUSH	ESI

	MOV		ESI, [EBP+8]					; address of array
	
	mDisplayString [EBP+12]					; address of title

	MOV		ECX, [EBP+16]					; length of array
	
	; Display Array
_Display:
	MOV		EAX, [ESI]
	CALL	WriteDec
	MOV		AL, ' '
	CALL	WriteChar
	ADD		ESI, [EBP+20]					; element type size
	
	; If not nth number skip to the end, else go to next line 
	; (nth element = Length of array-count+1/n = remainder 0)
	MOV		EAX, [EBP+16]					; length of array
	SUB		EAX, ECX
	ADD		EAX, 1
	MOV		EBX, [EBP+24]					; number of elements per line
	CDQ
	DIV		EBX
	CMP		EDX, 0
	JNE		_SkipNewLine
	CALL	CrLf

_SkipNewLine:
	LOOP	_Display

	CALL	CrLf

	;Restore Registers and Return
	POP		ESI
	POP		EAX
	POP		EBX
	POP		ECX
	POP		EDX
	POP		EBP
	RET		20
displayList	ENDP

; ---------------------------------------------------------------------------------
; Name: average
;
; Calculates average of an array passed rounded down to the nearest integer.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			Requires and calcSum PROC.
;		
;
; Postconditions: Uses registers but restores them (). 
;
; Receives:
;		Stack Parameters: 
;				average (by reference) = address of average
;				sum (by reference) = address of sum
;				outputList (by reference) = address of outputList
;				ARRAYLEN = number of elements in array
;
; Returns: None.  Displays converted number using mDisplayString MACRO.
;		
; ---------------------------------------------------------------------------------
calcAverage PROC
	; Preserve Registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	EDI
	PUSH	ESI

	; Calculate Sum
	PUSH	[EBP+16]						;address of sum 
	PUSH	[EBP+12]						;address of outputList
	PUSH	[EBP+8]							;ARRAYLEN (elements in array)
	CALL	calcSum

	; Set EDI and ESI 
	MOV		ESI, [EBP+16]					;address of sum 
	MOV		EDI, [EBP+20]					;address of average

	; Divide Number of Elements
	CDQ		
	MOV		EAX, [ESI]						;sum 
	MOV		EBX, [EBP+8]					;ARRAYLEN (elements in array)
	IDIV	EBX
	MOV		[EDI], EAX						;address of average 
	
	; Restore Registers and Return
	POP		ESI
	POP		EDI
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16
calcAverage ENDP

; ---------------------------------------------------------------------------------
; Name: calcSum
;
; Calculates the sum of integers in a DWORD array passed.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			
;		
;
; Postconditions: Uses registers but restores them (EBP, EAX, EBX, ECX, EDI, ESI). 
;
; Receives:
;		Stack Parameters: 
;				sum (by reference) = address of sum
;				outputList (by reference) = address of outputList
;				ARRAYLEN = number of elements in array
;
; Returns: None.  Displays converted number using mDisplayString MACRO.
;		
; ---------------------------------------------------------------------------------
calcSum PROC
	; Preserve Registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDI
	PUSH	ESI


	; Set Registers to Traverse Array
	XOR		EBX, EBX
	MOV		ECX, [EBP+8]					;ARRAYLEN (elements in array)
	MOV		ESI, [EBP+12]					;address of outputLlist
	MOV		EDI, [EBP+16]					;address of sum

_NextElement:
	; Add Elements in outputList
	LODSD
	ADD		EBX, EAX
	LOOP	_NextElement
	
	; Store in sum
	MOV		[EDI], EBX								

	; Restore registers and Return
	POP		ESI
	POP		EDI
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		12
calcSum ENDP

; ---------------------------------------------------------------------------------
; Name: displayFarewell
;
; Displays farewell message
;
; Preconditions: farewell  is pushed onto stack. Requires printString MACRO.
;		
;
; Postconditions: Uses EBP but preserves and restores it. Displays Farewell.
;
; Receives:
;		Stack Parameters: 
;				farewellMess (by reference) = farewell message
;
; Returns: None. Displays farewell.
;		
; ---------------------------------------------------------------------------------
displayFarewell PROC
	; Set Base Pointer
	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP+8]							;address of farewell

	; Restore Base Pointer
	POP		EBP
	RET		4

displayFarewell ENDP

END main