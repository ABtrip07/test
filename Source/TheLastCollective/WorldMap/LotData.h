#pragma once

#include "CoreMinimal.h"
#include "LotData.generated.h"

/** Serializable data chunk representing a single lot in the world. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FLotData
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lot")
    FName LotID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lot")
    FVector2D WorldPosition;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lot")
    FName OwningClanID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lot")
    TArray<FName> BuildingIDs;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lot")
    TArray<FName> AssignedVillagerIDs;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lot")
    float DefenseRating = 0.0f;
};
