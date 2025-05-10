import usePlayer from "../../hooks/usePlayer";
import React, { useEffect, useMemo, useState } from "react";
import { UserEvents } from "../../events/UserEvents";
import { PreferredColourScheme, UiConfig } from "../../models/Player";
import { App, ConfigProvider, theme as antdTheme } from "antd";
import NotificationHelper from "../../helpers/NotificationHelper";
import LoadingTracker from "./LoadingTracker";

/**
 * Sets up the wrapped component in the context required for a page root component required for the page to
 * respond to user specific settings and global functionality.
 *
 * @param Component The component to wrap.
 */
export default function PageRoot(Component: React.ComponentType) {
  return function(props: React.ComponentProps<typeof Component>) {
    const { player, reload } = usePlayer();
    const [theme, setTheme] = useState<PreferredColourScheme>(player?.ui_config.preferred_colour_scheme ?? PreferredColourScheme.System);

    useEffect(() => {
      const onSettingsUpdated = (config: UiConfig) => {
        setTheme(config.preferred_colour_scheme!);
      };

      NotificationHelper.subscribe(UserEvents.SettingsUpdated, onSettingsUpdated);

      return () => {
        NotificationHelper.unsubscribe(UserEvents.SettingsUpdated, onSettingsUpdated);
      };
    }, []);

    const antdThemeAlgorithm = useMemo(() => {
      switch (theme) {
        case PreferredColourScheme.Light:
          return antdTheme.defaultAlgorithm;

        case PreferredColourScheme.Dark:
          return antdTheme.darkAlgorithm;

        default:
        case PreferredColourScheme.System:
          return window.matchMedia("(prefers-color-scheme: dark)").matches
            ? antdTheme.darkAlgorithm
            : antdTheme.defaultAlgorithm;
      }
    }, [theme]);

    useEffect(() => {
      // FIXME: hack hack hack
      document.body.style.color = antdThemeAlgorithm === antdTheme.defaultAlgorithm ? "#000" : "#FFF";
      document.body.style.backgroundColor = antdThemeAlgorithm === antdTheme.darkAlgorithm ? "#000" : "#FFF";
    }, [antdThemeAlgorithm]);

    return (
      <ConfigProvider
        theme={{ algorithm: antdThemeAlgorithm, cssVar: true }}
      >
        <App>
          <LoadingTracker>
            <Component {...props} />
          </LoadingTracker>
        </App>
      </ConfigProvider>
    );
  };
}
