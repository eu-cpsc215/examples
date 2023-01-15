# Environment Setup

The steps below outline how to setup a development environment for assembly programming. It uses Visual Studio and the MASM assembler with a 64-bit example program.

The steps and example code are adapted from Appendix B in the [textbook](https://www.prospectpressvt.com/textbooks/hall-assembly-programming-2-0).

1. Install Visual Studio if needed, and the workflow for desktop programming in C++.
1. Open Visual Studio and create a new C++ `Empty Project`, giving the project an appropriate name. (examples: [VS2017](screenshots/new-project-vs17.png), [VS2022](screenshots/new-project-vs22.png))
1. Once the project has been created and is open, right-click on the project in the Solution Explorer and select `Build Dependencies` → `Build Customizations`. ([example](screenshots/build-customizations.png))
1. Check the `masm` box.
1. In the Solution Explorer, right-click `Source Files` then select `Add` → `New item...`.
1. Under `Visual C++` click `Utility` then choose `Text File`. When you name the file also type the .asm extension. ([example](screenshots/create-asm-file.png))
1. In the Solution Explorer, right-click on the newly created .asm file, select `Properties`, and under `Configuration Properties` → `General` change `Item Type` to `Microsoft Macro Assembler` if not already set (should be set by default). ([example](screenshots/item-type.png))
1. In the Solution Explorer, right-click on the project, select `Properties` and within the Properties you should see a drop-down menu called `Microsoft Macro Assembler`. If the menu is missing, return to Step 2. If the menu exists, continue to Step 9.
1. In the Tool Bar, below the Menu Bar, you will see a drop-down box with the selected solution configuration and platform. Ensure that the `Debug` configuration and `x64` platform are selected. ([example](screenshots/selected-configuration-and-platform.png))
1. In the project Properties dialog, navigate to `Linker` → `System` and in the `SubSystem` drop-down box select `Windows (/SUBSYSTEM:WINDOWS)`. ([example](screenshots/subsystem-selection.png))
	* Some projects use `Console (/SUBSYSTEM:CONSOLE)` to provide a console output window.
1. In the project Properties dialog, navigate to `Linker` → `Advanced` and in the `Entry Point` box type `_main`. ([example](screenshots/entry-point.png))
1. Copy and paste the code from [appendix-b-sample.asm](appendix-b-sample.asm) into the assembly source file created earlier.
	* There is a bug in the sample provided by the textbook that can result in a program crash on some machines. The sample code provided in the repo ([appendix-b-sample.asm](appendix-b-sample.asm)) includes a fix for this.
1. Set a breakpoint at a suitable location (e.g., `mov rax, num`). ([example](screenshots/set-breakpoint.png))
1. Build and debug the program.
1. When the program halts at the breakpoint, arrange the window frames to your preference. The following windows are recommend and can be opened using the `Debug` → `Windows` menu. ([example](screenshots/debug-windows-menu.png))
	* Registers
	* Memory (choose at least Memory 1, others are optional)
	* Disassembly
	* Autos
1. Another useful option is to right-click anywhere in the Registers window and select `Flags`, which enables viewing of the flags register. Select any other registers you have interest in watching.
1. Run the program to completion.
	* There should be no crashes or exceptions; the program should terminate normally. The output window in Visual Studio will indicate the program "exited with code 0."