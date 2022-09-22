import Player from "./Player";

export type MatchTeam = {
  name?: string;
  players: Player[];
  captain: Player;
  id: number;
}
