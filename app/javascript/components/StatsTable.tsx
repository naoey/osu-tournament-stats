import * as React from 'react';
import { Table } from 'antd';

export interface Statistic {
  playerName: string;
  accuracy: number;
  mapsPlayed: number;
  mapsWon: number;
};

export interface StatsTableProps {
  data: Array<Statistic>;
}

export default class StatsTable extends React.Component<StatsTableProps, {}> {
  private xhr: Request = null;

  render() {
    const { data } = this.props;

    return (
      <div>
        <Table
          dataSource={data.map(d => ({ playerName: d.playerName, accuracy: `${d.accuracy * 100}%`, winRate: `${d.mapsWon} / ${d.mapsPlayed}`}))}
          rowKey={item => item.playerName}
          columns={[{
            dataIndex: 'playerName',
            title: 'Player',
          }, {
            dataIndex: 'accuracy',
            title: 'Accuracy',
          }, {
            dataIndex: 'winRate',
            title: 'Map win rate',
          }]}
          pagination={false}
        />
      </div>
    );
  }
}
