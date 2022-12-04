import { Player } from "./Player";

export type Tournament = {
  id: number;
  name: string;
  start_date: string;
  end_date: string;
  match_count: number;
  host_player: Player;
  staff?: Player[];
}
