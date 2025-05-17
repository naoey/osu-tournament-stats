import usePlayer from "../../hooks/usePlayer";
import React, { useEffect, useMemo, useRef, useState } from "react";
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
    const { player } = usePlayer();
    const colourSchemeMediaQueryRef = useRef(window.matchMedia("(prefers-color-scheme: dark)"));
    const [activeTheme, setActiveTheme] = useState<PreferredColourScheme>(
      player?.ui_config.preferred_colour_scheme ?? PreferredColourScheme.System,
    );

    useEffect(() => {
      const onSettingsUpdated = (config: UiConfig) => {
        setActiveTheme(config.preferred_colour_scheme!);
      };

      const onMediaQueryChanged = (e: MediaQueryListEvent) => {
        setActiveTheme(e.matches ? PreferredColourScheme.Dark : PreferredColourScheme.Light);
      };

      NotificationHelper.subscribe(UserEvents.SettingsUpdated, onSettingsUpdated);

      colourSchemeMediaQueryRef.current.addEventListener('change', onMediaQueryChanged);

      return () => {
        NotificationHelper.unsubscribe(UserEvents.SettingsUpdated, onSettingsUpdated);

        colourSchemeMediaQueryRef.current.removeEventListener('change', onMediaQueryChanged);
      };
    }, []);

    const antdThemeAlgorithm = useMemo(() => {
      switch (activeTheme) {
        case PreferredColourScheme.Light:
          return antdTheme.defaultAlgorithm;

        case PreferredColourScheme.Dark:
          return antdTheme.darkAlgorithm;

        default:
        case PreferredColourScheme.System:
          return colourSchemeMediaQueryRef.current.matches
            ? antdTheme.darkAlgorithm
            : antdTheme.defaultAlgorithm;
      }
    }, [activeTheme]);

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
