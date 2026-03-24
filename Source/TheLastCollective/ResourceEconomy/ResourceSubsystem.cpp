#include "ResourceSubsystem.h"

void UResourceSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    for (uint8 i = 0; i < static_cast<uint8>(EResourceType::People) + 1; ++i)
    {
        Resources.Add(static_cast<EResourceType>(i), 0.0f);
    }
}

void UResourceSubsystem::Deinitialize()
{
    Super::Deinitialize();
}

float UResourceSubsystem::GetResource(EResourceType Type) const
{
    const float* Value = Resources.Find(Type);
    return Value ? *Value : 0.0f;
}

void UResourceSubsystem::AddResource(EResourceType Type, float Amount)
{
    float& Current = Resources.FindOrAdd(Type);
    Current += Amount;
    OnResourceChanged.Broadcast(Type, Current);
}

bool UResourceSubsystem::ConsumeResource(EResourceType Type, float Amount)
{
    float* Current = Resources.Find(Type);
    if (!Current || *Current < Amount) return false;
    *Current -= Amount;
    OnResourceChanged.Broadcast(Type, *Current);
    return true;
}

bool UResourceSubsystem::CanAfford(const TArray<FResourceAmount>& Cost) const
{
    for (const FResourceAmount& Entry : Cost)
    {
        if (GetResource(Entry.Type) < Entry.Amount) return false;
    }
    return true;
}
