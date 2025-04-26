import React from "react";
import { Button, Flex } from "antd";

type LinkOsuDiscordProps = {
  username: string;
  query: string;
}

export default function LinkOsuDiscord({ username, query }: LinkOsuDiscordProps) {
  return (
    <Flex align="center" justify="center" style={{ textAlign: 'center' }} vertical>
      <h1>Hello, {username}!</h1>

      <p>Welcome to the osu!india Discord server!</p>

      <p>
        To access the server, you need to login with your osu! ID so that the staff and other
        members will be able to recognise you. Click the link below to be redirected to the osu! website to authorise us to identify
        who you are on osu!
      </p>

      <form action="/auth/osu" method="post">
        <input type="hidden" name="authenticity_token" value={$('meta[name="csrf-token"]').attr('content')} />
        <input type="hidden" name="s" value={query} />
        <Button type="primary" htmlType="submit">Login with osu!</Button>
      </form>
    </Flex>
  )
}
