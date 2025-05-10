import { DiscordExp, DiscordServer } from "./Discord";

export enum IdentityProvider {
  Osu = "osu",
  Discord = "discord",
}

export enum BanStatus {
  NoBan,
  Soft,
  Hard,
}

export enum PreferredColourScheme {
  System,
  Light,
  Dark,
}

export type Identity = {
  provider: IdentityProvider;
  auth_provider: { display_name: string };
  raw: any;
  uid: number;
  uname: string;
  created_at: string;
}

export type UiConfig = {
  preferred_colour_scheme?: PreferredColourScheme,
}

export type Player = {
  id: number;
  name: string;
  avatar_url?: string;
  ban_status: BanStatus;
  identities: Identity[];
  created_at: string;
  discord_exp?: DiscordExp[];
  ui_config: UiConfig;
}
