import { Table } from "antd";
import moment from "moment";
import * as React from "react";
import Tournament from "../../entities/Tournament";

export interface ITournamentListTableProps {
  data: Tournament[];
  className?: string;
  style?: any;
  isLoading?: boolean;
}

const DATE_RANGE_FORMAT = "DD MMM YYYY";

export default class TournamentListTable extends React.Component<ITournamentListTableProps> {
  public static defaultProps: Partial<ITournamentListTableProps> = {
    isLoading: false,
  };

  public render() {
    const { data, className, style, isLoading } = this.props;

    const columns = [{
      dataIndex: "name",
      key: "name",
      render: (_: string, record: Tournament) => <a href={`/tournaments/${record.id}`}>{record.name}</a>,
      title: "Name",
    }, {
      dataIndex: ["host_player", "name"],
      key: "host",
      title: "Host",
    }, {
      dataIndex: "match_count",
      key: "match_count",
      title: "Matches",
    }, {
      key: "dates",
      render: (_: string, record: Tournament) => `${moment(record.start_date).format(DATE_RANGE_FORMAT)} - ${moment(record.end_date).format(DATE_RANGE_FORMAT)}`,
      title: "Dates",
    }];

    return (
      <Table
        loading={isLoading}
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

  private keyExtractor = (item: Tournament): string => item.id.toString();
}
