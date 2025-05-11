import { useState } from "react";
import { Identity, IdentityProvider, Player, UiConfig } from "../models/Player";
import Api from "../api/Api";
import * as UserRequests from "../api/requests/UserRequests";

export default function usePlayer() {
  const [player, setPlayer] = useState(window.currentUser ?? null);

  const toLoginPage = () => {
    window.location.href = "/login";
  };

  const updateUiConfig = async (config: UiConfig): Promise<UiConfig> => {
    const response = await Api.performRequest<UiConfig>(UserRequests.updateUiConfig({ config }));
    setPlayer({ ...player, ui_config: response });

    return response;
  };

  const deleteIdentity = async (id: Identity): Promise<Identity[]> => {
    const identities = await Api.performRequest<Identity[]>(UserRequests.deleteIdentity({ provider: id.provider }));
    setPlayer({ ...player, identities });
    return identities;
  };

  const reload = async () => {
    // const response = await Api.performRequest<Player>(UserRequests.
    // get("me"));
    // setPlayer(response);
  };

  return {
    isAuthenticated: !!player,
    player,
    updateUiConfig,
    deleteIdentity,
    toLoginPage,
    reload,

    get osuId(): number | undefined {
      return player?.identities.find(i => i.provider === IdentityProvider.Osu)?.uid;
    },

    get discordId(): number | undefined {
      return player?.identities.find(i => i.provider === IdentityProvider.Discord)?.uid;
    },
  };
}
