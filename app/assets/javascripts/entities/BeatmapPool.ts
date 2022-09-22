import { Beatmap } from "./Beatmap";
import Player from "./Player";

export enum PoolBeatmapCategory {
  Nomod = "nm",
  HardRock = "hr",
  Hidden = "hd",
  DoubleTime = "dt",
  ForcedMod = "form",
  FreeMod = "frem",
}

/**
 * Represents a beatmap that is part of a pool.
 */
export type PoolBeatmap = Beatmap & {
  category: PoolBeatmapCategory;
}

/**
 * Represents a pool of beatmaps that can be used in a match.
 */
export type BeatmapPool = {
  name: string;
  created_by: Player;
  created_at: string;
  updated_at: string;
  beatmaps: PoolBeatmap[];
}
