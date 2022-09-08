import IPlayer from "./IPlayer";

export default interface IMatchTeam {
  name?: string;
  players: IPlayer[];
  captain: IPlayer;
  id: number;
}
