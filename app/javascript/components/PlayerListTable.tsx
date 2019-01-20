import * as React from 'react';
import { Table } from 'antd';
import { ColumnProps } from 'antd/lib/table';

export interface PlayerListItem {
  name: string;
  online_id: number;
  matches_played: number;
  matches_won: number;
  maps_played: number;
  maps_won: number;
  total_score: number;
  average_score: number,
  accuracy: number;
  perfect_count: number;
  average_misses: number;
  total_misses: number;
  best_accuracy: number;
  average_accuracy:number;
  maps_failed: number,
}

export interface PlayerListTableProps {
  data: Array<PlayerListItem>;
}

export default class PlayerListTable extends React.Component<PlayerListTableProps> {
  static sorter(a:PlayerListItem, b:PlayerListItem, valueExtractor: (PlayerListItem) => number|string): number {
    if (valueExtractor(a) > valueExtractor(b)) return 1;
    if (valueExtractor(a) < valueExtractor(b)) return -1;
    return 0;
  }

  render() {
    const { data } = this.props;

    const columns: ColumnProps<PlayerListItem>[]  = [
      {
        dataIndex: 'name',
        title: 'Name',
        render: (text, record) => <a target="_blank" href={`https://osu.ppy.sh/users/${record.online_id}`}>{text} <i className="fas fa-external-link-alt" /></a>,
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.name),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'matches_played',
        title: 'Matches played',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.matches_played),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        key: 'matches_won',
        dataIndex: 'matches_won',
        title: 'Matches won',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.matches_won),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        key: 'matches_won_percent',
        dataIndex: 'matches_won',
        title: 'Match win %',
        render: (text, record) => <span>{Math.round(record.matches_won / record.matches_played * 100 * 100) / 100}%</span>,
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.matches_won / item.matches_played),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'maps_played',
        title: 'Maps played',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.maps_played),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        key: 'maps_won',
        dataIndex: 'maps_won',
        title: 'Maps won',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.maps_won),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        key: 'maps_won_percent',
        dataIndex: 'maps_won',
        title: 'Maps win %',
        render: (text, record) => <span>{Math.round(record.maps_won / record.maps_played * 100 * 100) / 100}%</span>,
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.maps_won / item.maps_played),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'best_accuracy',
        title: 'Best accuracy',
        render: (text, record) => <span>{record.best_accuracy}%</span>,
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.best_accuracy),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'average_accuracy',
        title: 'Average accuracy',
        render: (text, record) => <span>{record.average_accuracy}%</span>,
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.average_accuracy),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'perfect_count',
        title: 'Perfect maps',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.perfect_count),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'total_misses',
        title: 'Total misses',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.total_misses),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'average_misses',
        title: 'Average misses',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.average_misses),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'total_score',
        title: 'Total score',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.total_score),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'average_score',
        title: 'Average score',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.average_score),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }, {
        dataIndex: 'maps_failed',
        title: 'Maps failed',
        sorter: (a, b, sortOrder) => PlayerListTable.sorter(a, b, item => item.average_score),
        defaultSortOrder: 'ascend',
        sortDirections: ['ascend', 'descend'],
      }
    ];

    return (
      <Table
        dataSource={data}
        columns={columns}
        rowKey={record => record.online_id.toString()}
        sortDirections={['ascend', 'descend']}
        pagination={false}
      />
    );
  }
}
