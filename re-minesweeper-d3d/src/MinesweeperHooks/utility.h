/*=============================================================================
Shared utility code.
=============================================================================*/

#pragma once

#include "pch.h"

namespace Mine
{
    class Utility
    {
    public:

        /// <summary>
        /// Gets base address of the current process.
        /// </summary>
        /// <returns></returns>
        static uint64_t GetBaseAddressForProcess();

        /// <summary>
        /// Gets full file path to process executable.
        /// </summary>
        static fs::path GetProcessFilePath(HANDLE process);
    };
}
