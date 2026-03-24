#include "BuildingManager.h"
#include "BuildingBase.h"

void UBuildingManager::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
}

void UBuildingManager::Deinitialize()
{
    Super::Deinitialize();
}

ABuildingBase* UBuildingManager::PlaceBuilding(TSubclassOf<ABuildingBase> BuildingClass, FTransform Transform)
{
    // TODO: Spawn building actor, register with lot system
    return nullptr;
}

void UBuildingManager::DestroyBuilding(FName BuildingID)
{
    // TODO: Remove building, notify resource system
}

TArray<ABuildingBase*> UBuildingManager::GetAllBuildings() const
{
    TArray<ABuildingBase*> Result;
    for (const auto& Pair : Buildings)
    {
        Result.Add(Pair.Value);
    }
    return Result;
}
