#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "ResourceTypes.h"
#include "ResourceSubsystem.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnResourceChanged, EResourceType, Type, float, NewAmount);

/**
 * GameInstance subsystem managing all resources.
 * Persists across map transitions. Central authority for resource queries and mutations.
 */
UCLASS()
class THELASTCOLLECTIVE_API UResourceSubsystem : public UGameInstanceSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "Resource")
    float GetResource(EResourceType Type) const;

    UFUNCTION(BlueprintCallable, Category = "Resource")
    void AddResource(EResourceType Type, float Amount);

    UFUNCTION(BlueprintCallable, Category = "Resource")
    bool ConsumeResource(EResourceType Type, float Amount);

    UFUNCTION(BlueprintCallable, Category = "Resource")
    bool CanAfford(const TArray<FResourceAmount>& Cost) const;

    UPROPERTY(BlueprintAssignable, Category = "Resource")
    FOnResourceChanged OnResourceChanged;

protected:
    UPROPERTY()
    TMap<EResourceType, float> Resources;
};
