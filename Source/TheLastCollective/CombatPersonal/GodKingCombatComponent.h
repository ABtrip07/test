#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "GodKingCombatComponent.generated.h"

/**
 * Handles God-King's personal combat abilities in 3rd person mode.
 * Melee/improvised ranged attacks (no gunpowder).
 */
UCLASS(ClassGroup = (TheLastCollective), meta = (BlueprintSpawnableComponent))
class THELASTCOLLECTIVE_API UGodKingCombatComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UGodKingCombatComponent();

    UFUNCTION(BlueprintCallable, Category = "Combat")
    void PerformLightAttack();

    UFUNCTION(BlueprintCallable, Category = "Combat")
    void PerformHeavyAttack();

    UFUNCTION(BlueprintCallable, Category = "Combat")
    void PerformDodge();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
    float BaseDamage = 25.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
    float AttackSpeed = 1.0f;

protected:
    virtual void BeginPlay() override;
};
