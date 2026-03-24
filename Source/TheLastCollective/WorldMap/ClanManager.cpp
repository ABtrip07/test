#include "ClanManager.h"

void UClanManager::Initialize(FSubsystemCollectionBase& Collection) { Super::Initialize(Collection); }
void UClanManager::Deinitialize() { Super::Deinitialize(); }

void UClanManager::RegisterClan(const FClanData& Data) { Clans.Add(Data.ClanID, Data); }

FClanData UClanManager::GetClanData(FName ClanID) const
{
    const FClanData* Found = Clans.Find(ClanID);
    return Found ? *Found : FClanData();
}
