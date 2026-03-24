#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "VillagerData.h"
#include "VillagerSubsystem.generated.h"

class URelationshipGraph;

/**
 * World subsystem managing all villagers, both on-screen (actors) and off-screen (data-only).
 * Ticks off-screen villagers at reduced fidelity for performance.
 */
UCLASS()
class THELASTCOLLECTIVE_API UVillagerSubsystem : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    /** Register a new villager from data (off-screen). */
    UFUNCTION(BlueprintCallable, Category = "Villager")
    void RegisterVillager(const FVillagerData& Data);

    /** Promote an off-screen villager to a full actor (camera entered range). */
    UFUNCTION(BlueprintCallable, Category = "Villager")
    AActor* SpawnVillagerActor(FName VillagerID);

    /** Demote an on-screen villager actor back to data-only (camera left range). */
    UFUNCTION(BlueprintCallable, Category = "Villager")
    void DespawnVillagerActor(FName VillagerID);

    /** Get the shared relationship graph. */
    UFUNCTION(BlueprintCallable, Category = "Villager")
    URelationshipGraph* GetRelationshipGraph() const { return RelationshipGraph; }

protected:
    /** All villager data, keyed by VillagerID. Includes both on-screen and off-screen. */
    UPROPERTY()
    TMap<FName, FVillagerData> AllVillagers;

    /** Set of VillagerIDs currently represented by actors. */
    UPROPERTY()
    TSet<FName> ActiveVillagerIDs;

    /** Global relationship graph shared by all villagers. */
    UPROPERTY()
    TObjectPtr<URelationshipGraph> RelationshipGraph;
};
