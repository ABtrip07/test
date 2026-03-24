#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "PersonalityData.generated.h"

/** Personality traits that influence villager behavior and relationships. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FPersonalityTraits
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Personality", meta = (ClampMin = "0.0", ClampMax = "1.0"))
    float Courage = 0.5f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Personality", meta = (ClampMin = "0.0", ClampMax = "1.0"))
    float Loyalty = 0.5f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Personality", meta = (ClampMin = "0.0", ClampMax = "1.0"))
    float Industriousness = 0.5f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Personality", meta = (ClampMin = "0.0", ClampMax = "1.0"))
    float Sociability = 0.5f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Personality", meta = (ClampMin = "0.0", ClampMax = "1.0"))
    float Piety = 0.5f;
};

/**
 * Data asset defining a villager's personality configuration.
 * Can be shared across archetypes or unique per villager.
 */
UCLASS(BlueprintType)
class THELASTCOLLECTIVE_API UPersonalityData : public UDataAsset
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Personality")
    FPersonalityTraits Traits;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Personality")
    FText PersonalityDescription;
};
