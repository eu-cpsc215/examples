#include <stdint.h>

int main()
{
	uint32_t fourByteInt = 0x12345678;     // Store 4-byte integer value in memory
	char* bytePtr = (char*)&fourByteInt;   // Get a pointer to that value in memory.
	char first = bytePtr[0];
	char second = bytePtr[1];
	char third = bytePtr[2];
	char fourth = bytePtr[3];

	// Set breakpoint and observe the values of the variables above.
	// Use memory debug window and observe value of bytes in memory.

	uint16_t twoByteInt = 0x2143;
	bytePtr = (char*)&twoByteInt;
	first = bytePtr[0];
	second = bytePtr[1];

	const char* str = "ABC";
	first = str[0];
	second = str[1];
	third = str[2];
	fourth = str[3];

	return 0;
}
