import { IdentityProvider, Player } from "./Player";

export class DiscordServer {
  id!: number;
}

export class DiscordExp {
  id: number;
  player_id: number;
  discord_server_id: number;
  exp: number;
  detailed_exp: [number, number, number];
  level: number;
  message_count: number;
  created_at: string;
  updated_at: string;
  player: Player & { osuId?: string, discordId?: string };

  constructor(data: DiscordExp) {
    this.id = data.id;
    this.player_id = data.player_id;
    this.discord_server_id = data.discord_server_id;
    this.exp = data.exp;
    this.detailed_exp = data.detailed_exp;
    this.level = data.level;
    this.message_count = data.message_count;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
    this.player = data.player;

    this.player.osuId = this.player.identities.find(p => p.provider === IdentityProvider.Osu)?.uid.toString();
    this.player.discordId = this.player.identities.find(p => p.provider === IdentityProvider.Discord)?.uid.toString();
  }
}
