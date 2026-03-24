#include "GodKingCharacter.h"
#include "GodKingCombatComponent.h"

AGodKingCharacter::AGodKingCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
    CombatComponent = CreateDefaultSubobject<UGodKingCombatComponent>(TEXT("CombatComponent"));
}

void AGodKingCharacter::BeginPlay()
{
    Super::BeginPlay();
}

void AGodKingCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    // TODO: Bind Enhanced Input actions
}

void AGodKingCharacter::EnterCombatMode()
{
    bIsInCombatMode = true;
    // TODO: Notify controller for camera switch
}

void AGodKingCharacter::ExitCombatMode()
{
    bIsInCombatMode = false;
    // TODO: Notify controller for camera switch
}
