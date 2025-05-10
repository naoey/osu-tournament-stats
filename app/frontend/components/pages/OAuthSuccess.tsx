import React from "react";
import { Content } from "antd/es/layout/layout";
import PageRoot from "../common/PageRoot";

enum AuthFlowCode {
  DiscordBotRegistration,
  DirectRegistration,
  ExistingUserLogin,
  DiscordAdditionalAccount,
};

type OsuLoginSuccessProps = {
  code: AuthFlowCode;
}

export default PageRoot(function OAuthSuccess({ code }: OsuLoginSuccessProps) {
  const getMessage = () => {
    switch (code) {
      case AuthFlowCode.DirectRegistration:
        return <p>Registration completed! Join the osu!india <a href="/discord">Discord server</a>.</p>;

      case AuthFlowCode.DiscordBotRegistration:
        return <p>Registration completed! You should now have access to the Discord server. Contact the admins in case you still can't access any channels.</p>;

      case AuthFlowCode.ExistingUserLogin:
        return <p>Login complete!</p>

      case AuthFlowCode.DiscordAdditionalAccount:
        return <p>Discord account linkage completed!</p>

      default:
        return <p>You shouldn't be here.</p>
    }
  }

  return (
    <Content>
      <h1>success!</h1>

      {getMessage()}
    </Content>
  )
})
