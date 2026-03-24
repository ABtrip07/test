#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "GodKingPlayerController.generated.h"

class UHUDManager;
class UInputMappingContext;

/** Camera mode states for the dual-view system. */
UENUM(BlueprintType)
enum class ECameraMode : uint8
{
    TopDown,      // RTS strategic view
    ThirdPerson   // 3rd person combat view
};

/**
 * Player controller handling camera mode transitions, input context switching,
 * and decree issuance UI.
 */
UCLASS()
class THELASTCOLLECTIVE_API AGodKingPlayerController : public APlayerController
{
    GENERATED_BODY()

public:
    AGodKingPlayerController();

    UFUNCTION(BlueprintCallable, Category = "Camera")
    void SwitchCameraMode(ECameraMode NewMode);

    UFUNCTION(BlueprintCallable, Category = "Camera")
    ECameraMode GetCurrentCameraMode() const { return CurrentCameraMode; }

protected:
    virtual void BeginPlay() override;
    virtual void SetupInputComponent() override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
    ECameraMode CurrentCameraMode = ECameraMode::TopDown;

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputMappingContext> TopDownMappingContext;

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputMappingContext> ThirdPersonMappingContext;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "UI")
    TObjectPtr<UHUDManager> HUDManager;
};
