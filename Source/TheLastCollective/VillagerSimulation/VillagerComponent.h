#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "VillagerData.h"
#include "VillagerComponent.generated.h"

class UPersonalityData;
class URelationshipGraph;

/**
 * Component attached to on-screen villager actors.
 * Holds runtime villager state and drives visible behavior.
 * When the villager goes off-screen, this component's data is serialized
 * into an FVillagerData and the actor is destroyed.
 */
UCLASS(ClassGroup = (TheLastCollective), meta = (BlueprintSpawnableComponent))
class THELASTCOLLECTIVE_API UVillagerComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UVillagerComponent();

    virtual void TickComponent(float DeltaTime, ELevelTick TickType,
        FActorComponentTickFunction* ThisTickFunction) override;

    /** Initialize from lightweight data when spawning actor for off-screen villager. */
    UFUNCTION(BlueprintCallable, Category = "Villager")
    void InitializeFromData(const FVillagerData& Data);

    /** Export current state to lightweight data for off-screen simulation. */
    UFUNCTION(BlueprintCallable, Category = "Villager")
    FVillagerData ExportToData() const;

protected:
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Villager")
    FVillagerData VillagerData;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Villager")
    TObjectPtr<UPersonalityData> Personality;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Villager")
    TObjectPtr<URelationshipGraph> Relationships;
};
