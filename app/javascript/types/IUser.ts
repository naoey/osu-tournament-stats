import IPlayer from "./IPlayer";

export enum UserPrivilege {
  Owner,
  Manager,
  Guest,
}

export interface IUser extends IPlayer {
  last_login: string;
  email: string;
  privilege: UserPrivilege;
}
