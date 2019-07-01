import IPlayer from "./IPlayer";

export enum BeatmapAvailability {
  Official,
  Mirror,
  Self,
}

export interface IBeatmap {
  name: string;
  artist: string;
  mapper: IPlayer;
  star_difficulty: number;
  difficulty_name: number;
  bpm?: number;
  duration: number;
  max_combo: number;
  availability: BeatmapAvailability;
}
