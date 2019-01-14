import * as React from 'react';
import { Menu } from 'antd';

export default class NavigationBar extends React.Component {
  render() {
    return (
      <Menu
        mode="horizontal"
        selectedKeys={[window.location.pathname.split('/')[2]]}
        theme="dark"
      >
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
