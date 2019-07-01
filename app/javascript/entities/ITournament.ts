import IPlayer from "./IPlayer";

export default interface ITournament {
  id: number;
  name: string;
  start_date: string;
  end_date: string;
  match_count: number;
  host_player: IPlayer;
  staff?: IPlayer[];
}
