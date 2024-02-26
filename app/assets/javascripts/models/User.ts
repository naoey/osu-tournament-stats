export enum IdentityProvider {
  Osu = 'osu',
  Discord = 'discord',
}

type IdentityAssociation = {
  name: IdentityProvider;
  display_name: string;
  enabled: boolean;
};

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
}
