import { Avatar, List, Table } from "antd";
import { ColumnProps } from "antd/lib/table";
import * as moment from "moment";
import * as React from "react";
import Api from "../../../api/Api";
import MatchRequests from "../../../api/requests/MatchRequests";
import { IMatch } from "../../../entities/IMatch";
import IMatchTeam from "../../../entities/IMatchTeam";
import IPlayer from "../../../entities/IPlayer";

import "./MatchListTable.scss";
import { GeneralEvents } from "../../../events/GeneralEvents";

export interface IMatchListTableProps {
  tournamentId?: number;
  hiddenColumns?: string[];
  isFocused?: boolean;
  initialData?: IMatch[];
}

function sortTimestamp(a: IMatch, b: IMatch) {
  if (moment(a.match_timestamp) > moment(b.match_timestamp)) return 1;
  if (moment(a.match_timestamp) < moment(b.match_timestamp)) return -1;
  return 0;
}

export default function MatchListTable({
  tournamentId,
  hiddenColumns = [],
  initialData = [],
  isFocused = true,
}: IMatchListTableProps) {
  const [isLoading, setIsLoading] = React.useState(true);
  const [data, setData] = React.useState(initialData);

  const isFirstLoad = React.useRef(true);

  const loadData = async () => {
    // If we had initial data and this is still the first load attempt, then skip
    // the API trip
    if (initialData.length > 0 && isFirstLoad.current) {
      setIsLoading(false);
      isFirstLoad.current = false;
      return;
    }

    setIsLoading(true);

    try {
      const request = MatchRequests.getMatches({ tournament_id: tournamentId });
      const response = await Api.performRequest<IMatch[]>(request);

      setData(response);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  const onMatchesChanged = React.useCallback(() => {
    if (isFocused) loadData();
  }, []);

  React.useEffect(() => {
    $(document).on(GeneralEvents.MatchCreated, onMatchesChanged);
    $(document).on(GeneralEvents.MatchDeleted, onMatchesChanged);

    return () => {
      $(document).off(GeneralEvents.MatchCreated, onMatchesChanged);
      $(document).off(GeneralEvents.MatchDeleted, onMatchesChanged);
    };
  });

  React.useEffect(() => {
    if (isFocused) loadData();
  }, [isFocused]);

  const renderTeam = (team: IMatchTeam, isWinner: boolean, showTeamNames: boolean = false) => (
    <List
      header={showTeamNames ? <b>{team.name || `Team ${team.captain.name}`}</b> : null}
      dataSource={team.players}
      renderItem={renderTeamPlayerItem}
      className={isWinner ? "team-list--winner" : "team-list"}
    />
  );

  const renderTeamPlayerItem = (player: IPlayer) => (
    <List.Item>
      <List.Item.Meta
        avatar={<Avatar src={`https://a.ppy.sh/${player.osu_id}`} />}
        title={<a href={`https://osu.ppy.sh/users/${player.osu_id}`} target="_blank">{player.name}</a>}
      />
    </List.Item>
  );

  const keyExtractor = (record: IMatch): string => record.id.toString();

  const columns: ColumnProps<IMatch>[] = [
    {
      dataIndex: "round_name",
      key: "1",
      render: (text, record) => (
        <a href={`/matches/${record.id}`}>
          {text}
        </a>
      ),
      title: tournamentId ? "Round" : "Name",
    }, {
      className: "team-cell",
      dataIndex: "red_team",
      key: "3",
      render: (text, record) => renderTeam(
        record.red_team,
        record.winning_team.id === record.red_team.id,
        record.red_team.players.length > 1 || record.blue_team.players.length > 1,
      ),
      title: "Red Player",
    }, {
      className: "team-cell",
      dataIndex: "blue_team",
      key: "2",
      render: (text, record) => renderTeam(
        record.blue_team,
        record.winning_team.id === record.blue_team.id,
        record.red_team.players.length > 1 || record.blue_team.players.length > 1,
      ),
      title: "Blue Team",
    }, {
      dataIndex: "match_timestamp",
      defaultSortOrder: "ascend",
      key: "4",
      render: text => moment(text).format("LLL"),
      sortDirections: ["ascend", "descend"],
      sorter: sortTimestamp,
      title: "Date",
    },
  ];

  return (
    <div className="match-list-table">
      <Table
        dataSource={data}
        loading={isLoading}
        columns={columns.filter(c => !hiddenColumns.includes(c.dataIndex as string))}
        rowKey={keyExtractor}
        pagination={{
          pageSize: 10,
          position: "top",
        }}
      />
    </div>
  );
}
