import * as React from 'react';
import * as moment from 'moment';
import { Table } from 'antd';

export interface MatchListPlayer {
  id: number;
  name: string;
}

export interface MatchListItem {
  round_name: string;
  online_id: number,
  blue_player: MatchListPlayer;
  red_player: MatchListPlayer;
  winner: number;
  timestamp: string;
}

export interface MatchListTableProps {
  data: Array<MatchListItem>;
}

export default class MatchListTable extends React.Component<MatchListTableProps, {}> {
  render() {
    const { data } = this.props;

    const columns = [{
      dataIndex: 'round_name',
      title: "Round",
    }, {
      dataIndex: 'blue_player',
      title: 'Blue Player',
      render: (text, record) => (
        <span style={text.id === record.winner ? { fontWeight: 'bold', color: 'green' } : {}}>
          {text.name}
        </span>)
    }, {
      dataIndex: 'red_player',
      title: 'Red Player',
      render: (text, record) => (
        <span style={text.id === record.winner ? { fontWeight: 'bold', color: 'green' } : {}}>
          {text.name}
        </span>)
    }, {
      dataIndex: 'timestamp',
      title: "Date",
      render: text => moment(text).format('LLL'),
    }];

    return (
      <Table
        dataSource={data}
        columns={columns}
        rowKey={record => record.id}
      />
    );
  }
}
