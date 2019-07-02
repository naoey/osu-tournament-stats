import { Table } from "antd";
import { ColumnProps } from 'antd/lib/table';
import * as _ from "lodash";
import * as moment from "moment";
import * as React from "react";
import { IMatch } from "../../entities/IMatch";
import IPlayer from "../../entities/IPlayer";

export interface IMatchListTableProps {
  data: IMatch[];
}

export default class MatchListTable extends React.Component<IMatchListTableProps, {}> {
  public static createRoundNameFilters() {
    return [{
      text: "Qualifiers",
      value: "qualifiers",
    }, {
      text: "Groups",
      value: "group",
    }, {
      text: "Main Event",
      value: "main",
    }, {
      text: "Main Event - Upper Bracket",
      value: "main_upper",
    }, {
      text: "Main Event - Lower Bracket",
      value: "main_lower",
    }, {
      text: "Semifinals",
      value: "semis",
    }, {
      text: "Finals",
      value: "finals",
    }];
  }

  public static createPlayerNameFilter(players: IPlayer[]) {
    return _.sortBy(
      _.uniqBy(players.map(p => ({ text: p.name, value: p.name.toLowerCase() })), i => i.text),
      p => p.value,
    );
  }

  public static onFilterRoundName(value: string, record: IMatch): boolean {
    return record.name.toLowerCase().indexOf(value) > -1;
  }

  public static onFilterPlayerName(team: "red" | "blue", value: string, record: IMatch): boolean {
    if (team === "red") { return (record.red_team as IPlayer).name.toLowerCase().indexOf(value) > -1; }
    if (team === "blue") { return (record.blue_team as IPlayer).name.toLowerCase().indexOf(value) > -1; }

    return false;
  }

  public static sortTimestamp(a: IMatch, b: IMatch) {
    if (moment(a.timestamp) > moment(b.timestamp)) { return 1; }
    if (moment(a.timestamp) < moment(b.timestamp)) { return -1; }
    return 0;
  }

  public render() {
    const { data } = this.props;

    const columns: Array<ColumnProps<IMatch>> = [
      {
        dataIndex: "name",
        filters: MatchListTable.createRoundNameFilters(),
        key: "1",
        onFilter: MatchListTable.onFilterRoundName,
        render: (text, record) => (
          <a href={`https://osu.ppy.sh/mp/${record.online_id}`} target="_blank">
            {text} <i className="fas fa-external-link-alt" />
          </a>
        ),
        title: "Round",
      }, {
        dataIndex: "blue_team",
        filters: MatchListTable.createPlayerNameFilter(data.map(d => (d.blue_team as IPlayer))),
        key: "2",
        onFilter: (value, record) => MatchListTable.onFilterPlayerName("blue", value, record),
        render: (text, record) => (
          <span style={text.id === record.winning_team ? { fontWeight: "bold", color: "green" } : {}}>
            {text.name}
          </span>
        ),
        title: "Blue Player",
      }, {
        dataIndex: "red_team",
        filters: MatchListTable.createPlayerNameFilter(data.map(d => (d.red_team as IPlayer))),
        key: "3",
        onFilter: (value, record) => MatchListTable.onFilterPlayerName("red", value, record),
        render: (text, record) => (
          <span style={text.id === record.winning_team ? { fontWeight: "bold", color: "green" } : {}}>
            {text.name}
          </span>
        ),
        title: "Red Player",
      }, {
        dataIndex: "timestamp",
        defaultSortOrder: "ascend",
        key: "4",
        render: text => moment(text).format("LLL"),
        sortDirections: ["ascend", "descend"],
        sorter: MatchListTable.sortTimestamp,
        title: "Date",
      },
    ];

    return (
      <div>
        <Table
          dataSource={data}
          columns={columns}
          rowKey={this.keyExtrator}
          pagination={{
            pageSize: 10,
            position: "top",
          }}
        />
      </div>
    );
  }

  private keyExtrator = (record: IMatch): string => record.id.toString();
}
