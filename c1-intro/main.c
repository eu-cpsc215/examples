/*
To have MSVC generate assembly output:

Project Properties -> C/C++ -> Output Files -> Assembler Output
*/

int sum(int a, int b)
{
	return a + b;
}

int main(int argc, char** argv)
{
	int val = sum(2, 3);
	return 0;
}
