import { BeatmapPool } from "./BeatmapPool";
import { MatchTeam } from "./MatchTeam";
import { Tournament } from "./Tournament";

export type Match = {
  id: number;
  round_name: string;
  match_timestamp: string;
  red_team: MatchTeam;
  blue_team: MatchTeam;
  winning_team: MatchTeam;
  tournament?: Tournament;
  online_id: number;
  beatmap_pool?: BeatmapPool;
};
