#include "RivalCivilization.h"

ARivalCivilization::ARivalCivilization()
{
    PrimaryActorTick.bCanEverTick = false;
}

void ARivalCivilization::BeginPlay()
{
    Super::BeginPlay();
}

void ARivalCivilization::TickCivilization(float DeltaTime)
{
    // TODO: Update rival civ AI - resource growth, aggression, territory expansion
}
