# CLAUDE.md - The Last Collective

## Project Overview
Post-apocalyptic civilization builder (UE5 C++). Player is a God-King war leader
managing a settlement via decree-based orders (not direct micromanagement). Dual faction
system: Sigil Collective (alchemy/magic) vs Quantists (quantum tech). Features idle/offline
progression, villager AI with personality and relationships, Junkbot armies, and lot-based
territory control.

## Engine & Build
- Unreal Engine 5.5, C++ primary (Blueprints for UI/prototyping only)
- Single module: TheLastCollective
- Build: UnrealBuildTool via .Build.cs / .Target.cs
- Plugins: EnhancedInput, GameplayAbilities (GAS)

## Architecture Decisions
- **Villager hybrid model**: On-screen villagers = full AActor with components.
  Off-screen = FVillagerData struct ticked in UVillagerSubsystem. Transition at
  camera frustum boundary.
- **Subsystem pattern**: UResourceSubsystem (GameInstanceSubsystem), UVillagerSubsystem
  (WorldSubsystem), UWorldMapSubsystem (WorldSubsystem), UWarMapSubsystem (WorldSubsystem).
- **Combat mode switch**: Camera + input context swap. No level streaming or map change.
  GodKingPlayerController handles the transition.
- **Lot system**: FLotData is a serializable data chunk. ULotSystem manages a TMap of lot IDs
  to FLotData.
- **Decree system**: Player issues decrees (high-level orders). Lieutenants interpret and
  execute via ULieutenantAI. This is the core "hands-off king" feel.

## Coding Standards
- **Naming**: UE5 conventions. Prefix: A (Actor), U (UObject/Component), F (struct), E (enum),
  I (interface), T (template). No Hungarian notation beyond UE prefixes.
- **File organization**: One class per file. File name matches class name (without prefix).
  e.g., UVillagerComponent -> VillagerComponent.h/.cpp
- **Headers**: Always include CoreMinimal.h first, then system headers, then project headers,
  then the .generated.h last.
- **UPROPERTY/UFUNCTION**: Always specify category. Use EditAnywhere/BlueprintReadWrite for
  designer-tunable values. Use BlueprintReadOnly for state. Use VisibleAnywhere for components.
- **Forward declarations**: Prefer forward declarations in headers over #include. Include in .cpp.
- **Subsystems over singletons**: Never use raw singletons. Use UE5 subsystem framework.
- **No raw new/delete**: Use UE5 memory management (NewObject, CreateDefaultSubobject, etc.)
- **Comments**: Use /** */ doc comments for UCLASS, USTRUCT, UPROPERTY, UFUNCTION declarations.
  Brief description of purpose. No obvious comments.
- **Modules**: Single module for Phase 0. May split into gameplay modules later
  (e.g., TLC_Combat, TLC_Simulation) when the codebase grows.

## Directory Structure (Source/TheLastCollective/)
- VillagerSimulation/ - Villager AI, personality, relationships, needs
- WorldBuilding/ - Buildings, construction, decree system
- ResourceEconomy/ - Resource types, production, consumption, trading
- CombatStrategic/ - Army management, squads, lieutenants, combat resolution
- CombatPersonal/ - God-King 3rd person character and combat components
- CameraUI/ - Player controller, camera system, HUD
- WorldMap/ - World map, lots, clans, rival civilizations, war map

## Key Patterns
- GameMode sets default pawn to AGodKingCharacter, controller to AGodKingPlayerController
- Resource system lives on GameInstance (persists across map transitions)
- World-scoped subsystems (Villager, WorldMap, WarMap) reset per level
- All gameplay-critical data structures use USTRUCT(BlueprintType) for serialization
- Decree system uses a command pattern: FDecree -> UDecreeSystem -> ULieutenantAI
