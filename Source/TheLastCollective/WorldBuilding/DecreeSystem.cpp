#include "DecreeSystem.h"

void UDecreeSystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
}

void UDecreeSystem::Deinitialize()
{
    Super::Deinitialize();
}

void UDecreeSystem::IssueDecree(const FDecree& Decree)
{
    ActiveDecrees.Add(Decree);
    // TODO: Notify lieutenant system to begin processing
}

TArray<FDecree> UDecreeSystem::GetActiveDecrees() const
{
    return ActiveDecrees;
}

void UDecreeSystem::CancelDecree(FName TargetID)
{
    ActiveDecrees.RemoveAll([&](const FDecree& D) { return D.TargetID == TargetID; });
}
