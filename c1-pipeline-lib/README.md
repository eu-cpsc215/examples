# Static Library Example

This project outputs static library. You can see this in Visual Studio by right-clicking on the project in the Solution Explorer and clicking `Properties`. In the `General` section, the `Configuration Type` property is set to `Static library (.lib)`.

To consumer the library in another project:
- Build the static library project.
- Copy the library output (`bin/x64/Debug/c1-pipeline-lib.lib`) into the consumer project directory.
- Copy the header file (`c1-pipeline-lib.h`) into the consumer project directory.
- Add the library as dependency for linking in the consumer project. In the consumer project's properties, go to `Linker` -> `Input`. In the `Additional Dependencies` property, open the drop-down menu and click `Edit`. Enter the name of the library file.
- Include the header file in the consumer project's code and call the function.
