#include "WorldMapSubsystem.h"
#include "LotSystem.h"
#include "ClanManager.h"

void UWorldMapSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
}

void UWorldMapSubsystem::Deinitialize()
{
    Super::Deinitialize();
}

ULotSystem* UWorldMapSubsystem::GetLotSystem() const
{
    return GetWorld()->GetSubsystem<ULotSystem>();
}

UClanManager* UWorldMapSubsystem::GetClanManager() const
{
    return GetWorld()->GetSubsystem<UClanManager>();
}
