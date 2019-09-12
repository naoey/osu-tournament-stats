export enum RecentActivityType {
  TournamentCreated,
  TournamentConcluded,
  MatchCreated,
  MatchCompleted,
  MatchPoolAdded,
}

export interface IRecentActivity {
  type: RecentActivityType;
  data: any[];
}
