#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "BuildingBase.generated.h"

/**
 * Base class for all placeable buildings in the settlement.
 * Buildings are placed via the decree system, not directly by the player.
 */
UCLASS(Abstract, Blueprintable)
class THELASTCOLLECTIVE_API ABuildingBase : public AActor
{
    GENERATED_BODY()

public:
    ABuildingBase();

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Building")
    FName BuildingID;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Building")
    FText BuildingName;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Building")
    int32 MaxWorkers = 3;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Building")
    TArray<FName> AssignedWorkerIDs;

    UFUNCTION(BlueprintCallable, Category = "Building")
    virtual void OnConstructionComplete();

protected:
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Building")
    TObjectPtr<USceneComponent> SceneRoot;
};
