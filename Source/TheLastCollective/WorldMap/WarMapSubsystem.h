#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "WarMapSubsystem.generated.h"

class ARivalCivilization;

/** Manages war state, async raiding, and PvE threat (Substrate aliens). */
UCLASS()
class THELASTCOLLECTIVE_API UWarMapSubsystem : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "War")
    void RegisterRivalCivilization(ARivalCivilization* Rival);

    UFUNCTION(BlueprintCallable, Category = "War")
    TArray<ARivalCivilization*> GetAllRivals() const;

    /** Get current global threat level from Substrate aliens. */
    UFUNCTION(BlueprintCallable, Category = "War")
    float GetSubstrateThreatLevel() const { return SubstrateThreatLevel; }

protected:
    UPROPERTY()
    TArray<TObjectPtr<ARivalCivilization>> Rivals;

    UPROPERTY()
    float SubstrateThreatLevel = 0.0f;
};
