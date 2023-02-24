#include <assert.h>
#include <stdint.h>
#include <stdio.h>

// Assembly proc declarations
void AsmBooleanBitwise();
void AsmBranching();
void AsmLooping();

int GetInt()
{
	int input;
	scanf_s("%d", &input);
	return input;
}

static void fooBar()
{
	int i = 0;
}

static void booleanBitwise()
{
	/*
	Before we look at bitwise boolean operations in assembly,
	let's review boolean operations in C.

	C doesn't have a boolean type. For logical boolean operations,
	values of zero are treated as FALSE and non-zero values are TRUE.
	----------------------------------------------------------
	*/
	
	// Simple boolean condition
	int isCold = 1;
	if (isCold)
	{
		// putOnACoat();
		fooBar();
	}

	int tempInDegrees = 31;
	if (tempInDegrees < 32)
	{
		// it's freezing
		fooBar();
	}

	/*
	Logical boolean operators deliver a boolean result: true or false.
	----------------------------------------------------------

	AND: &&
	OR:  ||
	NOT: !
	*/

	/*
	Logical AND
	----------
	F && F = 0
	F && T = 0
	T && F = 0
	T && T = 1
	*/
	int isRaining = 0;
	if (isCold && isRaining)
	{
		// startTheSnow();
		fooBar();
	}

	/*
	Logical OR
	----------
	F || F = 0
	F || T = 1
	T || F = 1
	T || T = 1
	*/
	if (isCold || isRaining)
	{
		// startTheSnow();
		fooBar();
	}

	/*
	Bitwise boolean operators apply boolean logic based on values of individual bits.
	----------------------------------------------------------

	AND: &
	OR:  |
	XOR: ^
	NOT: ~
	Left shift: <<
	Right shift: >>
	*/

	uint8_t byteA, byteB, result;

	/*
	Bitwise AND
	----------
	0 & 0 = 0
	0 & 1 = 0
	1 & 0 = 0
	1 & 1 = 1
	*/
	byteA = 11;             // 00001011
	byteB = 13;             // 00001101
	result = byteA & byteB; // 00001001 (9)
	assert(result == 9);

	/*
	Bitwise OR
	----------
	0 | 0 = 0
	0 | 1 = 1
	1 | 0 = 1
	1 | 1 = 1
	*/
	byteA = 11;             // 00001011
	byteB = 13;             // 00001101
	result = byteA | byteB; // 00001111 (15)
	assert(result == 15);

	/*
	Bitwise NOT (flip the bits)
	----------
	~0 = 1
	~1 = 0
	*/
	byteA = 0xFF;	  // 11111111
	result = ~byteA;  // 00000000 (0)
	assert(result == 0);

	byteA = 11;       // 00001011
	result = ~byteA;  // 11110100 (0xF4)
	assert(result == 0xF4);

	/*
	Practical applications of bitwise operators: bitmasking.

	We don't have control over individual bits. Bytes are the smallest
	unit we can work with. Sometimes we want to operate on bits though.
	Bitwise operations can help here.
	----------------------------------------------------------
	*/

	uint8_t mask, target;

	// Check if a specific bit is set
	mask = 2;                // 00000010 (bit to check)
	target = 11;             // 00001011 (target value)
	result = mask & target;  // 00000010 (2) (is set)
	assert(result == 2);

	mask = 4;                // 00000100 (bit to check)
	target = 11;             // 00001011 (target value)
	result = mask & target;  // 00000000 (0) (not set)
	assert(result == 0);

	// Set a specific bit
	mask = 4;                // 00000100 (bit to set)
	target = 11;             // 00001011 (target value)
	result = mask | target;  // 00001111 (15)
	assert(result == 15);

	// Clear a specific bit (flip mask bits, then AND)
	mask = 2;                   // 00000010 (bit to clear)
	target = 11;                // 00001011 (target value)
	result = (~mask) & target;  // 00001001 (9)
	assert(result == 9);

	// Bitmasking example:
	// Damage flag usage: https://github.com/id-Software/Quake-2/blob/372afde46e7defc9dd2d719a1732b8ace1fa096e/game/g_combat.c#L270
	// Damage flag def: https://github.com/id-Software/Quake-2/blob/372afde46e7defc9dd2d719a1732b8ace1fa096e/game/g_local.h#L659-L665
	// Clear bit AND/NOT: https://github.com/id-Software/Quake-2/blob/372afde46e7defc9dd2d719a1732b8ace1fa096e/game/g_combat.c#L316
	// Set bit OR: https://github.com/id-Software/Quake-2/blob/372afde46e7defc9dd2d719a1732b8ace1fa096e/game/g_combat.c#L399

	// ASCII character case example:
	char A = 'A';    // 0x41     01000001
	char a = 'a';    // 0x61     01100001
	mask = 0x20;     //          00100000 (mask of case bit)

	// Set bit to convert to lowercase
	// beware order of operations: without parentheses, result is different
	assert((A | mask) == a);
	
	// Clear bit to convert to uppercase
	assert((a & (~mask)) == A);

	// XOR can be used in the ASCII example as a toggle (works in both directions)
	assert((a ^ mask) == A);
	assert((A ^ mask) == a);

	/*
	Let's jump into some assembly code.
	----------------------------------------------------------
	*/
	AsmBooleanBitwise();
}

static void branching()
{
	// Basic if statement.
	int i = 0;
	if (i == 0)
	{
		i = 1;
	}

	// Example of if/else if constructs.
	if (i == 0)
	{
		i = 2;
	}
	else if (i == 1)
	{
		i = 3;
	}
	else if (i == 3)
	{
		i = 4;
	}

	// C also has an unconditional jump: the "goto"
	int hello = 10;
	hello++;
	goto skipIt;
	hello = 20; // This will be skipped

skipIt:
	hello++;
	assert(hello == 12);

	/*
	Let's jump into some assembly code.
	----------------------------------------------------------
	*/
	AsmBranching();
}

static void looping()
{
	AsmLooping();
}

// Program entry point
void main()
{
	booleanBitwise();
	branching();
	looping();
}
