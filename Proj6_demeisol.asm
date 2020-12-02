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
	PUSH	EDI

	; Prompt User 
	mDisplayString	strAddress

	; Get and Save User input
	MOV		EDX, input
	MOV		ECX, buffSize
	CALL	ReadString
	MOV		EDI, charEntered
	MOV		[EDI], EAX

	; Restore Registers
	POP		EDI
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
prompt1			BYTE	13,10,"Enter a signed number between -2,147,483,648 " 
				BYTE	"and +2,147,483,647: ",13,10,0
listTitle		BYTE	13,10,"You Entered:",13,10,0
sumTitle		BYTE	"Sum: ",0
avgTitle		BYTE	"Average (rounded down to nearest integer): ",0
farewell		BYTE	"..., have a great day!",13,10,13,10,0

; Array and Calculation Variables
tempStr			BYTE	12 DUP(0)
processedStr	BYTE	12 DUP(0)
pStringLen		DWORD	LENGTHOF processedStr
userInput		BYTE	BUFFERSIZE DUP (0)
userInputSize	DWORD	SIZEOF userInput
outputList		SDWORD	ARRAYLEN DUP (2)
typeSize		DWORD	TYPE outputList
inputLen		DWORD	?
elemPerLine		DWORD	10
sum				SDWORD	0
average			DWORD	0
isValid			DWORD	0
signedNum		SDWORD	?

.code
main PROC
 
	; Introduce Program
	PUSH	OFFSET intro1
	PUSH	OFFSET intro2
	CALL	introduction	


;___	mGetString OFFSET prompt1, userInputSize, OFFSET userInput, inputLen

	mDisplayString OFFSET userInput

	; Get 10 Valid Integers from User
	PUSH	ARRAYLEN
	PUSH	OFFSET OutputList
	PUSH	OFFSET error
	PUSH	OFFSET inputLen
	PUSH	SDWMIN
	PUSH	SDWMAX
	PUSH	OFFSET prompt1
	PUSH	userInputSize
	PUSH	OFFSET userInput
	PUSH	OFFSET signedNum
	PUSH	OFFSET isValid
	CALL	getUserInputs

	; Display userInput Array
	PUSH	SDWMAX
	PUSH	SDWMIN
	PUSH	OFFSET tempStr
	PUSH	pStringLen
	PUSH	OFFSET processedStr
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
	PUSH	SDWMAX
	PUSH	SDWMIN
	PUSH	OFFSET tempStr
	PUSH	pStringLen
	PUSH	OFFSET processedStr
	PUSH	sum
	CALL	WriteVal

	; Display Average
	PUSH	SDWMAX
	PUSH	SDWMIN
	PUSH	OFFSET tempStr
	PUSH	pStringLen
	PUSH	OFFSET processedStr
	PUSH	average
	CALL	WriteVal

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
; Name: getUserInputs
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
;			ARRAYLEN = number of outputList elements
;			outputList (by reference) = address to store signed numbers
;			error (by reference) = address of error message
;			inputLen (by reference) = address for number of characters inputted
;			SDWMIN = lowest signed 32 bit integer value
;			SDWMAX = greatest signed 32 bit integer value
;			prompt1	(by reference) = address of prompt for user to enter number
;			userInputSize = buffer size for input
;			userInput (by reference) = address for string user inputs
;			signedNum (by reference) = address to store outputted SDWORD
;			isValid (by reference) = address to store if number is written or not
;
; Returns: 
;		outputList (by reference) = address to store outputed SDWORD
;		
; ---------------------------------------------------------------------------------
getUserInputs PROC
	; Preserve Registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	; Set Registers
	MOV		ECX, [EBP+48]				;ARRAYLEN
	MOV		EDI, [EBP+44]				;OutputList

_NextElement:
	; Get User Input
	PUSH	[EBP+40]					;address of error
	PUSH	[EBP+36]					;address of inputLen
	PUSH	[EBP+32]					;SDWMIN
	PUSH	[EBP+28]					;SDWMAX
	PUSH	[EBP+24]					;address of prompt1
	PUSH	[EBP+20]					;userInputSize
	PUSH	[EBP+16]					;address of userInput
	PUSH	[EBP+12]					;address of signedNum
	PUSH	[EBP+8]						;address of isValid
	CALL	readVal

	; If Valid, Store Input in Array and Increment Counter
	MOV		ESI, [EBP+8]				;isValid
	CMP		BYTE PTR [ESI], 1				
	MOV		BYTE PTR [ESI], 0
	JNE		_NextElement
	MOV		ESI, [EBP+12]				;signedNum
	MOVSD	
	LOOP	_NextElement

	; Restore Registers and Return
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		44

getUserInputs ENDP

; ---------------------------------------------------------------------------------
; Name: readVal
;
; Converts string entered by user to signed number and validates if it is within
; range for SDWORD.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			Requires mGetString MACRO and mDisplayString  MACRO.
;		
;
; Postconditions: Uses registers but restores them (EBP, EAX, EBX, ECX, EDX, 
;			EDI, ESI). 
;
; Receives:
;		Stack Parameters: 
;			error (by reference) = address of error message
;			inputLen (by reference) = address for number of characters inputted
;			SDWMIN = lowest signed 32 bit integer value
;			SDWMAX = greatest signed 32 bit integer value
;			prompt1	(by reference) = address of prompt for user to enter number
;			userInputSize = buffer size for input
;			userInput (by reference) = address for string user inputs
;			signedNum (by reference) = address to store outputted SDWORD
;			isValid (by reference) = address to store if number is written or not
;
; Returns: 
;		isValid = 1 if it is valid and was written 0 if not
;		signedNum (by reference) = address to store outputed SDWORD
;		
; ---------------------------------------------------------------------------------
readVal PROC

	; Preserve Registers
	LOCAL	hasSign:BYTE, isNeg:BYTE, isPos:BYTE, oFlag
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	; Set Registers and Local Variables
	MOV		ESI, [EBP+16]					;userInput
	MOV		hasSign, 0
	MOV		isNeg, 0
	MOV		isPos, 0
	MOV		oFlag, 0

	; Get Input from User  params: (prompt1, userInputSize, userInput, inputLen)
	mGetString	[EBP+24], [EBP+20], [EBP+16], [EBP+36] 									
	
	;---------------------------------------
	; Checks for No Input
	;---------------------------------------
	; If User Didn't Input Anything, Display Error Message and Return
	CMP		BYTE PTR [ESI], 0
	JE		_PrintError

	;---------------------------------------
	; Checks Length of Input
	;---------------------------------------
	; Set Registers
	MOV		EDI, [EBP+36]				;inputLen
	MOV		ECX, [EDI]
	XOR		EAX, EAX

	; If More than 11 Characters Entered, Display Error Message and Return
	CMP		ECX, 11
	JG		_PrintError

	;---------------------------------------
	; Checks If First Character is a Sign
	;---------------------------------------
	CLD

	; If First Character is a +, Move to Next Char, DEC Count, Go to Loop
	CMP		BYTE PTR [ESI], '+'
	JE		_PlusSign

	; If First Character is a -, Move to Next Char, DEC Count, Go to Loop 
	CMP		BYTE PTR [ESI], '-'
	JNE		_IsDigitLoop
	INC		ESI
	DEC		ECX
	MOV		hasSign, 1
	MOV		isNeg, 1
	JMP		_IsDigitLoop

_PlusSign:
	INC		ESI
	DEC		ECX
	MOV		hasSign, 1
	MOV		isPos, 1

	;---------------------------------------
	; Checks Characters are Digits
	;---------------------------------------'
_IsDigitLoop:
	LODSB

	; If Character Code is less than Zero's, Print Error
	CMP		AL, '0'
	JB		_PrintError

	; If it is Greater than 9's, Print Error
	CMP		AL, '9'
	JA		_PrintError

	LOOP	_IsDigitLoop
	
	;---------------------------------------
	; Converts to SDWORD and Checks for Valid SDWORD Range
	;---------------------------------------
	; Reset Registers
	MOV		ESI, [EBP+16]					;userInput
	MOV		ECX, [EDI]						;inputLen
	XOR		EBX, EBX
	XOR		EDX, EDX
	CLD

	; If Signed, Start at Second Character
	CMP		hasSign, 1
	JNE		_Convert
	INC		ESI
	DEC		ECX

COMMENT !
;___ FPU for this???
	FINIT
_Convert:
	; Convert from ASCII to Signed Digit. 
	; result = 10*result+(n-48) = 10 result * n 48 - +
	XOR		EAX, EAX
	LODSB
	FILD	EAX
	FILD	EBX
	FMUL


	LOOP	_Convert
!

_Convert:
	; Convert from ASCII to Signed Digit. result = 10*result+(n-48)
	XOR		EAX, EAX
	LODSB
	SUB		EAX, 48
	MOV		EBX, EAX
	MOV		EAX, 10
	IMUL	EDX

	;If Overflow, Display Error message
	JO		_PrintError
	ADD		EAX, EBX

	;If Overflow Flag
	JNO		_Continue
	MOV		oFlag, 1
_Continue:
	MOV		EDX, EAX
	LOOP	_Convert
	
	; If Negative, Invert
	CMP		isNeg, 1
	JNE		_CheckRange
	NEG		EAX

	; If Minimum Value, Store and Return
	CMP		EAX, [EBP+32]				;SDMIN
	JE		_StoreResult

_CheckRange:
	; If Overflow, Display Error message
	CMP		oFlag, 1
	JE		_PrintError

	;---------------------------------------
	; Stores Result or Prints Error and Returns
	;---------------------------------------
_StoreResult:
	; Store Result
	MOV		EDI, [EBP+12]					;signedNum
	MOV		[EDI], EAX						;signedNum
	MOV		EDI, [EBP+8]					;isValid
	MOV		DWORD PTR [EDI], 1				;isValid
	JMP		_Return

_PrintError:
	; Print Error
	mDisplayString	[EBP+40]				;error

_Return:
; Restore Registers and Return
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		36

readVal ENDP

; ---------------------------------------------------------------------------------
; Name: writeVal
;
; Converts signed DWORD to string in reverse order.  Reverses string to correct 
; order. Then displays the correct value. Sign is added for negative numbers.
;
; Preconditions: Parameters pushed on to stack in order listed below under Receives.
;			Requires mdisplayString MACRO.
;		
;
; Postconditions: Uses registers but restores them (EBP, EAX, EBX, EDX, EDI, ESI). 
;			Changes processedStr, tempStr. Displays string of DWORD value.
;
; Receives:
;		Stack Parameters: 
;			SDWMAX = maximum 32 bit signed integer
;			SDWMIN = minimum 32 bit signed integer
;			tempStr (by reference) = used to process value
;			pStringLen = length of processedStr
;			processedStr (by reference) = address to store string output
;			a DWORD value = value to be converted and printed
;
; Returns:
;		Displays converted number using mDisplayString MACRO.
;		
; ---------------------------------------------------------------------------------
writeVal PROC
	; Preserve Registers
	LOCAL	count:DWORD, isNeg:BYTE
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		isNeg, 0

	; If Min Signed DWORD Value, Set Absolute Value
	MOV		EDX, [EBP+8]					;DWORD
	CMP		EDX, [EBP+24]					;SDWMIN
	JNE		_CheckNegative
	MOV		EDX, [EBP+28]					;SDWMAX

_CheckNegative:
	; If Negative Get Absolute Value
	CMP		EDX, 0	
	JGE		_SetRegs
	NEG		EDX
	MOV		isNeg, 1

_SetRegs:
	; Set Registers
	MOV		EAX, EDX						;DWORD to convert
	MOV		EDI, [EBP+20]					;address of tempStr
	MOV		ECX, [EBP+16]					;pStringLen
	MOV		EBX, 10
	MOV		count, 0						
	CLD

_NextDigit:
	; Calculate ASCII Code for Digit
 	CDQ
	IDIV	EBX
	PUSH	EAX
	ADD		EDX, 48

	; Store in String
	MOV		EAX, EDX
	STOSB	
	INC		count
	POP		EAX

	; If Quotient is Not 0, Continue
	CMP		EAX, 0
	JNE		_NextDigit

	; If Negative, Add Sign
	CMP		isNeg, 1								
	JNE		_Reverse
	MOV		AL, '-'
	INC		count
	STOSB

	; If Minimum SDWORD, Increment Last digit (First in tempStr)
	MOV		EDX, [EBP+8]					;DWORD
	CMP		EDX, [EBP+24]					;SDWMIN
	JNE		_Reverse
	MOV		EDI, [EBP+20]
	INC		BYTE PTR [EDI] 					;SDWMAX
	
_Reverse:
	; Set Registers for Reversal
	MOV		EDI, [EBP+12]						;address of processedStr
	MOV		ESI, [EBP+20]						;address of tempStr
	ADD		ESI, count		
	DEC		ESI									;last element
	MOV		ECX, count
	
	; Reverse String from Source to Destination
_NextElement:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_NextElement

	; Display String
	mDisplayString		[EBP+12]				;address of tempStr processedStr

	; Clear Arrays
	MOV		ECX, [EBP+16]						;pStringL
	MOV		EDI, [EBP+12]						;address of processedStr
	MOV		EAX, 0
	REP		STOSB
	MOV		EDI, [EBP+20]						;address of tempStr
	REP		STOSB

	; Restore Registers and Return
	POP		ESI
	POP		EDI
	POP		EDX
	POP		EBX
	POP		EAX
	RET		24
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