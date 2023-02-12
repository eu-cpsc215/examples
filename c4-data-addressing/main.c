// Declare function defined in the assembly module
void _program();

// Main entry point
void main()
{
	// Review of pointers:

	int myVar = 4;
	int* myPtr = &myVar;   // Stores the address of myVar in myPtr

	// Use the indirection operator * to dereference a pointer and get the value being pointed to
	int yourVar = *myPtr;

	// Use the indirection operator to update the value being pointed to
	*myPtr = 2;

	// Create another pointer and assigns the value of myPtr (the address of myVar)
	int* yourPtr = myPtr;
	yourVar = *yourPtr;

	_program();
}
