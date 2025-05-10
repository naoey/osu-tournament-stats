import React, { useEffect, useState } from "react";
import { Identity, IdentityProvider, Player } from "../../../models/Player";
import { Avatar, Button, Divider, Flex, message, Select } from "antd";
import moment from "moment";
import { DeleteOutlined, DiscordOutlined } from "@ant-design/icons";
import AppearanceSection from "./AppearanceSection";
import usePlayer from "../../../hooks/usePlayer";
import LoadingTracker, { useLoadingTracker } from "../../common/LoadingTracker";
import PageRoot from "../../common/PageRoot";
import CsrfHelper from "../../../helpers/CsrfHelper";

export default PageRoot(function EditProfile() {
  const { player, toLoginPage, deleteIdentity: apiDeleteIdentity } = usePlayer();
  const [editingPlayer, setEditingPlayer] = useState<Player>(player);
  const loadingTracker = useLoadingTracker();

  useEffect(() => {
    if (!player) toLoginPage();
  }, [player]);

  if (!player) return null;

  const deleteIdentity = async (id: Identity) => {
    const loadingKey = `deleteIdentity_${id.provider}`;

    try {
      const identities = await apiDeleteIdentity(id);
      loadingTracker.addLoadingKey(loadingKey);
      setEditingPlayer(p => ({ ...p, identities }));
      message.success("Removed Discord connection");
    } catch (e) {
      console.error(e);
      message.error("Something went wrong!");
    } finally {
      loadingTracker.removeLoadingKey(loadingKey);
    }
  };

  const renderLinkedAccounts = () => editingPlayer.identities.map(id => (
    <Flex align="center" gap="middle" key={id.provider}>
      <p>
        <b>{id.auth_provider.display_name}</b>: {id.uname} [{id.uid}]
        <br />
        <small><i>Connected on {moment(id.created_at).toLocaleString()}</i></small>
      </p>

      <Button
        onClick={() => deleteIdentity(id)}
        type="primary" danger icon={<DeleteOutlined />}
        disabled={id.provider === IdentityProvider.Osu || loadingTracker.isKeyLoading(`deleteIdentity_${id.provider}`)}
        loading={loadingTracker.isKeyLoading(`deleteIdentity_${id.provider}`)}
      />
    </Flex>
  ));

  const renderAdditionalAccountOptions = () => {
    const options = [];

    if (!editingPlayer.identities.some(i => i.provider === IdentityProvider.Discord)) {
      options.push(
        <form method="post" action="/auth/discord">
          <input type="hidden" name="authenticity_token" value={CsrfHelper.getCsrfToken()} />
          <Button
            icon={<DiscordOutlined />}
            type="primary"
            style={{ backgroundColor: '#5865F2' }}
            htmlType="submit"
            shape="circle"
            value="submit"
            data-turbo="false"
          />
        </form>,
      );
    }

    if (!editingPlayer.identities.some(i => i.provider === IdentityProvider.Osu)) {
      options.push(
        <>
          <p>To link your osu! account, join the <a href="/discord">osu!india Discord server</a> first.</p>
        </>,
      )
      // options.push(
      //   <form method="post" action="/auth/osu">
      //     <input type="hidden" name="authenticity_token" value={$('meta[name="csrf-token"]').attr('content')} />
      //     <Button
      //       icon={<DiscordOutlined />}
      //       type="primary"
      //       style={{ backgroundColor: '#5865F2' }}
      //       htmlType="submit"
      //       shape="circle"
      //       value="submit"
      //       data-turbo="false"
      //     />
      //   </form>,
      // );
    }

    if (options.length === 0) return null;

    return (
      <Flex align="center" gap="small">
        <strong>Add other accounts:</strong>{options}
      </Flex>
    );
  };

  return (
    <>
      <Flex align="center" gap="large">
        <Avatar src={editingPlayer.avatar_url} size={75} />
        <h1>{editingPlayer.name}</h1>
      </Flex>

      <Divider />

      <h2>Basic</h2>

      <p>
        <b>Registered: </b> {moment(editingPlayer.created_at).toLocaleString()}
      </p>

      <Divider />

      <AppearanceSection />

      <Divider />

      <h2>Linked Accounts</h2>

      {renderLinkedAccounts()}
      {renderAdditionalAccountOptions()}
    </>
  );
})
