#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "RelationshipGraph.generated.h"

/** A single directed relationship edge between two villagers. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FRelationshipEdge
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Relationship")
    FName TargetVillagerID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Relationship", meta = (ClampMin = "-100.0", ClampMax = "100.0"))
    float Affinity = 0.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Relationship")
    float Trust = 50.0f;
};

/** Wrapper for TArray<FRelationshipEdge> to support UPROPERTY TMap values. */
USTRUCT()
struct FRelationshipList
{
    GENERATED_BODY()

    UPROPERTY()
    TArray<FRelationshipEdge> Edges;
};

/**
 * Manages the social relationship graph for all villagers.
 * Stored as adjacency lists keyed by villager ID.
 */
UCLASS(BlueprintType)
class THELASTCOLLECTIVE_API URelationshipGraph : public UObject
{
    GENERATED_BODY()

public:
    /** Add or update a relationship between two villagers. */
    UFUNCTION(BlueprintCallable, Category = "Relationship")
    void SetRelationship(FName SourceID, FName TargetID, float Affinity, float Trust);

    /** Get the relationship from Source to Target. Returns false if none exists. */
    UFUNCTION(BlueprintCallable, Category = "Relationship")
    bool GetRelationship(FName SourceID, FName TargetID, FRelationshipEdge& OutEdge) const;

protected:
    /** Adjacency list: VillagerID -> array of outgoing relationship edges. */
    UPROPERTY()
    TMap<FName, FRelationshipList> AdjacencyMap;
};
