#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "LieutenantAI.generated.h"

struct FDecree;

/**
 * AI component for lieutenants that interpret and execute God-King decrees.
 * Lieutenants manage squads and carry out high-level orders autonomously.
 */
UCLASS(ClassGroup = (TheLastCollective), meta = (BlueprintSpawnableComponent))
class THELASTCOLLECTIVE_API ULieutenantAI : public UActorComponent
{
    GENERATED_BODY()

public:
    ULieutenantAI();

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Lieutenant")
    FName LieutenantID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lieutenant")
    float Competence = 0.5f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Lieutenant")
    float Loyalty = 0.5f;

    UFUNCTION(BlueprintCallable, Category = "Lieutenant")
    void AssignDecree(const FDecree& Decree);

    UFUNCTION(BlueprintCallable, Category = "Lieutenant")
    void TickAI(float DeltaTime);

protected:
    virtual void BeginPlay() override;
};
