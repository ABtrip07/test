#include "LotSystem.h"

void ULotSystem::Initialize(FSubsystemCollectionBase& Collection) { Super::Initialize(Collection); }
void ULotSystem::Deinitialize() { Super::Deinitialize(); }

void ULotSystem::RegisterLot(const FLotData& Data) { Lots.Add(Data.LotID, Data); }

FLotData ULotSystem::GetLotData(FName LotID) const
{
    const FLotData* Found = Lots.Find(LotID);
    return Found ? *Found : FLotData();
}

TArray<FLotData> ULotSystem::GetLotsByClan(FName ClanID) const
{
    TArray<FLotData> Result;
    for (const auto& Pair : Lots)
    {
        if (Pair.Value.OwningClanID == ClanID) Result.Add(Pair.Value);
    }
    return Result;
}
