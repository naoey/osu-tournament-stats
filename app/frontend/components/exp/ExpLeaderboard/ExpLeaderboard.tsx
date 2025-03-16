import React, { useEffect, useState, useMemo } from "react";
import { Table, TablePaginationConfig, message, List, Avatar, Spin } from "antd";
import DiscordRequests from "../../../api/requests/DiscordRequests";
import Api from "../../../api/Api";
import moment from "moment";
import { Player } from "../../../models/Player";
import { DiscordExp } from "../../../models/Discord";

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
      setData(d => [...d, ...response.map(e => new DiscordExp(e))]);
    } catch (e) {
      message.error("An error occurred!");
    }

    setLoading(false);
  };

  useEffect(() => {
    fetchRecords();
  }, []);

  const formattedData = useMemo(() => {
    return data.map(d => ({ ...data, player: new Player(d.player) }));
  }, [data]);

  useEffect(() => {
    const onPageEndReached = () => {
      fetchRecords(page + 1);
    };

    document.addEventListener("ots.page_end_reached", onPageEndReached);

    return () => {
      document.removeEventListener("ots.page_end_reached", onPageEndReached);
    };
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
                className="item"
                avatar={<Avatar src={`https://a.ppy.sh/${record.player.osuId}`}/>}
                title={
                  record.player.osuId
                    ? (
                      <a href={`https://osu.ppy.sh/users/${record.player.osuId}`} target="_blank">
                        {record.player.name || record.player.discordId}
                      </a>
                    )
                    : record.player.name || record.player.discord_id
                }
                description={record.level >= 100 ? "Spam God" : ""}
              />
            </List.Item>
          )}
        />
        <Table.Column title="Level" dataIndex="level" key="level"/>
        <Table.Column title="XP" dataIndex="exp" key="exp" render={text => text.toLocaleString()}/>
        <Table.Column title="Messages" dataIndex="message_count" key="message_count" render={text => text.toLocaleString()}/>
        <Table.Column
          title="Last Updated"
          dataIndex="updated_at"
          key="updated"
          render={text => {
            const t = moment(text);

            if (t.unix() <= 0) {
              // Unix epoch (date) set for this record meaning it has never been updated within KelaBot
              return "Never";
            }

            return t.calendar();
          }}
        />
      </Table>

      <div className="spin-wrap">
        {isLoading ? <Spin size="large"/> : null}
      </div>
    </div>
  );
}
