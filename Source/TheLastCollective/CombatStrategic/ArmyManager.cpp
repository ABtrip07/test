#include "ArmyManager.h"
#include "SquadUnit.h"

void UArmyManager::Initialize(FSubsystemCollectionBase& Collection) { Super::Initialize(Collection); }
void UArmyManager::Deinitialize() { Super::Deinitialize(); }

void UArmyManager::RegisterSquad(ASquadUnit* Squad)
{
    if (Squad) AllSquads.AddUnique(Squad);
}

TArray<ASquadUnit*> UArmyManager::GetSquadsByLieutenant(FName LieutenantID) const
{
    TArray<ASquadUnit*> Result;
    for (const auto& Squad : AllSquads)
    {
        if (Squad && Squad->LieutenantID == LieutenantID) Result.Add(Squad);
    }
    return Result;
}

float UArmyManager::GetTotalArmyPower() const
{
    float Total = 0.0f;
    for (const auto& Squad : AllSquads)
    {
        if (Squad) Total += Squad->GetEffectiveCombatPower();
    }
    return Total;
}
