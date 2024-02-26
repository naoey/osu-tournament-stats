import React, { useState } from "react";
import { IdentityProvider, User } from "../../models/User";
import { Avatar, Button, Divider, Flex, Form } from "antd";
import moment from "moment";
import { DeleteOutlined } from "@ant-design/icons";

type EditProfileProps = {
  user: User;
};

export default function EditProfile({ user }: EditProfileProps) {
  const [editingUser, setEditingUser] = useState<User>(user);

  const renderLinkedAccounts = () => editingUser.identities.map(id => (
    <Flex align="center" gap="middle">
      <p>
        <b>{id.auth_provider.display_name}</b>: {id.uname} [{id.uid}]
        <br />
        <small><i>Connected on {moment(id.created_at).toLocaleString()}</i></small>
      </p>

      <Button type="primary" danger icon={<DeleteOutlined />} disabled={id.provider === IdentityProvider.Osu} />
    </Flex>
  ));

  const renderAdditionalAccountOptions = () => {
    const options = [];

    if (editingUser.identities.length < 2) {
      options.push(<a href="/profile/edit/add_discord">Connect Discord</a>);
    } else {
      return null;
    }

    return (
      <>
        <h4>Add Accounts</h4>
        {options}
      </>
    );
  }

  return (
    <>
      <Form method="PUT" action="/users/profile">
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
      </Form>
    </>
  )
}
