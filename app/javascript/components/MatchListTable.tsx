import * as React from 'react';
import * as moment from 'moment';
import { Table } from 'antd';
import { ColumnProps } from 'antd/lib/table';
import _ from 'lodash';

export interface MatchListPlayer {
  id: number;
  name: string;
}

export interface MatchListItem {
  round_name: string;
  online_id: number;
  blue_player: MatchListPlayer;
  red_player: MatchListPlayer;
  winner: number;
  timestamp: string;
}

export interface MatchListTableProps {
  data: Array<MatchListItem>;
}

enum Team {
  'Red',
  'Blue',
}

export default class MatchListTable extends React.Component<MatchListTableProps, {}> {
  static createRoundNameFilters() {
    return [{
      text: 'Qualifiers',
      value: 'qualifiers',
    }, {
      text: 'Groups',
      value: 'groups',
    }, {
      text: 'Main Event',
      value: 'main',
    }, {
      text: 'Main Event - Upper Bracket',
      value: 'main_upper',
    }, {
      text: 'Main Event - Lower Bracket',
      value: 'main_lower',
    }, {
      text: 'Semifinals',
      value: 'semis',
    }, {
      text: 'Finals',
      value: 'finals',
    }];
  }

  static createPlayerNameFilter(players: Array<MatchListPlayer>) {
    return players.map(p => ({ text: p.name, value: p.name.toLowerCase() }));
  }

  static onFilterRoundName(value: string, record: MatchListItem): boolean {
    return record.round_name.toLowerCase().indexOf(value) > -1;
  }

  static onFilterPlayerName(team:Team, value:string, record:MatchListItem): boolean {
    if (team === Team.Red) return record.red_player.name.toLowerCase().indexOf(value) > -1;
    if (team === Team.Blue) return record.blue_player.name.toLowerCase().indexOf(value) > -1;

    return false;
  }

  static sortTimestamp(a:MatchListItem, b:MatchListItem, sortOrder:'ascend'|'descend') {
    if (sortOrder === 'ascend') {
      if (moment(a.timestamp) > moment(b.timestamp)) return 1;
      if (moment(a.timestamp) < moment(b.timestamp)) return -1;
      return 0;
    }

    if (sortOrder === 'descend') {
      if (moment(a.timestamp) > moment(b.timestamp)) return -1;
      if (moment(a.timestamp) < moment(b.timestamp)) return -1;
      return 0;
    }
  }

  render() {
    const { data } = this.props;

    const columns: ColumnProps<MatchListItem>[] = [
      {
        dataIndex: 'round_name',
        key: '1',
        title: "Round",
        render: (text, record) => (
          <a href={`https://osu.ppy.sh/mp/${record.online_id}`} target="_blank">
            {text} <i className="fas fa-external-link-alt" />
          </a>
        ),
        filters: MatchListTable.createRoundNameFilters(),
        onFilter: MatchListTable.onFilterRoundName,
        sortDirections: ['ascend', 'descend'],
      }, {
        key: '2',
        dataIndex: 'blue_player',
        title: 'Blue Player',
        render: (text, record) => (
          <span style={text.id === record.winner ? { fontWeight: 'bold', color: 'green' } : {}}>
            {text.name}
          </span>
        ),
        filters: MatchListTable.createPlayerNameFilter(data.map(d => d.blue_player)),
        onFilter: (value, record) => MatchListTable.onFilterPlayerName(Team.Blue, value, record),
        sortDirections: ['ascend', 'descend'],
      }, {
        key: '3',
        dataIndex: 'red_player',
        title: 'Red Player',
        render: (text, record) => (
          <span style={text.id === record.winner ? { fontWeight: 'bold', color: 'green' } : {}}>
            {text.name}
          </span>
        ),
        filters: MatchListTable.createPlayerNameFilter(data.map(d => d.red_player)),
        onFilter: (value, record) => MatchListTable.onFilterPlayerName(Team.Red, value, record),
        sortDirections: ['ascend', 'descend'],
      }, {
        key: '4',
        dataIndex: 'timestamp',
        title: "Date",
        render: text => moment(text).format('LLL'),
        defaultSortOrder: 'ascend',
        sorter: MatchListTable.sortTimestamp,
        sortDirections: ['ascend', 'descend'],
      }
    ];

    return (
      <div>
        <Table
          dataSource={data}
          columns={columns}
          rowKey={record => record.online_id.toString()}
        />
      </div>
    );
  }
}
