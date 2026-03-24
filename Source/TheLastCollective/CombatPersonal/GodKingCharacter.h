#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "GodKingCharacter.generated.h"

class UGodKingCombatComponent;

/**
 * The player's God-King avatar. Used in both top-down RTS view (minimal interaction)
 * and 3rd person combat mode (full action combat).
 */
UCLASS()
class THELASTCOLLECTIVE_API AGodKingCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AGodKingCharacter();

    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

    UFUNCTION(BlueprintCallable, Category = "GodKing")
    bool IsInCombatMode() const { return bIsInCombatMode; }

    UFUNCTION(BlueprintCallable, Category = "GodKing")
    void EnterCombatMode();

    UFUNCTION(BlueprintCallable, Category = "GodKing")
    void ExitCombatMode();

protected:
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "GodKing|Combat")
    TObjectPtr<UGodKingCombatComponent> CombatComponent;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "GodKing")
    bool bIsInCombatMode = false;
};
