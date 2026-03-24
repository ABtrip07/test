#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "BuildingManager.generated.h"

class ABuildingBase;

/** Manages all buildings in the current world. */
UCLASS()
class THELASTCOLLECTIVE_API UBuildingManager : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "Building")
    ABuildingBase* PlaceBuilding(TSubclassOf<ABuildingBase> BuildingClass, FTransform Transform);

    UFUNCTION(BlueprintCallable, Category = "Building")
    void DestroyBuilding(FName BuildingID);

    UFUNCTION(BlueprintCallable, Category = "Building")
    TArray<ABuildingBase*> GetAllBuildings() const;

protected:
    UPROPERTY()
    TMap<FName, TObjectPtr<ABuildingBase>> Buildings;
};
