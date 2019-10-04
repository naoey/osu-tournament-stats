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

export interface IMatchListTableProps {
  tournamentId?: number;
}

interface IMatchListTableState {
  data: IMatch[];
  isLoading: boolean;
}

export default class MatchListTable extends React.Component<IMatchListTableProps, IMatchListTableState> {
  public static sortTimestamp(a: IMatch, b: IMatch) {
    if (moment(a.match_timestamp) > moment(b.match_timestamp)) return 1;
    if (moment(a.match_timestamp) < moment(b.match_timestamp)) return -1;
    return 0;
  }

  public state = {
    data: [],
    isLoading: true,
  };

  public async componentDidMount() {
    const { tournamentId } = this.props;

    if (!tournamentId) {
      this.setState({ isLoading: false, data: [] });
      return;
    }

    try {
      const request = MatchRequests.getMatches({ tournament_id: tournamentId });
      const response = await Api.performRequest<IMatch[]>(request);

      this.setState({ data: response });
    } catch (e) {
      console.error(e);
    } finally {
      this.setState({ isLoading: false });
    }
  }

  public render() {
    const { data, isLoading } = this.state;

    const columns: Array<ColumnProps<IMatch>> = [
      {
        dataIndex: "round_name",
        key: "1",
        render: (text, record) => (
          <a href={`https://osu.ppy.sh/mp/${record.online_id}`} target="_blank">
            {text} <i className="fas fa-external-link-alt" />
          </a>
        ),
        title: "Round",
      }, {
        className: "team-cell",
        dataIndex: "red_team",
        key: "3",
        render: (text, record) => this.renderTeam(
          record.red_team,
          record.winning_team.id === record.red_team.id,
          record.red_team.players.length > 1 || record.blue_team.players.length > 1,
        ),
        title: "Red Player",
      }, {
        className: "team-cell",
        dataIndex: "blue_team",
        key: "2",
        render: (text, record) => this.renderTeam(
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
        sorter: MatchListTable.sortTimestamp,
        title: "Date",
      },
    ];

    return (
      <div className="match-list-table">
        <Table
          dataSource={data}
          loading={isLoading}
          columns={columns}
          rowKey={this.keyExtractor}
          pagination={{
            pageSize: 10,
            position: "top",
          }}
        />
      </div>
    );
  }

  private renderTeam = (team: IMatchTeam, isWinner: boolean, showTeamNames: boolean = false) => (
    <List
      header={showTeamNames ? <b>{team.name || `Team ${team.captain.name}`}</b> : null}
      dataSource={team.players}
      renderItem={this.renderTeamPlayerItem}
      className={isWinner ? "team-list--winner" : "team-list"}
    />
  )

  private renderTeamPlayerItem = (player: IPlayer) => (
    <List.Item>
      <List.Item.Meta
        avatar={<Avatar src={`https://a.ppy.sh/${player.osu_id}`} />}
        title={<a href={`https://osu.ppy.sh/users/${player.osu_id}`} target="_blank">{player.name}</a>}
      />
    </List.Item>
  )

  private keyExtractor = (record: IMatch): string => record.id.toString();
}
