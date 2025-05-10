import usePlayer from "../../../hooks/usePlayer";
import React from "react";
import { Select, message } from "antd";
import { PreferredColourScheme } from "../../../models/Player";
import { useLoadingTracker } from "../../common/LoadingTracker";
import EnumHelper from "../../../helpers/EnumHelper";
import { UserEvents } from "../../../events/UserEvents";
import NotificationHelper from "../../../helpers/NotificationHelper";

const loading_key = 'preferredColourScheme';

export default function AppearanceSection() {
  const { player, updateUiConfig } = usePlayer();
  const [toast] = message.useMessage();
  const loadingTracker = useLoadingTracker();

  if (!player) return null;

  const handleColourSchemeChange = async (scheme: PreferredColourScheme) => {
    try {
      loadingTracker.addLoadingKey(loading_key);
      const newConfig = { ...player.ui_config, preferred_colour_scheme: scheme };
      await updateUiConfig(newConfig);
      NotificationHelper.dispatch(UserEvents.SettingsUpdated, newConfig);
    } catch (e) {
      console.error("Failed to update colour scheme", e);
      message.open({ type: "error", content: "Something went wrong!" });
    } finally {
      loadingTracker.removeLoadingKey(loading_key);
    }
  };

  return (
    <>
      <h2>Appearance</h2>

      <div>
        <b>Colour Scheme: </b>
        <Select
          style={{ width: 120 }}
          value={player.ui_config.preferred_colour_scheme}
          options={EnumHelper.getReadablePairs(PreferredColourScheme).map(([label, value]) => ({ label, value }))}
          onChange={handleColourSchemeChange}
          loading={loadingTracker.isKeyLoading(loading_key)}
          disabled={loadingTracker.isKeyLoading(loading_key)}
        />
      </div>
    </>
  )
}
