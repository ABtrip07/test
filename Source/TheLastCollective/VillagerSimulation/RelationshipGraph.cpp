#include "RelationshipGraph.h"

void URelationshipGraph::SetRelationship(FName SourceID, FName TargetID, float Affinity, float Trust)
{
    FRelationshipList& List = AdjacencyMap.FindOrAdd(SourceID);
    for (FRelationshipEdge& Edge : List.Edges)
    {
        if (Edge.TargetVillagerID == TargetID)
        {
            Edge.Affinity = Affinity;
            Edge.Trust = Trust;
            return;
        }
    }
    List.Edges.Add(FRelationshipEdge{TargetID, Affinity, Trust});
}

bool URelationshipGraph::GetRelationship(FName SourceID, FName TargetID, FRelationshipEdge& OutEdge) const
{
    const FRelationshipList* List = AdjacencyMap.Find(SourceID);
    if (!List) return false;
    for (const FRelationshipEdge& Edge : List->Edges)
    {
        if (Edge.TargetVillagerID == TargetID)
        {
            OutEdge = Edge;
            return true;
        }
    }
    return false;
}
