import React, { useState } from "react";
import { Identity, IdentityProvider, Player } from "../../models/Player";
import { Avatar, Button, Divider, Flex, message } from "antd";
import moment from "moment";
import { DeleteOutlined, DiscordOutlined } from "@ant-design/icons";

type EditProfileProps = {
  user: Player;
};

export default function EditProfile({ user }: EditProfileProps) {
  const [editingUser, setEditingUser] = useState<Player>(user);
  const [deleteIdLoadingKeys, setDeleteLoadingKeys] = useState<IdentityProvider[]>([]);

  const deleteIdentity = async (id: Identity) => {
    try {
      setDeleteLoadingKeys(k => [...k, id.provider]);
      setEditingUser(await editingUser.deleteIdentity(id));
      setDeleteLoadingKeys(k => k.filter(i => i !== id.provider));
      message.success("Removed Discord connection");
    } catch (e) {
      console.error(e);
      setDeleteLoadingKeys(k => k.filter(i => i !== id.provider));
      message.error("Something went wrong!");
    }
  };

  const renderLinkedAccounts = () => editingUser.identities.map(id => (
    <Flex align="center" gap="middle" key={id.provider}>
      <p>
        <b>{id.auth_provider.display_name}</b>: {id.uname} [{id.uid}]
        <br />
        <small><i>Connected on {moment(id.created_at).toLocaleString()}</i></small>
      </p>

      <Button
        onClick={() => deleteIdentity(id)}
        type="primary" danger icon={<DeleteOutlined />}
        disabled={id.provider === IdentityProvider.Osu || deleteIdLoadingKeys.includes(id.provider)}
        loading={deleteIdLoadingKeys.includes(id.provider)}
      />
    </Flex>
  ));

  const renderAdditionalAccountOptions = () => {
    const options = [];

    if (editingUser.identities.length < 2) {
      options.push(
        <form method="post" action="/auth/discord">
          <input type="hidden" name="authenticity_token" value={$('meta[name="csrf-token"]').attr('content')} />
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
    } else {
      return null;
    }

    return (
      <Flex align="center" gap="small">
        <strong>Add other accounts:</strong>{options}
      </Flex>
    );
  };

  return (
    <>
      <Flex align="center" gap="large">
        <Avatar src={editingUser.avatar_url} size={75} />
        <h1>{editingUser.name}</h1>
      </Flex>

      <Divider />

      <h2>Basic</h2>

      <p>
        <b>Registered: </b> {moment(editingUser.created_at).toLocaleString()}
      </p>

      <Divider />

      <h2>Linked Accounts</h2>

      {renderLinkedAccounts()}
      {renderAdditionalAccountOptions()}
    </>
  );
}
