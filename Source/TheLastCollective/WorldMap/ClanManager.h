#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "ClanManager.generated.h"

/** Data for a 5-person clan unit. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FClanData
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Clan")
    FName ClanID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Clan")
    FText ClanName;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Clan")
    TArray<FName> MemberIDs;  // Max 5

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Clan")
    FName CoalitionID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Clan")
    float ClanLoyalty = 50.0f;
};

/** Manages clans (5-person units) and coalitions. */
UCLASS()
class THELASTCOLLECTIVE_API UClanManager : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable, Category = "Clan")
    void RegisterClan(const FClanData& Data);

    UFUNCTION(BlueprintCallable, Category = "Clan")
    FClanData GetClanData(FName ClanID) const;

protected:
    UPROPERTY()
    TMap<FName, FClanData> Clans;
};
