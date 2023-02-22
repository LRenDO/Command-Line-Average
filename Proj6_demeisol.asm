TITLE Stringing Signs and Signing Strings (Proj6_demeisol.asm)

; Author: Ren Demeis-Ortiz
; Last Modified: 12.2.20
; OSU Email: demeisol@oregonstate.edu
; Course Number: CS271 Sec 400
; Project Number: 6          
; Due Date: 12.6.20
; Description: Prompts user to enter 10 signed dword integers. Receives input as 
;		a string. Validates input to make sure it is valid dword and stores all 
;		valid values in an array. Calculates sum and average. Finally it prints 
;		the integers entered, sum and average by converting the signed number 
;		back to a string before displaying it. Total sum assumed to be a valid 
;		signed 32 bit integer for calculations to be correct per instructions. 
;		Requires Irvine Library.

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt and receives string input from user.
;
; Preconditions: Pass string address for prompt and location for user input to 
;		be stored by reference. Uses ReadString and WriteString from Irvine 
;		Library and mDisplayString MACRO.
;
; Postconditions: User input is stored at second parameter. Registers are  
;		preserved and restored (EDX, ECX, EAX). 
;
; Receives: 
;		prompt (by reference) = address of prompt
;		buffSize = size of buffer for user input
;		input (by reference) =Address for storing user entered input 
;		charEntered (by reference) = Address for total characters entered
;
; Returns: 
;		input = User input
;		charEntered = Total Characters Entered by User
;		
; ------------------------------------------------------------------------------
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

; ------------------------------------------------------------------------------
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
; ------------------------------------------------------------------------------
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
intro1			BYTE	"Stringing Signs and Signing Strings "
				BYTE	"By Ren Demeis-Ortiz",13,10,13,10,0
intro2			BYTE	"This program will take 10 signed decimal integers and "
				BYTE	"calculate the sum and average of those integers.",13,10
				BYTE	"Each number must be between -2,147,483,648 and " 
				BYTE	"+2,147,483,647 and may only contain digits.",13,10
				BYTE	"The first character, however, can be a postive or "
				BYTE	"negative sign.  The numbers you enter will",13,10
				BYTE	"be displayed and then the sum and the rounded down "
				BYTE	"average of the numbers entered. The sum",13,10
				BYTE	"must be a 32 bit signed integer for a correct summation."
				BYTE	13,10,13,10,"You can begin entering your numbers below."
				BYTE	13,10,13,10,0
error			BYTE	13,10,"Woops! That wasn't a valid input. Let's try "
				BYTE	"again.",13,10,0
prompt1			BYTE	13,10,"Enter a 32 bit signed integer: ",0
listTitle		BYTE	13,10,"You Entered:",13,10,0
spacer			BYTE	", ",0
sumTitle		BYTE	13,10,13,10,"Sum: ",0
avgTitle		BYTE	13,10,"Average (rounded down to nearest integer): ",0
farewell		BYTE	13,10,13,10,"Thanks for stopping by. Have a great day!"
				BYTE	13,10,13,10,0

; Array and Calculation Variables
tempStr			BYTE	12 DUP(0)					;string in reverse
processedStr	BYTE	12 DUP(0)					;string to be displayed
pStringLen		DWORD	LENGTHOF processedStr
userInput		BYTE	BUFFERSIZE DUP (0)			;string inputted by user
userInputSize	DWORD	SIZEOF userInput
outputList		SDWORD	ARRAYLEN DUP (0)			;inputs as signed numbers
typeSize		DWORD	TYPE outputList
inputLen		DWORD	?
sum				SDWORD	0
average			SDWORD	0
isValid			DWORD	0
signedNum		SDWORD	?

.code
main PROC
 
	; Introduce Program
	PUSH	OFFSET intro1
	PUSH	OFFSET intro2
	CALL	introduction	

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
	PUSH	OFFSET spacer
	PUSH	SDWMAX
	PUSH	SDWMIN
	PUSH	OFFSET tempStr
	PUSH	pStringLen
	PUSH	OFFSET processedStr
	PUSH	ARRAYLEN
	PUSH	OFFSET listTitle
	PUSH	OFFSET outputList
	CALL	displayList

	; Calculate Average and Sum
	PUSH	typeSize
	PUSH	OFFSET average
	PUSH	OFFSET sum
	PUSH	OFFSET outputList
	PUSH	ARRAYLEN
	CALL	calcAverage

	; Display Sum 
	mdisplayString	OFFSET sumTitle
	PUSH	SDWMAX
	PUSH	SDWMIN
	PUSH	OFFSET tempStr
	PUSH	pStringLen
	PUSH	OFFSET processedStr
	PUSH	sum
	CALL	WriteVal

	; Display Average
	mdisplayString	OFFSET avgTitle
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

	mDisplayString [EBP+12]					;address of intro1

	mDisplayString [EBP+8]					;address of intro2

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
; Postconditions: Uses registers but restores them (EBP, ECX, EDI, ESI). 
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
	PUSH	ECX
	PUSH	EDI
	PUSH	ESI

	; Set Registers
	MOV		ECX, [EBP+48]					;ARRAYLEN
	MOV		EDI, [EBP+44]					;outputList

_NextElement:
	; Get User Input
	PUSH	[EBP+40]						;address of error
	PUSH	[EBP+36]						;address of inputLen
	PUSH	[EBP+32]						;SDWMIN
	PUSH	[EBP+28]						;SDWMAX
	PUSH	[EBP+24]						;address of prompt1
	PUSH	[EBP+20]						;userInputSize
	PUSH	[EBP+16]						;address of userInput
	PUSH	[EBP+12]						;address of signedNum
	PUSH	[EBP+8]							;address of isValid
	CALL	readVal

	; If Valid, Store Input in Array and Increment Counter
	MOV		ESI, [EBP+8]					;isValid
	CMP		BYTE PTR [ESI], 1				
	MOV		BYTE PTR [ESI], 0
	JNE		_NextElement
	MOV		ESI, [EBP+12]					;signedNum
	MOVSD	
	LOOP	_NextElement

	; Restore Registers and Return
	POP		ESI
	POP		EDI
	POP		ECX
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
	MOV		EDI, [EBP+36]					;inputLen
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
	CMP		EAX, [EBP+32]					;SDMIN
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
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		isNeg, 0

	; If Min Signed DWORD Value, Set Absolute Value
	MOV		EDX, [EBP+8]					;DWORD
	CMP		EDX, [EBP+24]					;SDWMIN
	JNE		_CheckNegative
	MOV		isNeg, 1
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
	MOV		EDI, [EBP+20]					;tempStr
	INC		BYTE PTR [EDI] 					;SDWMAX
	
_Reverse:
	; Set Registers for Reversal
	MOV		EDI, [EBP+12]					;address of processedStr
	MOV		ESI, [EBP+20]					;address of tempStr
	ADD		ESI, count		
	DEC		ESI								;last element
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
	POP		ECX
	POP		EBX
	POP		EAX
	RET		24
writeVal ENDP


; ---------------------------------------------------------------------------------
; Name: displayList
;
; Prints a DWORD array to the console with one space and comma between elements.
;
; Preconditions: 5 parameters pushed to the stack in the order listed below in 
;				Receives section.
;		
;
; Postconditions: Uses ECX, EBP, ESI but preserves and restores 
;				all of them.
;
; Receives:
;		Stack Parameters: 
;			spacer (by reference) = comma and space between elements
;			SDWMAX = maximum 32 bit signed integer
;			SDWMIN = minimum 32 bit signed integer
;			tempStr (by reference) = used to process value
;			pStringLen = length of processedStr
;			processedStr (by reference) = address to store string output
;			ARRAYLEN = number of elements in array
;			listTitle (by reference) = string title to be displayed before array
;			outputList (by reference) = array to be displayed
;
; Returns: 
;		None. Displays array.
; ---------------------------------------------------------------------------------
displayList PROC
	; Preserve Registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ECX
	PUSH	ESI

	; Set Registers
	MOV		ESI, [EBP+8]					;address of array
	MOV		ECX, [EBP+16]					;length of array

	; Display Title
	mDisplayString [EBP+12]					;address of title

	
	; Display Array
_Display:
	LODSD
	PUSH	[EBP+36]						;SDWMAX
	PUSH	[EBP+32]						;SDWMIN
	PUSH	[EBP+28]						;address of tempStr
	PUSH	[EBP+24]						;pStringLen
	PUSH	[EBP+20]						;address of processedStr
	PUSH	EAX								;element
	CALL	writeVal				
	CMP		ECX, 1
	JE		_Return
	mDisplayString	[EBP+40]				;spacer
	LOOP	_Display

_Return:
	;Restore Registers and Return
	POP		ESI
	POP		ECX
	POP		EBP
	RET		36
displayList	ENDP

; ---------------------------------------------------------------------------------
; Name: calcAverage
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
;				typeSize = size of elements
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
	LOCAL	fpuCont:WORD
	PUSH	EAX
	PUSH	EBX
	PUSH	EDI
	PUSH	ESI

	; Calculate Sum
	PUSH	[EBP+24]
	PUSH	[EBP+16]						;address of sum 
	PUSH	[EBP+12]						;address of outputList
	PUSH	[EBP+8]							;ARRAYLEN (elements in array)
	CALL	calcSum

	; Set EDI and ESI 
	MOV		ESI, [EBP+16]					;address of sum 
	MOV		EDI, [EBP+20]					;address of average

	; Change Controls to Round Down
	; Credit: http://www.ray.masmcode.com/tutorial/fpuchap3.htm#fstcw
	FINIT
	FSTCW	fpuCont
	FWAIT
	OR		fpuCont, 0C00h
	FLDCW   fpuCont

	; Divide Number of Elements
	FILD	SDWORD PTR [ESI]
	FILD	SDWORD PTR [EBP+8]				;ARRAYLEN (elements in array)
	FDIV
	FISTP	SDWORD PTR [EDI]

	; Restore Registers and Return
	POP		ESI
	POP		EDI
	POP		EBX
	POP		EAX
	RET		20
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
; Postconditions: Uses registers but restores them (EBP, ECX, EDI, ESI). 
;
; Receives:
;		Stack Parameters: 
;				typeSize = size of element 
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
	PUSH	ECX
	PUSH	EDI
	PUSH	ESI


	; Set Registers to Traverse Array
	MOV		ECX, [EBP+8]					;ARRAYLEN (elements in array)
	MOV		ESI, [EBP+12]					;address of outputLlist
	MOV		EDI, [EBP+16]					;address of sum

	FINIT
	FILD	SDWORD PTR [ESI]
	ADD		ESI, [EBP+20]					;typeSize
	DEC		ECX

_NextElement:
	; Add Elements in outputList
	FILD	SDWORD PTR [ESI]
	FADD
	ADD		ESI, [EBP+20]					;typeSize
	LOOP	_NextElement
	
	; Store in sum
	FISTP	SDWORD PTR [EDI]

	; Restore registers and Return
	POP		ESI
	POP		EDI
	POP		ECX
	POP		EBP
	RET		16
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