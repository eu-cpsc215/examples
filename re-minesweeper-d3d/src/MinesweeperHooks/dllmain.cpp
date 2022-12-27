/*=============================================================================
dllmain.cpp

References:
- https://bananamafia.dev/post/d3dhook/
- https://github.com/ps1337/endscene-hook
- https://github.com/adamhlt/D3D9-Hook-ImGui
- https://github.com/rce/d3d9-hooking-example
=============================================================================*/

/*=============================================================================
INCLUDES
=============================================================================*/

#include "pch.h"
#include <psapi.h>

#include <cstdint>
#include "utility.h"

using namespace Mine;

/*=============================================================================
MACROS / CONSTANTS
=============================================================================*/

/*=============================================================================
TYPES
=============================================================================*/

struct BoardColumn
{
    char pad[0x10];
    bool* rowHasMine;
};

struct BoardMineData
{
    char pad[0x10];
    BoardColumn** columns;
};

struct Board
{
    void* vtable;               // 0x00
    char pad[0x50];             // 0x08
    BoardMineData* mineData;    // 0x58
};

struct UiTile
{
    char pad[0x30];
    int col;                    // 0x30
    int row;                    // 0x34
};

struct UiEvent
{
    char pad[0x10];
    int type;
};

constexpr int MOUSE_ENTER = 2;
constexpr int MOUSE_LEAVE = 3;

typedef void(_fastcall* BoardUpdateFunc)(Board* board, void* uiBoardCanvas);
typedef HRESULT(APIENTRY* EndSceneFunc)(LPDIRECT3DDEVICE9 pDevice);
typedef void(_fastcall* GameResetFunc)(void* game, bool b1, bool b2, bool b3);
typedef void(_fastcall* UiTileHandleEventFunc)(UiTile* tile, UiEvent* _event);

/*=============================================================================
VARIABLES
=============================================================================*/

Board* TheBoard;
constexpr size_t BoardUpdateRva = 0x26EFC;
BoardUpdateFunc BoardUpdateTarget = nullptr;

constexpr size_t GameResetRva = 0x2AD0C;
GameResetFunc GameResetTarget = nullptr;

constexpr size_t UiTileHandleEventRva = 0x37200;
UiTileHandleEventFunc UiTileHandleEventTarget = nullptr;

EndSceneFunc EndSceneTarget = nullptr;
HWND WindowHndl = nullptr;

UiTile* HoveredTile = nullptr;

/*=============================================================================
METHODS
=============================================================================*/

/**
Hook for Board::Update(). Used to capture a pointer to the game Board object.
*/
void BoardUpdateDetour(Board* board, void* uiBoardCanvas)
{
    TheBoard = board;

    BoardUpdateTarget(board, uiBoardCanvas);
}

/**
Hook for Game::Reset().
*/
void GameResetDetour(void* game, bool b1, bool b2, bool b3)
{
    // Clear saved pointers when game is reset
    HoveredTile = nullptr;
    TheBoard = nullptr;

    GameResetTarget(game, b1, b2, b3);
}

/**
Hook for UiTile::HandleEvent(). Used to determine which tile is being hovered over.
*/
void UiTileHandleEventDetour(UiTile* tile, UiEvent* _event)
{
    if (_event->type == MOUSE_LEAVE)
    {
        HoveredTile = nullptr;
    }
    else
    {
        HoveredTile = tile;
    }

    UiTileHandleEventTarget(tile, _event);
}

/**
Hook for D3D EndScene(). Allows us to do custom rendering on top of the existing game.
*/
HRESULT EndSceneDetour(const LPDIRECT3DDEVICE9 pDevice)
{
    if (!EndSceneTarget)
    {
        throw std::runtime_error("Missing EndSceneTarget.");
    }

    if (HoveredTile && TheBoard)
    {
        auto hasMine = TheBoard->mineData->columns[HoveredTile->col]->rowHasMine[HoveredTile->row];
        if (hasMine)
        {
            // Draw a small rectangle in the corner of the screen if hovering over a mine
            int x = 1;
            int y = 1;
            int w = 10;
            int h = 10;
            D3DRECT r = { x, y, x + w, y + h };
            D3DCOLOR color = 0xFF0000;

            pDevice->Clear(1, &r, D3DCLEAR_TARGET, color, 0, 0);
        }
    }

    return EndSceneTarget(pDevice);
}

HWND hWindowEnumResult = nullptr;
BOOL CALLBACK EnumWindowCallback(HWND hWnd, LPARAM lParam)
{
    DWORD processId = 0;
    GetWindowThreadProcessId(hWnd, &processId);
    if (GetCurrentProcessId() != processId)
    {
        return TRUE;
    }

    hWindowEnumResult = hWnd;
    return FALSE;
}

HWND GetProcessWindow()
{
    EnumWindows(EnumWindowCallback, NULL);
    return hWindowEnumResult;
}

/**
Entry point for the thread. This will handle the hooking.
*/
void ThreadMain(HMODULE dllModule)
{
    /*
    Message boxes are a quick and dirty way to get debugging feedback. They can also
    be used to allow attaching a debugger to the thread. To do this:

    - Uncomment the MessageBoxA() call below.
    - Add a breakpoint somewhere after the MessageBoxA() call.
    - When the message box is shown, switch back to Visual Studio and choose "Debug" -> "Attach to Process".
    - Find the Minesweeper process and attach.
    - Switch back to Minesweeper and press OK in the message box to close it.
    - The breakpoint should be hit and you can now debug the thread as normal.
    - Visual Studio will remember the process you last attached to and provides an option "Debug" -> "Reattach to Process".
    */
    // MessageBoxA(NULL, "Thread start.", "Minesweeper", MB_OK | MB_ICONINFORMATION);

	HANDLE process = GetCurrentProcess();
	auto processFilePath = Utility::GetProcessFilePath(process);
	auto processDirPath = processFilePath.parent_path();
    auto processFileName = processFilePath.filename().string();
    auto baseAddr = Utility::GetBaseAddressForProcess();

    // Get path to hooks DLL to inject
    CHAR moduleName[MAX_PATH];
    GetModuleFileNameExA(process, dllModule, moduleName, MAX_PATH);
    auto exeDir = fs::path(moduleName).parent_path();

    /*
    Setup D3D hooks
    */

    // Get the window handle for this process
    constexpr int maxTries = 10;
    for (int i = 0; i < maxTries; ++i)
    {
        WindowHndl = GetProcessWindow();

        // The Minesweeper window may not be available right away, so wait and try again
        if (!WindowHndl)
            Sleep(500);
    }

    if (!WindowHndl)
    {
        MessageBoxA(NULL, "Failed to get window handle.", "Minesweeper", MB_OK | MB_ICONINFORMATION);
        return;
    }

    // Create D3D context
    auto d3d = Direct3DCreate9(D3D_SDK_VERSION);
    if (d3d == nullptr)
    {
        MessageBoxA(NULL, "Failed to init D3D9.", "Minesweeper", MB_OK | MB_ICONINFORMATION);
        return;
    }

    D3DPRESENT_PARAMETERS d3dpp = {};
    d3dpp.Windowed = true; // needs to be correct, otherwise CreateDevice will fail (Minesweeper is not fullscreen)
    d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
    d3dpp.hDeviceWindow = WindowHndl;

    // Create a dummy D3D device. This allows us to get the addresses of D3D functions at runtime.
    IDirect3DDevice9* dummyDevice = nullptr;
    if (d3d->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3dpp.hDeviceWindow, D3DCREATE_SOFTWARE_VERTEXPROCESSING, &d3dpp, &dummyDevice) != D3D_OK)
    {
        MessageBoxA(NULL, "Failed to create dummy D3D device.", "Minesweeper", MB_OK | MB_ICONINFORMATION);
        d3d->Release();
        return;
    }

    // Copy D3D device vtable (addresses to the various functions)
    char* d3d9DeviceTable[119];
    memcpy(d3d9DeviceTable, *reinterpret_cast<void***>(dummyDevice), sizeof(d3d9DeviceTable));

    // Cleanup D3D resources - no longer needed after we have the vtable.
    dummyDevice->Release();
    d3d->Release();

    // Get EndScene address
    EndSceneTarget = (EndSceneFunc)d3d9DeviceTable[42];

    // Board update func
    BoardUpdateTarget = (BoardUpdateFunc)(baseAddr + BoardUpdateRva);

    /*
    Setup Minesweeper hooks
    */

    UiTileHandleEventTarget = (UiTileHandleEventFunc)(baseAddr + UiTileHandleEventRva);
    GameResetTarget = (GameResetFunc)(baseAddr + GameResetRva);

    /*
    Do the hooking

    NOTE: The variable containing the target address is updated with the
    address of the new target after the detour is applied.
    */

    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    DetourAttach(&(PVOID&)EndSceneTarget, EndSceneDetour);
    DetourAttach(&(PVOID&)BoardUpdateTarget, BoardUpdateDetour);
    DetourAttach(&(PVOID&)UiTileHandleEventTarget, UiTileHandleEventDetour);
    DetourAttach(&(PVOID&)GameResetTarget, GameResetDetour);
    DetourTransactionCommit();

    // Thread runs forever or until the END key is pressed
    while (!GetAsyncKeyState(VK_END))
    {
        Sleep(1000);
    }

    /*
    Cleanup
    */

    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    DetourDetach(&(PVOID&)EndSceneTarget, EndSceneDetour);
    DetourDetach(&(PVOID&)BoardUpdateTarget, BoardUpdateDetour);
    DetourDetach(&(PVOID&)UiTileHandleEventTarget, UiTileHandleEventDetour);
    DetourDetach(&(PVOID&)GameResetTarget, GameResetDetour);
    DetourTransactionCommit();

    // MessageBoxA(NULL, "Thread end.", "Minesweeper", MB_OK | MB_ICONINFORMATION);
    ExitThread(0);
}

/**
Main entry point for the DLL.
*/
BOOL APIENTRY DllMain
(
    HMODULE hModule,
    DWORD  fdwReason,
    LPVOID lpReserved
)
{
    if (fdwReason == DLL_PROCESS_ATTACH)
    {
        // Spawn a thread to handle our hooking
        HANDLE hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ThreadMain, hModule, 0, NULL);
        if (hThread && hThread != INVALID_HANDLE_VALUE)
        {
            // Can free the handle if thread created successfully
            CloseHandle(hThread);
        }
    }

    return TRUE;
}
