import { message, Table, Tooltip } from "antd";
import { ColumnProps } from "antd/lib/table";
import * as _ from "lodash";
import * as React from "react";
import * as v from "voca";
import Api from "../../api/Api";
import StatisticsRequests from "../../api/requests/StatisticsRequests";
import { IPlayerStatistic } from "../../entities/IPlayerStatistic";

export interface IPlayerListTableProps {
  tournamentId?: number;
  matchId?: number;
}

export interface IPlayerListTableState {
  data: IPlayerStatistic[];
  isLoading: boolean;
}

interface IPlayerListTableColumnDefinition {
  key: string;
  title?: string;
  render?: (text: string, record: IPlayerStatistic) => React.ReactNode;
  titleTooltip?: string;
}

export default class PlayerListTable extends React.Component<IPlayerListTableProps, IPlayerListTableState> {
  private static sorter(a: IPlayerStatistic, b: IPlayerStatistic, valueExtractor: (IPlayerStatistic) => number | string): number {
    let aValue = valueExtractor(a);
    let bValue = valueExtractor(b);

    if (typeof aValue === "string") aValue = aValue.toLowerCase();
    if (typeof bValue === "string") bValue = bValue.toLowerCase();

    if (aValue > bValue) return 1;
    if (aValue < bValue) return -1;
    return 0;
  }

  public state = { data: [], isLoading: true };

  public async componentDidMount() {
    const { matchId, tournamentId } = this.props;

    try {
      let request;

      if (matchId) request = StatisticsRequests.getMatchStatistics({ matchId });
      else if (tournamentId) request = StatisticsRequests.getTournamentStatistics({ tournamentId });
      else {
        this.setState({ isLoading: false });
        return;
      }

      const response = await Api.performRequest<IPlayerStatistic[]>(request);

      this.setState({ isLoading: false, data: response });
    } catch (e) {
      message.error(e.message);
    }
  }

  public render() {
    const { data, isLoading } = this.state;

    const augmentedData = data.map(d => ({
      ...d,
      maps_won_percent: Math.round(d.maps_won / d.maps_played * 100 * 100) / 100,
      matches_won_percent: Math.round(d.matches_won / d.matches_played * 100 * 100) / 100,
    }));

    const columns: IPlayerListTableColumnDefinition[]  = [
      {
        key: "player.name",
        render: (text, record) => (
          <a target="_blank" href={`https://osu.ppy.sh/users/${record.online_id}`}>
            {text} <i className="fas fa-external-link-alt" />
          </a>
        ),
      }, {
        key: "matches_played",
      }, {
        key: "matches_won",
      }, {
        key: "matches_won_percent",
        render: text => <span>{text}%</span>,
        title: "Match win %",
      }, {
        key: "maps_played",
      }, {
        key: "maps_won",
      }, {
        key: "maps_won_percent",
        render: text => <span>{text}%</span>,
        title: "Maps win %",
      }, {
        key: "best_accuracy",
        render: (text, record) => <span>{record.best_accuracy}%</span>,
      }, {
        key: "average_accuracy",
        render: (text, record) => <span>{record.average_accuracy}%</span>,
      }, {
        key: "perfect_count",
        title: "Perfect maps",
      }, {
        key: "total_misses",
      }, {
        key: "average_misses",
      }, {
        key: "total_score",
      }, {
        key: "average_score",
      }, {
        key: "maps_failed",
      }, {
        key: "full_combos",
        titleTooltip: "Approximated FC. Doesn't count maps that have been deleted from osu servers.",
      },
    ];

    return (
      <Table
        loading={isLoading}
        dataSource={augmentedData}
        columns={columns.map(this.createSortedColumn)}
        rowKey={this.keyExtractor}
        sortDirections={["ascend", "descend"]}
        pagination={{
          pageSize: 10,
          position: "top",
        }}
        scroll={{ x: "150%" }}
      />
    );
  }

  private keyExtractor = (record: IPlayerStatistic): string => record.player.id.toString();

  private createSortedColumn = (
    { key, title = null, render = null, titleTooltip = null }: IPlayerListTableColumnDefinition,
    index: number,
  ): ColumnProps<IPlayerStatistic> => {
    const { data } = this.state;

    const column: ColumnProps<IPlayerStatistic> = {
      dataIndex: key,
      defaultSortOrder: "ascend",
      key,
      sortDirections: ["ascend", "descend"],
      sorter: (a, b) => PlayerListTable.sorter(a, b, item => item[key]),
      title: titleTooltip ?
        () => <Tooltip title={titleTooltip}>{title || v.titleCase(key.split("_").join(" "))}</Tooltip>
        : title || v.titleCase(key.split("_").join(" ")),
    };

    if (render !== null) column.render = render;

    if (index === 0) {
      column.fixed = "left";
      column.filters = _.sortBy(
        _.uniqBy(data.map(p => ({ text: p.player.name, value: p.player.name.toLowerCase() })), i => i.text),
        p => p.value,
      );
      column.onFilter = (value, record) => record.player.name.toLowerCase().indexOf(value) > -1;
      column.width = 175;
    }

    return column;
  }
}
