#include "VillagerSubsystem.h"
#include "RelationshipGraph.h"

void UVillagerSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    RelationshipGraph = NewObject<URelationshipGraph>(this);
}

void UVillagerSubsystem::Deinitialize()
{
    Super::Deinitialize();
}

void UVillagerSubsystem::RegisterVillager(const FVillagerData& Data)
{
    AllVillagers.Add(Data.VillagerID, Data);
}

AActor* UVillagerSubsystem::SpawnVillagerActor(FName VillagerID)
{
    // TODO: Spawn villager actor from class, initialize UVillagerComponent from FVillagerData
    ActiveVillagerIDs.Add(VillagerID);
    return nullptr;
}

void UVillagerSubsystem::DespawnVillagerActor(FName VillagerID)
{
    // TODO: Export actor's UVillagerComponent data back to AllVillagers, destroy actor
    ActiveVillagerIDs.Remove(VillagerID);
}
