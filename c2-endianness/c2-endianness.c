#include <stdint.h>

int main()
{
	uint32_t fourByteInt = 0x12345678;
	char* bytePtr = (char*)&fourByteInt;
	char first = bytePtr[0];
	char second = bytePtr[1];
	char third = bytePtr[2];
	char fourth = bytePtr[3];

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
