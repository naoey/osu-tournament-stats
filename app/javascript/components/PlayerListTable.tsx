import * as React from 'react';
import { Table } from 'antd';

export interface PlayerListItem {
  name: string;
  online_id: number,
  matches_played: number;
  matches_won: number;
  maps_played: number;
  maps_won: number,
  total_score: number;
  average_score: number,
  accuracy: number;
  perfect_count: number,
  average_misses: number;
  total_misses: number,
}

export interface PlayerListTableProps {
  data: Array<PlayerListItem>;
}

export default class PlayerListTable extends React.Component<PlayerListTableProps> {
  render() {
    const { data } = this.props;

    const columns = [
      {
        dataIndex: 'name',
        title: 'Name',
        render: (text, record) => <a target="_blank" href={`https://osu.ppy.sh/users/${record.online_id}`}>{text} <i className="fas fa-external-link-alt" /></a>,
      }, {
        dataIndex: 'matches_played',
        title: 'Matches played',
      }, {
        dataIndex: 'matches_won',
        title: 'Matches won',
      }, {
        dataIndex: 'matches_won',
        title: 'Match win %',
        render: (text, record) => <span>{record.matches_won / record.matches_played * 100}%</span>,
      }, {
        dataIndex: 'maps_played',
        title: 'Maps played',
      }, {
        dataIndex: 'maps_won',
        title: 'Maps won',
      }, {
        dataIndex: 'maps_won',
        title: 'Maps win %',
        render: (text, record) => <span>{Math.round(record.maps_won / record.maps_played * 100 * 100) / 100}%</span>,
      }, {
        dataIndex: 'best_accuracy',
        title: 'Best accuracy',
        render: (text, record) => <span>{record.best_accuracy}%</span>,
      }, {
        dataIndex: 'average_accuracy',
        title: 'Average accuracy',
        render: (text, record) => <span>{record.average_accuracy}%</span>,
      }, {
        dataIndex: 'perfect_count',
        title: 'Perfect maps',
      }, {
        dataIndex: 'total_misses',
        title: 'Total misses',
      }, {
        dataIndex: 'average_misses',
        title: 'Average misses',
      }, {
        dataIndex: 'total_score',
        title: 'Total score',
      }, {
        dataIndex: 'average_score',
        title: 'Average score',
      },
    ];

    return (
      <Table
        dataSource={data}
        columns={columns}
        rowKey={record => record.online_id}
        sortDirections={['ascend', 'descend']}
      />
    );
  }
}
