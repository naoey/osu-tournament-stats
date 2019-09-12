import { IBeatmapPool } from "./IBeatmapPool";
import IPlayer from "./IPlayer";

export enum MatchType {
  Monthly = "monthly",
  Tournament = "tournament",
  ShowMatch = "show",
}

export interface IMatch {
  id: number;
  name: string;
  created_at: string;
  updated_at: string;
  timestamp: string;
  added_by: IPlayer;
  red_team: IPlayer | IPlayer[];
  red_team_captain_id?: number;
  blue_team: IPlayer | IPlayer[];
  blue_team_captain_id?: number;
  winning_team: "red" | "blue" | IPlayer;
  tournament_id?: number;
  type: MatchType;
  online_id: number;
  beatmap_pool?: IBeatmapPool;
}
