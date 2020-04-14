import { Button, message, Modal, Table, Tooltip } from "antd";
import { ColumnProps } from "antd/lib/table";
import * as _ from "lodash";
import * as React from "react";
import * as v from "voca";
import Api from "../../api/Api";
import StatisticsRequests from "../../api/requests/StatisticsRequests";
import { IPlayerStatistic } from "../../entities/IPlayerStatistic";
import BeatmapRequests from "../../api/requests/BeatmapRequests";
import { IBeatmap } from "../../entities/IBeatmap";

export interface IPlayerStatsListTableProps {
  tournamentId?: number;
  matchId?: number;
  isFocused?: boolean;
  hiddenColumns?: string[];
}

interface IPlayerListTableColumnDefinition {
  key: string;
  title?: string;
  render?: (text: string, record: IPlayerStatistic) => React.ReactNode;
  titleTooltip?: string;
}

enum DetailModal {
  MapsWon = 'Maps won',
  MapsLost = 'Maps lost',
  FullCombos = 'Full combos',
  BestAccuracy = 'Best accuracy',
};

interface DetailModalState {
  type: DetailModal;
  statistic: IPlayerStatistic;
  isLoading: boolean;
  data?: any;
}

function sorter(a: IPlayerStatistic, b: IPlayerStatistic, valueExtractor: (IPlayerStatistic) => number | string): number {
  let aValue = valueExtractor(a);
  let bValue = valueExtractor(b);

  if (typeof aValue === "string") aValue = aValue.toLowerCase();
  if (typeof bValue === "string") bValue = bValue.toLowerCase();

  if (aValue > bValue) return 1;
  if (aValue < bValue) return -1;
  return 0;
}

export default function PlayerStatsListTable({
  matchId,
  tournamentId,
  isFocused = true,
  hiddenColumns = [],
}: IPlayerStatsListTableProps) {
  const [isLoading, setIsLoading] = React.useState(true);
  const [data, setData] = React.useState([]);
  const [detailModal, setDetailModal] = React.useState<null | DetailModalState>(null);

  const loadData = async () => {
    if (!matchId && !tournamentId) {
      setIsLoading(false);
      return;
    }

    setIsLoading(true);

    try {
      let request;

      if (matchId) request = StatisticsRequests.getMatchStatistics({ matchId });
      else if (tournamentId) request = StatisticsRequests.getTournamentStatistics({ tournamentId });

      const response = await Api.performRequest<IPlayerStatistic[]>(request);

      setData(response);
    } catch (e) {
      message.error(e.message);
    } finally {
      setIsLoading(false);
    }
  };

  React.useEffect(() => {
    if (isFocused) loadData();
  }, [isFocused]);

  const keyExtractor = (record: IPlayerStatistic): string => record.player.id.toString();

  const createSortedColumn = (
    { key, title = null, render = null, titleTooltip = null }: IPlayerListTableColumnDefinition,
    index: number,
  ): ColumnProps<IPlayerStatistic> => {
    const column: ColumnProps<IPlayerStatistic> = {
      dataIndex: key,
      defaultSortOrder: "ascend",
      key,
      sortDirections: ["ascend", "descend"],
      sorter: (a, b) => sorter(a, b, item => item[key]),
      title: titleTooltip ?
        () => (
          <Tooltip title={titleTooltip}>
            <span>
              {title || v.titleCase(key.split("_").join(" "))}
            </span>
          </Tooltip>
        )
        : title || v.titleCase(key.split("_").join(" ")),
    };

    if (render !== null) column.render = render;

    if (index === 0) {
      column.fixed = "left";
      column.filters = _.sortBy(
        _.uniqBy(data.map(p => ({ text: p.player.name, value: p.player.name.toLowerCase() })), i => i.text),
        p => p.value,
      );
      column.onFilter = (value, record) => record.player.name.toLowerCase().indexOf(value.toString()) > -1;
      column.width = 175;
    }

    return column;
  };

  const showDetailModal = async (detail: DetailModal, record: IPlayerStatistic) => {
    setDetailModal({
      isLoading: true,
      type: detail,
      statistic: record,
    });

    let request;

    switch (detail) {
      case DetailModal.FullCombos:
        request = BeatmapRequests.getBeatmaps({ ids: record.full_combos });
        break

      default:
        break;
    }

    try {
      const response = await Api.performRequest(request);

      setDetailModal({ ...detailModal, data: response });
    } catch (e) {
      message.error(e.message || 'An error occured!');
      setDetailModal(null);
    }
  };

  const renderDetailModal = () => {
    if (detailModal === null)
      return null;

    switch (detailModal.type) {
      case DetailModal.FullCombos:
        return (
          <ul>
            {
              detailModal.data.map(d => (
                <li key={d.id}>
                  {d.name}
                </li>
              ))
            }
          </ul>
        );

      default:
        return null;
    }
  };

  const augmentedData = data.map(d => ({
    ...d,
    maps_won_percent: Math.round(d.maps_won / d.maps_played * 100 * 100) / 100,
    matches_won_percent: Math.round(d.matches_won / d.matches_played * 100 * 100) / 100,
  }));

  const columns: IPlayerListTableColumnDefinition[] = [
    {
      key: "player.name",
      render: (text, record) => (
        <a target="_blank" href={`https://osu.ppy.sh/users/${record.online_id}`}>
          {text} <i className="fas fa-external-link-alt"/>
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
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.FullCombos, record)}>
          {record.full_combos.length}
        </Button>
      )
    },
  ];

  return (
    <React.Fragment>
      <Table
        loading={isLoading}
        dataSource={augmentedData}
        columns={columns.filter(c => !hiddenColumns.includes(c.key)).map(createSortedColumn)}
        rowKey={keyExtractor}
        sortDirections={["ascend", "descend"]}
        pagination={{
          pageSize: 10,
          position: "top",
        }}
        scroll={{ x: "100%" }}
      />
      <Modal
        visible={detailModal !== null}
        title={detailModal?.type}
      >
        {renderDetailModal()}
      </Modal>
    </React.Fragment>
  );
}
