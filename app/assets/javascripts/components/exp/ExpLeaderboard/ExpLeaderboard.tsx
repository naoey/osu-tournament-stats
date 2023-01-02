import React, { useEffect, useState } from "react";
import { DiscordExp } from "../../../entities/DiscordExp";
import { Table, TablePaginationConfig, message, List, Avatar, Spin } from "antd";
import DiscordRequests from "../../../api/requests/DiscordRequests";
import Api from "../../../api/Api";
import moment from "moment";

import "./styles.scss";

export function ExpLeaderboard() {
  const [isLoading, setLoading] = useState(false);
  const [data, setData] = useState<DiscordExp[]>([]);
  const [page, setPage] = useState(1);

  const fetchRecords = async (p = page) => {
    if (isLoading) return;

    setLoading(true);

    try {
      const request = DiscordRequests.getExpLeaderboard({ serverId: 1, page: p });
      const response = await Api.performRequest<DiscordExp[]>(request);

      setPage(p);
      setData(d => [...d, ...response]);
    } catch (e) {
      message.error("An error occurred!");
    }

    setLoading(false);
  }

  useEffect(() => {
    fetchRecords();
  }, []);

  useEffect(() => {
    const onPageEndReached = () => {
      fetchRecords(page + 1);
    }

    document.addEventListener("ots.page_end_reached", onPageEndReached);

    return () => {
      document.removeEventListener("ots.page_end_reached", onPageEndReached);
    }
  }, [page]);

  return (
    <div className="leaderboard-wrapper">
      <Table dataSource={data} pagination={false} rowKey={r => r.id} sticky>
        <Table.Column
          width={60}
          render={(t, r, i) => i + 1}
          title="Rank"
          key="rank"
        />
        <Table.Column
          title="Username"
          dataIndex={["player", "name"]}
          key="player_name"
          width={200}
          render={(text: string, record: DiscordExp) => (
            <List.Item>
              <List.Item.Meta
                avatar={<Avatar src={`https://a.ppy.sh/${record.player.osu_id}`} />}
                title={
                  record.player.osu_id
                    ? (
                        <a href={`https://osu.ppy.sh/users/${record.player.osu_id}`} target="_blank">
                          {record.player.name || record.player.discord_id}
                        </a>
                    )
                    : record.player.name || record.player.discord_id
                }
              />
            </List.Item>
          )}
        />
        <Table.Column title="Level" dataIndex="level" key="level" />
        <Table.Column title="XP" dataIndex="exp" key="exp" render={text => text.toLocaleString()}/>
        <Table.Column title="Messages" dataIndex="message_count" key="message_count" render={text => text.toLocaleString()} />
        <Table.Column title="Last Updated" dataIndex="updated_at" key="updated" render={text => moment(text).calendar()} />
      </Table>

      <div className="spin-wrap">
        {isLoading ? <Spin size="large" /> : null}
      </div>
    </div>
  );
}
