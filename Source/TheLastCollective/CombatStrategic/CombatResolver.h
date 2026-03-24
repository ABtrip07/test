#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "CombatResolver.generated.h"

class ASquadUnit;

/** Result of a combat engagement. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FCombatResult
{
    GENERATED_BODY()

    UPROPERTY(BlueprintReadOnly, Category = "Combat")
    bool bAttackerWon = false;

    UPROPERTY(BlueprintReadOnly, Category = "Combat")
    int32 AttackerCasualties = 0;

    UPROPERTY(BlueprintReadOnly, Category = "Combat")
    int32 DefenderCasualties = 0;
};

/** Resolves combat between squads using power calculations and RNG. */
UCLASS(BlueprintType)
class THELASTCOLLECTIVE_API UCombatResolver : public UObject
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category = "Combat")
    static FCombatResult ResolveCombat(const TArray<ASquadUnit*>& Attackers, const TArray<ASquadUnit*>& Defenders);
};
