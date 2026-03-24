#include "GodKingPlayerController.h"
#include "HUDManager.h"
#include "EnhancedInputSubsystems.h"

AGodKingPlayerController::AGodKingPlayerController()
{
}

void AGodKingPlayerController::BeginPlay()
{
    Super::BeginPlay();
    HUDManager = NewObject<UHUDManager>(this);
    // TODO: Set initial input mapping context for top-down mode
}

void AGodKingPlayerController::SetupInputComponent()
{
    Super::SetupInputComponent();
    // TODO: Bind camera toggle, decree actions via Enhanced Input
}

void AGodKingPlayerController::SwitchCameraMode(ECameraMode NewMode)
{
    if (CurrentCameraMode == NewMode) return;
    CurrentCameraMode = NewMode;
    // TODO: Swap input mapping context, transition camera, notify character
}
