import { Player } from "./Player";

export type DiscordServer = {
  id: number;
  discord_id: number;
  registration_channel_id: number;
  verified_role_id: number;
  created_at: string;
  updated_at: string;
  verification_log_channel_id: number;
  exp_enabled: boolean;
  exp_roles_config: Array<[number, number]>;
};

export type DiscordExp = {
  id: number;
  player_id: number;
  discord_server_id: number;
  exp: number;
  detailed_exp: [number, number, number];
  level: number;
  message_count: number;
  created_at: string;
  updated_at: string;
  player: Player;
};
