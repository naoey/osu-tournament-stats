import IPlayer from "./IPlayer";

export interface IPlayerStatistic {
  player: IPlayer;
  matches_played: number;
  matches_won: number;
  maps_played: number[];
  maps_won: number[];
  total_score: number;
  average_score: number;
  accuracy: number;
  perfect_maps: number[];
  average_misses: number;
  total_misses: number;
  best_accuracy: { beatmap_id: number, accuracy: number };
  average_accuracy: number;
  maps_failed: number[];
  online_id: number;
  full_combos: number[];
}
