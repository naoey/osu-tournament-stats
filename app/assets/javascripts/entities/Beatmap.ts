import { Player } from "./Player";

export enum BeatmapAvailability {
  Official,
  Mirror,
  Self,
}

export type Beatmap = {
  name: string;
  artist: string;
  mapper: Player;
  star_difficulty: number;
  difficulty_name: number;
  bpm?: number;
  duration: number;
  max_combo: number;
  availability: BeatmapAvailability;
}
