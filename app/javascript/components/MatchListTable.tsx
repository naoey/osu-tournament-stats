import * as React from 'react';
import * as moment from 'moment';
import { Table } from 'antd';

export interface MatchListItem {
  name: string;
  id: number,
  timestamp: string,
}

export interface MatchListTableProps {
  data: Array<MatchListItem>;
}

export default class MatchListTable extends React.Component<MatchListTableProps, {}> {
  render() {
    const { data } = this.props;

    const columns = [{
      dataIndex: 'name',
      title: "Match",
      render: (text, record) => (
        <a href={`/statistics/match/${record.id}`}>
          {text}
        </a>
      ),
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
