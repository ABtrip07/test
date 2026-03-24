#pragma once

#include "CoreMinimal.h"
#include "VillagerData.generated.h"

/** Enumeration of villager needs that drive behavior. */
UENUM(BlueprintType)
enum class EVillagerNeed : uint8
{
    Food,
    Shelter,
    Safety,
    Social,
    Faith,
    Purpose
};

/** Lightweight data representation for off-screen villagers. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FVillagerData
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    FName VillagerID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    FText DisplayName;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    FVector LastKnownLocation;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager|Needs")
    TMap<EVillagerNeed, float> Needs;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    FName AssignedLotID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    FName ClanID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    float Faith = 50.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Villager")
    float Morale = 50.0f;
};
