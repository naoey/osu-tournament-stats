import * as React from 'react';
import { Menu } from 'antd';

export default class NavigationBar extends React.Component {
  public render() {
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

        {
          // TODO: replace with proper global types
          (window as any)._currentUser
            ? (
              <Menu.Item key="logout">
                <a href="#" onClick={this.onLogout}>Logout</a>
              </Menu.Item>
            )
            : (
              <Menu.Item key="login">
                <a href="/login">Login</a>
              </Menu.Item>
            )
        }
      </Menu>
    );
  }

  private async onLogout() {
    try {
      await fetch("/logout", {
        credentials: "same-origin",
        method: "DELETE",
      })

      window.location.reload();
    } catch (e) {
      console.error(e);
    }
  }
}
