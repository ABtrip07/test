#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SquadUnit.generated.h"

/** Represents a squad of Junkbots on the battlefield. */
UCLASS(Blueprintable)
class THELASTCOLLECTIVE_API ASquadUnit : public AActor
{
    GENERATED_BODY()

public:
    ASquadUnit();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Squad")
    int32 UnitCount = 10;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Squad")
    float MoraleModifier = 1.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Squad")
    FName SquadID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Squad")
    FName LieutenantID;

    UFUNCTION(BlueprintCallable, Category = "Squad")
    float GetEffectiveCombatPower() const;

protected:
    virtual void BeginPlay() override;
};
