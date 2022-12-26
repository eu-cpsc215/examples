/*=============================================================================
INCLUDES
=============================================================================*/

#include "pch.h"

#include <psapi.h>

#include "utility.h"

/*=============================================================================
NAMESPACE
=============================================================================*/

namespace Mine {

/*=============================================================================
PUBLIC METHODS
=============================================================================*/

uint64_t Utility::GetBaseAddressForProcess()
{
    HANDLE process = GetCurrentProcess();
    HMODULE processModules[1024];
    DWORD numBytesWrittenInModuleArray = 0;
    EnumProcessModules(process, processModules, sizeof(HMODULE) * 1024, &numBytesWrittenInModuleArray);

    DWORD numRemoteModules = numBytesWrittenInModuleArray / sizeof(HMODULE);
    CHAR processName[MAX_PATH];
    GetModuleFileNameExA(process, NULL, processName, MAX_PATH); // a null module handle gets the process name
    _strlwr_s(processName, MAX_PATH);

    HMODULE module = 0; // An HMODULE is the DLL's base address 

    for (DWORD i = 0; i < numRemoteModules; ++i)
    {
        CHAR moduleName[MAX_PATH];
        CHAR absoluteModuleName[MAX_PATH];
        GetModuleFileNameExA(process, processModules[i], moduleName, MAX_PATH);

        _fullpath(absoluteModuleName, moduleName, MAX_PATH);
        _strlwr_s(absoluteModuleName, MAX_PATH);

        if (strcmp(processName, absoluteModuleName) == 0)
        {
            module = processModules[i];
            break;
        }
    }

    return (uint64_t)module;
}

fs::path Utility::GetProcessFilePath(HANDLE process)
{
    CHAR processName[MAX_PATH];
    GetModuleFileNameExA(process, NULL, processName, MAX_PATH); // null module handle gets the process name
    return fs::path(processName);
}

}
