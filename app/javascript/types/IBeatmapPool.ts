import { IBeatmap } from "./IBeatmap";
import IPlayer from "./IPlayer";

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
export interface IPoolBeatmap extends IBeatmap {
  category: PoolBeatmapCategory;
}

/**
 * Represents a pool of beatmaps that can be used in a match.
 */
export interface IBeatmapPool {
  name: string;
  created_by: IPlayer;
  created_at: string;
  updated_at: string;
  beatmaps: IPoolBeatmap[];
}
