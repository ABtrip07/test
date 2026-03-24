#include "WarMapSubsystem.h"
#include "RivalCivilization.h"

void UWarMapSubsystem::Initialize(FSubsystemCollectionBase& Collection) { Super::Initialize(Collection); }
void UWarMapSubsystem::Deinitialize() { Super::Deinitialize(); }

void UWarMapSubsystem::RegisterRivalCivilization(ARivalCivilization* Rival)
{
    if (Rival) Rivals.AddUnique(Rival);
}

TArray<ARivalCivilization*> UWarMapSubsystem::GetAllRivals() const
{
    TArray<ARivalCivilization*> Result;
    for (const auto& Rival : Rivals)
    {
        if (Rival) Result.Add(Rival);
    }
    return Result;
}
