#pragma once

#include "CoreMinimal.h"
#include "ResourceTypes.generated.h"

/** Core resource types in the game economy. */
UENUM(BlueprintType)
enum class EResourceType : uint8
{
    Scrap,
    Fuel,
    Reagents,
    Data,
    Food,
    People
};

/** A quantity of a specific resource. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FResourceAmount
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Resource")
    EResourceType Type = EResourceType::Scrap;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Resource")
    float Amount = 0.0f;
};
