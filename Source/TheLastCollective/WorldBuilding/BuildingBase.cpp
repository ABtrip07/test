#include "BuildingBase.h"

ABuildingBase::ABuildingBase()
{
    PrimaryActorTick.bCanEverTick = false;
    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    RootComponent = SceneRoot;
}

void ABuildingBase::BeginPlay()
{
    Super::BeginPlay();
}

void ABuildingBase::OnConstructionComplete()
{
    // TODO: Notify resource system, enable building functionality
}
