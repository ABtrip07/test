#include "VillagerComponent.h"
#include "PersonalityData.h"
#include "RelationshipGraph.h"

UVillagerComponent::UVillagerComponent()
{
    PrimaryComponentTick.bCanEverTick = true;
}

void UVillagerComponent::BeginPlay()
{
    Super::BeginPlay();
}

void UVillagerComponent::TickComponent(float DeltaTime, ELevelTick TickType,
    FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
    // TODO: Drive visible villager behavior based on needs, personality, etc.
}

void UVillagerComponent::InitializeFromData(const FVillagerData& Data)
{
    VillagerData = Data;
}

FVillagerData UVillagerComponent::ExportToData() const
{
    return VillagerData;
}
