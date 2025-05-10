import React from "react";
import { Content } from "antd/es/layout/layout";
import PageRoot from "../common/PageRoot";

enum FailureCode {
  OnlyOsuAllowed,
  AltDiscord,
}

type OauthFailedProps = {
  service: string;
  code?: FailureCode;
};

export default PageRoot(function OAuthFailure({ service, code }: OauthFailedProps) {
  console.log('code', code, FailureCode.OnlyOsuAllowed);
  const getMessage = () => {
    switch (code) {
      case FailureCode.OnlyOsuAllowed:
        return (
          <p>
            Looks like this Discord user is not linked to an account yet! Registration is only allowed with
            osu! accounts, so complete sign up with the "Sign in with osu!" option on the login page, and
            then link your Discord ID from the profile page.

            You can then login with either your osu! or Discord accounts from next time!
          </p>
        );

      case FailureCode.AltDiscord:
        return (
          <p>
            Your osu! account is already linked to another Discord account. Multiple Discord accounts are not allowed.

            Contact the server admins if you have a valid reason for using a different Discord account.
          </p>
        )

      default:
        return <p>Something broke when trying to log you in with your {service} account.</p>;
    }
  };

  return (
    <Content>
      <h1>failed!</h1>

      {getMessage()}
      <p>Click <a href="/login">here</a> to go back to the login page.</p>
    </Content>
  );
})
