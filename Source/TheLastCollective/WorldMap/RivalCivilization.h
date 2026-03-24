#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "RivalCivilization.generated.h"

/** Represents a rival AI civilization on the world map. */
UCLASS(Blueprintable)
class THELASTCOLLECTIVE_API ARivalCivilization : public AActor
{
    GENERATED_BODY()

public:
    ARivalCivilization();

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Civilization")
    FName CivilizationID;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Civilization")
    FText CivilizationName;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Civilization")
    float ThreatLevel = 0.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Civilization")
    float Hostility = 50.0f;

    UFUNCTION(BlueprintCallable, Category = "Civilization")
    void TickCivilization(float DeltaTime);

protected:
    virtual void BeginPlay() override;
};
