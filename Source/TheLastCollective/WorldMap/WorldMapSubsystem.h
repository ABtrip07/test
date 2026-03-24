#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "WorldMapSubsystem.generated.h"

class ULotSystem;
class UClanManager;

/** High-level world map subsystem coordinating lots, clans, and territory. */
UCLASS()
class THELASTCOLLECTIVE_API UWorldMapSubsystem : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "WorldMap")
    ULotSystem* GetLotSystem() const;

    UFUNCTION(BlueprintCallable, Category = "WorldMap")
    UClanManager* GetClanManager() const;
};
