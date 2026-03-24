#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "HUDManager.generated.h"

/**
 * Manages all HUD widgets. Handles showing/hiding UI layers
 * based on camera mode (RTS overlay vs combat HUD).
 */
UCLASS(BlueprintType)
class THELASTCOLLECTIVE_API UHUDManager : public UObject
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category = "UI")
    void ShowTopDownHUD();

    UFUNCTION(BlueprintCallable, Category = "UI")
    void ShowCombatHUD();

    UFUNCTION(BlueprintCallable, Category = "UI")
    void ShowDecreePanel();

    UFUNCTION(BlueprintCallable, Category = "UI")
    void HideDecreePanel();
};
