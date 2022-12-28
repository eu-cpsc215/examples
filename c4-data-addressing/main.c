// Declare function defined in the assembly module
void _program();

// Main entry point
void main()
{
	// Review of pointers:

	int variable = 2;
	int* pointerToVariable = &variable;

	// "De-referencing" a pointer to get the value being pointed to
	int valueOfVariable = *pointerToVariable; 

	// At the end of the day, data has to be stored in memory.

	_program();
}
