#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "LotData.h"
#include "LotSystem.generated.h"

/** Manages the lot-based territory system. */
UCLASS()
class THELASTCOLLECTIVE_API ULotSystem : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "Lot")
    void RegisterLot(const FLotData& Data);

    UFUNCTION(BlueprintCallable, Category = "Lot")
    FLotData GetLotData(FName LotID) const;

    UFUNCTION(BlueprintCallable, Category = "Lot")
    TArray<FLotData> GetLotsByClan(FName ClanID) const;

protected:
    UPROPERTY()
    TMap<FName, FLotData> Lots;
};
