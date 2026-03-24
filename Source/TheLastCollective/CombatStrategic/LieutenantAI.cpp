#include "LieutenantAI.h"
#include "WorldBuilding/DecreeSystem.h"

ULieutenantAI::ULieutenantAI()
{
    PrimaryComponentTick.bCanEverTick = false;
}

void ULieutenantAI::BeginPlay()
{
    Super::BeginPlay();
}

void ULieutenantAI::AssignDecree(const FDecree& Decree)
{
    // TODO: Interpret decree type and begin execution plan
}

void ULieutenantAI::TickAI(float DeltaTime)
{
    // TODO: Progress on assigned decrees, manage squads
}
