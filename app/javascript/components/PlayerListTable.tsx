import * as React from 'react';
import { Table } from 'antd';
import { ColumnProps } from 'antd/lib/table';
import * as v from 'voca';
import uuid from 'uuid';

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
    let aValue = valueExtractor(a);
    let bValue = valueExtractor(b);

    if (typeof aValue === 'string') aValue = aValue.toLowerCase();
    if (typeof bValue === 'string') bValue = bValue.toLowerCase();

    if (aValue > bValue) return 1;
    if (aValue < bValue) return -1;
    return 0;
  }

  static createSortedColumn({
    key,
    title = null,
    render = null}: {
    key: string,
    title: string,
    render: (text: string, item: PlayerListItem) => any,
  }, index: number): ColumnProps<PlayerListItem> {
    const column: ColumnProps<PlayerListItem> = {
      key: uuid.v1(),
      dataIndex: key,
      title: title || v.titleCase(key.split('_').join(' ')),
      sorter: (a, b) => PlayerListTable.sorter(a, b, item => item[key]),
      defaultSortOrder: 'ascend',
      sortDirections: ['ascend', 'descend'],
    };

    if (render !== null) column.render = render;

    if (index === 0) column.fixed = 'left';

    return column;
  }

  render() {
    const { data } = this.props;

    const columns: ColumnProps<PlayerListItem>[]  = [
      {
        key: 'name',
        render: (text, record) => <a target="_blank" href={`https://osu.ppy.sh/users/${record.online_id}`}>{text} <i className="fas fa-external-link-alt" /></a>,
      }, {
        key: 'matches_played',
      }, {
        key: 'matches_won',
      }, {
        key: 'matches_won',
        title: 'Match win %',
        render: (text, record) => <span>{Math.round(record.matches_won / record.matches_played * 100 * 100) / 100}%</span>,
      }, {
        key: 'maps_played',
        title: 'Maps played',
      }, {
        key: 'maps_won',
      }, {
        key: 'maps_won_percent',
        title: 'Maps win %',
        render: (text, record) => <span>{Math.round(record.maps_won / record.maps_played * 100 * 100) / 100}%</span>,
      }, {
        key: 'best_accuracy',
        render: (text, record) => <span>{record.best_accuracy}%</span>,
      }, {
        key: 'average_accuracy',
        render: (text, record) => <span>{record.average_accuracy}%</span>,
      }, {
        key: 'perfect_count',
        title: 'Perfect maps',
      }, {
        key: 'total_misses',
      }, {
        key: 'average_misses',
      }, {
        key: 'total_score',
      }, {
        key: 'average_score',
      }, {
        key: 'maps_failed',
      }
    ];

    return (
      <Table
        dataSource={data}
        columns={columns.map(PlayerListTable.createSortedColumn)}
        rowKey={record => record.online_id.toString()}
        sortDirections={['ascend', 'descend']}
        pagination={false}
        scroll={{ x: 1500 }}
      />
    );
  }
}
