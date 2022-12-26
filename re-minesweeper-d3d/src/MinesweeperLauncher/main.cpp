/*=============================================================================
main.cpp

Main entry point.

Nice reference for DLL injection:
http://kylehalladay.com/blog/2020/11/13/Hooking-By-Example.html
=============================================================================*/

/*=============================================================================
INCLUDES
=============================================================================*/

#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include <Windows.h>

/*=============================================================================
MACROS / CONSTANTS
=============================================================================*/

/*=============================================================================
TYPES
=============================================================================*/

/*=============================================================================
VARIABLES
=============================================================================*/

/*=============================================================================
METHODS
=============================================================================*/

/**
Application entry point.
*/
int main()
{
	std::cout << "Minesweeper launcher started." << "\n";

	wchar_t exePath[MAX_PATH];
	GetModuleFileNameW(NULL, exePath, MAX_PATH);
	auto exeDir = std::filesystem::path(exePath).parent_path();
	auto minesweeperExePath = (exeDir / "Minesweeper.exe").string();
    auto dllToInjectPath = (exeDir / "MinesweeperHooks.dll").string();

	std::cout << "Using target: " << minesweeperExePath << std::endl;

	/*
	Create a process for the target game.
	*/

	STARTUPINFOA gameProcessStartupInfo;
	memset(&gameProcessStartupInfo, 0, sizeof(gameProcessStartupInfo));

	PROCESS_INFORMATION gameProcess;

	// Create the process, but suspend it so we can inject
	if (!CreateProcessA(NULL, (char*)minesweeperExePath.c_str(), NULL, NULL, FALSE, CREATE_SUSPENDED | DEBUG_ONLY_THIS_PROCESS, NULL, NULL, &gameProcessStartupInfo, &gameProcess))
	{
		std::cout << "CreateProcess failed " << GetLastError() << std::endl;
		return 1;
	}

	// Get debug access to the new process
	if (!DebugActiveProcessStop(gameProcess.dwProcessId))
	{
		std::cout << "DebugActiveProcessStop failed " << GetLastError() << std::endl;
		return 1;
	}

	/*
	Put path to injection DLL into the game process' memory.
	*/

	size_t dllPathSize = dllToInjectPath.length();
	void* dllPathRemote = VirtualAllocEx(
		gameProcess.hProcess,
		NULL, // let the system decide where to allocate the memory
		dllPathSize,
		MEM_COMMIT, // actually commit the virtual memory
		PAGE_READWRITE); // mem access for committed page

	if (!dllPathRemote)
	{
		fprintf(stderr, "Could not allocate %zd bytes in process with pid: %lu\n", dllPathSize, gameProcess.dwProcessId);
		return 1;
	}

	BOOL writeSucceeded = WriteProcessMemory(
		gameProcess.hProcess,
		dllPathRemote,
        dllToInjectPath.c_str(),
		dllPathSize,
		NULL);

	if (!writeSucceeded)
	{
		fprintf(stderr, "Could not write %zd bytes to process with pid %lu\n", dllPathSize, gameProcess.dwProcessId);
		return 1;
	}

	/*
	Load the injection DLL into the target process.
	*/

	// NOTE: Was having trouble using LoadLibraryW, should investigate sometime

	// Get address of LoadLibraryA function inside Kernel32.dll
	PTHREAD_START_ROUTINE loadLibraryFunc = (PTHREAD_START_ROUTINE)GetProcAddress(GetModuleHandle(TEXT("Kernel32.dll")), "LoadLibraryA");
	if (loadLibraryFunc == NULL)
	{
		fprintf(stderr, "Could not find LoadLibraryA function inside kernel32.dll\n");
		return 1;
	}

	// Create a thread in the target process using LoadLibraryW as the entry point
	DWORD remoteThreadId;
	HANDLE remoteThread = CreateRemoteThread(
		gameProcess.hProcess,
		NULL, // default thread security
		0, // stack size for thread
		loadLibraryFunc, // pointer to start of thread function (for us, LoadLibraryA)
		dllPathRemote, // pointer to variable being passed to thread function
		0, // 0 means the thread runs immediately after creation
		&remoteThreadId);

	if (remoteThread == NULL)
	{
		fprintf(stderr, "Could not create remote thread.\n");
		return 1;
	}
	else
	{
		fprintf(stdout, "Success! remote thread started in process %d\n", gameProcess.dwProcessId);
	}

	// Wait for the remote thread to terminate
	WaitForSingleObject(remoteThread, INFINITE);

	// Verify that LoadLibrary loaded the injection DLL successfully
	DWORD exitCode;
	if (!GetExitCodeThread(remoteThread, &exitCode))
	{
		MessageBoxA(NULL, "Failed to get thread exit code.", "OOPS", MB_OK | MB_ICONINFORMATION);
	}

	if (exitCode == 0)
	{
		MessageBoxA(NULL, "LoadLibrary thread failed.", "OOPS", MB_OK | MB_ICONINFORMATION);
	}

	/*
	Let the game process run and let the injected DLL take over.
	*/

	ResumeThread(gameProcess.hThread);
	WaitForSingleObject(gameProcess.hProcess, INFINITE);

	// Free memory allocated in the game process for injection DLL path
	VirtualFreeEx(gameProcess.hProcess, dllPathRemote, 0, MEM_RELEASE);

	CloseHandle(remoteThread);
	CloseHandle(gameProcess.hProcess);
	CloseHandle(gameProcess.hThread);

	return 0;
}
