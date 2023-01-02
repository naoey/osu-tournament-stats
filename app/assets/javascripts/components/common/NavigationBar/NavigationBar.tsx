import { Menu } from "antd";
import * as React from "react";

import './styles.scss';

export function NavigationBar() {
  return (
    <Menu
      className="ot-navbar"
      mode="horizontal"
      selectedKeys={[window.location.pathname.split("/").splice(1, 1)[0]]}
      theme="dark"
    >
      <Menu.Item key="tournaments">
        <a href="/tournaments">Tournaments</a>
      </Menu.Item>
      <Menu.Item key="matches">
        <a href="/matches">Matches</a>
      </Menu.Item>
      <Menu.Item key="discord">
        <a href="/discord/servers/1/exp">osu!india discord exp</a>
      </Menu.Item>

      <Menu.Item key="authentication" style={{ float: "right" }}>
        {
          // TODO: replace with proper global types
          (window as any).currentUser
            ? <a rel="nofollow" data-method="delete" href="/logout">Logout</a>
            : <a rel="nofollow" href="/login">Login</a>
        }
      </Menu.Item>
    </Menu>
  );
}

