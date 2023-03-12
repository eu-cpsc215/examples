#include <stdio.h>
#include <math.h>
#include <Windows.h>
#include <string.h>

#define MAXTIMES (100)

void main(int* argc, char** argv)
{
	int numTimes = 5;

	if (argc > 1)
	{
		numTimes = atoi(argv[1]);
		numTimes = min(MAXTIMES, max(0, numTimes));
	}

	printf("Output: ");

	for (int i = 0; i < numTimes; i++)
	{
		if (i > 0)
			printf(", ");

		printf("%i", i + 1);
	}

	printf("\r\n");
}
