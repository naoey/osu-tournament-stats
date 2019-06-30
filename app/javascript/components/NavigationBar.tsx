import { Menu } from 'antd';
import * as React from 'react';

export default class NavigationBar extends React.Component {
  public render() {
    return (
      <Menu
        mode="horizontal"
        selectedKeys={[window.location.pathname.split("/").splice(1, 1)[0]]}
        theme="dark"
      >
        <Menu.Item key="tournaments">
          <a href="/tournaments">Tournaments</a>
        </Menu.Item>
        <Menu.Item key="matches">
          <a href="/statistics/matches">Matches</a>
        </Menu.Item>
        <Menu.Item key="players">
          <a href="/statistics/players">Players</a>
        </Menu.Item>
      </Menu>
    );
  }
}
