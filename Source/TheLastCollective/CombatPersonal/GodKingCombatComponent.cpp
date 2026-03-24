#include "GodKingCombatComponent.h"

UGodKingCombatComponent::UGodKingCombatComponent()
{
    PrimaryComponentTick.bCanEverTick = false;
}

void UGodKingCombatComponent::BeginPlay()
{
    Super::BeginPlay();
}

void UGodKingCombatComponent::PerformLightAttack()
{
    // TODO: Trigger light attack montage, enable hit detection
}

void UGodKingCombatComponent::PerformHeavyAttack()
{
    // TODO: Trigger heavy attack montage, enable hit detection
}

void UGodKingCombatComponent::PerformDodge()
{
    // TODO: Trigger dodge movement and i-frames
}
