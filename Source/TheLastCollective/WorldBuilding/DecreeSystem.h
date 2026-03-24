#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "DecreeSystem.generated.h"

/** Types of decrees the God-King can issue. */
UENUM(BlueprintType)
enum class EDecreeType : uint8
{
    Build,
    Gather,
    Research,
    Defend,
    Attack,
    Recruit,
    Celebrate,
    Exile
};

/** A decree issued by the God-King, interpreted by lieutenants. */
USTRUCT(BlueprintType)
struct THELASTCOLLECTIVE_API FDecree
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Decree")
    EDecreeType Type = EDecreeType::Build;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Decree")
    FName TargetID;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Decree")
    int32 Priority = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Decree")
    float TimeIssued = 0.0f;
};

/**
 * Manages the decree queue. Player issues high-level orders;
 * lieutenants interpret and execute them.
 */
UCLASS()
class THELASTCOLLECTIVE_API UDecreeSystem : public UWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;
    virtual void Deinitialize() override;

    /** Issue a new decree from the God-King. */
    UFUNCTION(BlueprintCallable, Category = "Decree")
    void IssueDecree(const FDecree& Decree);

    /** Get all active decrees, sorted by priority. */
    UFUNCTION(BlueprintCallable, Category = "Decree")
    TArray<FDecree> GetActiveDecrees() const;

    /** Cancel a decree by target ID. */
    UFUNCTION(BlueprintCallable, Category = "Decree")
    void CancelDecree(FName TargetID);

protected:
    UPROPERTY()
    TArray<FDecree> ActiveDecrees;
};
