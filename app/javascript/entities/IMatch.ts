import { IBeatmapPool } from "./IBeatmapPool";
import IMatchTeam from "./IMatchTeam";

export interface IMatch {
  id: number;
  round_name: string;
  match_timestamp: string;
  red_team: IMatchTeam;
  blue_team: IMatchTeam;
  winning_team?: IMatchTeam;
  tournament_id?: number;
  online_id: number;
  beatmap_pool?: IBeatmapPool;
}
