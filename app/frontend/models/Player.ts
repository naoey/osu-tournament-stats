import { DiscordExp, DiscordServer } from "./Discord";
import Api from "../api/Api";
import { deleteIdentity } from "../api/requests/UserRequests";

export enum IdentityProvider {
  Osu = "osu",
  Discord = "discord",
}

export enum BanStatus {
  NoBan,
  Soft,
  Hard,
}

type Identity = {
  provider: IdentityProvider;
  raw: any;
  uid: number;
  uname: string;
  created_at: string;
}

export class Player {
  id: number;
  name: string;
  avatar_url?: string;
  ban_status: BanStatus;
  identities: Identity[];
  created_at: string;
  discord_exp?: DiscordExp[];

  constructor(data: Player) {
    this.id = data.id;
    this.name = data.name;
    this.avatar_url = data.avatar_url;
    this.ban_status = data.ban_status;
    this.identities = data.identities;
    this.created_at = data.created_at;
  }

  async deleteIdentity(id: Identity): Promise<Player> {
    this.identities = await Api.performRequest<Identity[]>(deleteIdentity({ provider: id.provider }));
    return this;
  }

  get osuId(): number | undefined {
    return this.identities.find(i => i.provider === IdentityProvider.Osu)?.uid;
  }

  get discordId(): number | undefined {
    return this.identities.find(i => i.provider === IdentityProvider.Discord)?.uid;
  }
}
