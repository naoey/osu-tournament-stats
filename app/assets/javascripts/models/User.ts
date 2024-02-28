import { DiscordServer } from "./Discord";
import Api from "../api/Api";
import { deleteIdentity } from "../api/requests/UserRequests";

export enum IdentityProvider {
  Osu = 'osu',
  Discord = 'discord',
}

type IdentityAssociation = {
  name: IdentityProvider;
  display_name: string;
  enabled: boolean;
};

type DiscordServerExp = {
  level: number;
  exp: number;
  detailed_exp: [number, number, number];
  discord_server: DiscordServer;
}

export enum BanStatus {
  None,
  Soft,
  Hard,
}

export class Identity {
  provider!: IdentityProvider;
  raw: any;
  uid!: number;
  uname!: string;
  created_at!: string;
  auth_provider!: IdentityAssociation;
}

export class User {
  id!: number;
  name!: string;
  avatar_url?: string;
  ban_status!: BanStatus;
  identities!: Identity[];
  created_at!: string;
  discord_exp?: DiscordServerExp[];

  async deleteIdentity(id: Identity) {
    await Api.performRequest(deleteIdentity({ provider: id.provider }))
  }
}
