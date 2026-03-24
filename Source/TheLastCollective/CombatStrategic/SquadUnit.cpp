#include "SquadUnit.h"

ASquadUnit::ASquadUnit()
{
    PrimaryActorTick.bCanEverTick = false;
}

void ASquadUnit::BeginPlay()
{
    Super::BeginPlay();
}

float ASquadUnit::GetEffectiveCombatPower() const
{
    return UnitCount * MoraleModifier;
}
