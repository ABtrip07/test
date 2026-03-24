#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "ArmyManager.generated.h"

class ASquadUnit;

/** Manages all squads and army composition. */
UCLASS()
class THELASTCOLLECTIVE_API UArmyManager : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "Army")
    void RegisterSquad(ASquadUnit* Squad);

    UFUNCTION(BlueprintCallable, Category = "Army")
    TArray<ASquadUnit*> GetSquadsByLieutenant(FName LieutenantID) const;

    UFUNCTION(BlueprintCallable, Category = "Army")
    float GetTotalArmyPower() const;

protected:
    UPROPERTY()
    TArray<TObjectPtr<ASquadUnit>> AllSquads;
};
