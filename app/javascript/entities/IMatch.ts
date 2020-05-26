import { IBeatmapPool } from "./IBeatmapPool";
import IMatchTeam from "./IMatchTeam";
import ITournament from "./ITournament";

export interface IMatch {
  id: number;
  round_name: string;
  match_timestamp: string;
  red_team: IMatchTeam;
  blue_team: IMatchTeam;
  winning_team?: IMatchTeam;
  tournament?: ITournament;
  online_id: number;
  beatmap_pool?: IBeatmapPool;
}
