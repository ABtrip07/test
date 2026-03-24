#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "TheLastCollectiveGameMode.generated.h"

class AGodKingCharacter;
class AGodKingPlayerController;

/**
 * Primary game mode for The Last Collective.
 * Sets default pawn to AGodKingCharacter and controller to AGodKingPlayerController.
 */
UCLASS()
class THELASTCOLLECTIVE_API ATheLastCollectiveGameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    ATheLastCollectiveGameMode();
};
