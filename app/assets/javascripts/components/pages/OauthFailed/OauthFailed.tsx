import React from 'react';
import { Content } from "antd/es/layout/layout";

export default function OauthFailed() {
  return (
    <Content>
      <h1>login failed!</h1>

      <p>Something broke when trying to log you in with your osu! account.</p>
      <p>Click <a href="/login">here</a> to go back to the login page.</p>
    </Content>
  );
}
