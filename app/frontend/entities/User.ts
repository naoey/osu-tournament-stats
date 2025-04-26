import { Player } from "./Player";

export enum UserPrivilege {
  Owner,
  Manager,
  Guest,
}

export type User = Player & {
  last_login: string;
  email: string;
  privilege: UserPrivilege;
};
