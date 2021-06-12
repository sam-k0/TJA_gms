/// @description Hier Beschreibung einfügen
// Sie können Ihren Code in diesem Editor schreiben
globalvar CELL_COEFFICIENT;
CELL_COEFFICIENT = 1.5

globalvar CURRENT_SPAWNX;
CURRENT_SPAWNX = 0;

globalvar SPAWN_MULTIPLIER;
SPAWN_MULTIPLIER = 8;


globalvar SONG_NAME, DIFFICULTY, OFFSET;

SONG_NAME = "n/a";
DIFFICULTY = "n/a";
OFFSET = "n/a";

var result = loadTaikoMap();

if(result)
{
readTaikoMap()
interpretTaikoMap()
}