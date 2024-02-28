import { DiscordServer } from "./Discord";
import Api from "../api/Api";
import { deleteIdentity } from "../api/requests/UserRequests";
import { Model } from "./Model";

export enum IdentityProvider {
  Osu = 'osu',
  Discord = 'discord',
}

class IdentityAssociation extends Model {
  name!: IdentityProvider;
  display_name!: string;
  enabled!: boolean;
}

class DiscordServerExp extends Model {
  level!: number;
  exp!: number;
  detailed_exp!: [number, number, number];
  discord_server!: DiscordServer;
}

export enum BanStatus {
  None,
  Soft,
  Hard,
}

export class Identity extends Model {
  provider!: IdentityProvider;
  raw: any;
  uid!: number;
  uname!: string;
  created_at!: string;
  auth_provider!: IdentityAssociation;
}

export class User extends Model {
  id!: number;
  name!: string;
  avatar_url?: string;
  ban_status!: BanStatus;
  identities!: Identity[];
  created_at!: string;
  discord_exp?: DiscordServerExp[];

  async deleteIdentity(id: Identity): Promise<User> {
    this.identities = await Api.performRequest<Identity[]>(deleteIdentity({ provider: id.provider }))
    return this;
  }
}
