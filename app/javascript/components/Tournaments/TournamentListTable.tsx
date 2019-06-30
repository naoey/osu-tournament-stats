import { Table } from "antd";
import moment from "moment";
import * as React from "react";
import ITournament from "../../types/ITournament";

export interface ITournamentListTableProps {
  data: ITournament[];
  className?: string;
  style?: any;
}

const DATE_RANGE_FORMAT = "DD MMM YYYY";

export default class TournamentListTable extends React.Component<ITournamentListTableProps> {
  public render() {
    const { data, className, style } = this.props;

    const columns = [{
      dataIndex: "name",
      key: "name",
      render: (_: string, record: ITournament) => <a href={`/tournaments/${record.id}`}>{record.name}</a>,
      title: "Name",
    }, {
      dataIndex: "host_player.name",
      key: "host",
      title: "Host",
    }, {
      dataIndex: "match_count",
      key: "match_count",
      title: "Matches",
    }, {
      key: "dates",
      render: (_: string, record: ITournament) => `${moment(record.start_date).format(DATE_RANGE_FORMAT)} - ${moment(record.end_date).format(DATE_RANGE_FORMAT)}`,
      title: "Dates",
    }];

    return (
      <Table
        dataSource={data}
        rowKey={this.keyExtractor}
        columns={columns}
        className={className}
        style={style}
        pagination={{
          pageSize: 10,
        }}
      />
    );
  }

  private keyExtractor = (item: ITournament): string => item.id.toString();
}
