#include <stdint.h>
#include <stdio.h>
#include <memory.h>
#include <Windows.h>

struct Player
{
	char name[64];
	uint8_t age;
	uint8_t height;
	uint16_t weight;
};

void main()
{
	struct Player quarterback;
	memset(&quarterback, 0, sizeof(quarterback));
	sprintf_s(&quarterback.name, sizeof(quarterback.name), "Patrick Mahomes");
	quarterback.age = 27;
	quarterback.height = 74;
	quarterback.weight = 225;

	MessageBoxA(NULL, quarterback.name, "Player Name", 0);

	// Array of players
	struct Player offensivePlayers[11];
	memset(&offensivePlayers, 0, sizeof(offensivePlayers));

	sprintf_s(&offensivePlayers[0].name, sizeof(offensivePlayers[0].name), "Bob");
	offensivePlayers[0].age = 25;
	offensivePlayers[0].height = 76;
	offensivePlayers[0].weight = 230;

	struct Player* p = &offensivePlayers[0];
	MessageBoxA(NULL, p->name, "Player Name", 0);
}
