export enum RecentActivityType {
  TournamentCreated,
  TournamentConcluded,
  MatchCreated,
  MatchCompleted,
  MatchPoolAdded,
}

export type RecentActivity = {
  type: RecentActivityType;
  data: any[];
}
