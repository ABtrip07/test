#include "TheLastCollectiveGameMode.h"
#include "CombatPersonal/GodKingCharacter.h"
#include "CameraUI/GodKingPlayerController.h"

ATheLastCollectiveGameMode::ATheLastCollectiveGameMode()
{
    DefaultPawnClass = AGodKingCharacter::StaticClass();
    PlayerControllerClass = AGodKingPlayerController::StaticClass();
}
