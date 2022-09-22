import { Button, message, Modal, Table, Tooltip } from "antd";
import { ColumnProps } from "antd/lib/table";
import * as _ from "lodash";
import * as React from "react";
import * as v from "voca";
import Api from "../../api/Api";
import StatisticsRequests from "../../api/requests/StatisticsRequests";
import { PlayerStatistic } from "../../entities/PlayerStatistic";
import BeatmapRequests from "../../api/requests/BeatmapRequests";
import { Beatmap } from "../../entities/Beatmap";
import LoadingView from "../common/LoadingView";

export interface IPlayerStatsListTableProps {
  tournamentId?: number;
  matchId?: number;
  isFocused?: boolean;
  hiddenColumns?: string[];
}

interface IPlayerListTableColumnDefinition {
  key: string;
  title?: string;
  render?: (text: string, record: PlayerStatistic) => React.ReactNode;
  titleTooltip?: string;
}

enum DetailModal {
  MapsWon = 'Maps won',
  MapsPlayed = 'Maps played',
  FullCombos = 'Full combos',
  BestAccuracy = 'Best accuracy',
  PerfectMaps = 'Perfect maps',
  MapsFailed = 'Maps failed',
};

interface DetailModalState {
  type: DetailModal;
  statistic: PlayerStatistic;
  isLoading: boolean;
  data?: any;
  title: string;
}

function sorter(a: PlayerStatistic, b: PlayerStatistic, valueExtractor: (IPlayerStatistic) => number | string): number {
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

      const response = await Api.performRequest<PlayerStatistic[]>(request);

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

  const keyExtractor = (record: PlayerStatistic): string => record.player.id.toString();

  const createSortedColumn = (
    { key, title = null, render = null, titleTooltip = null }: IPlayerListTableColumnDefinition,
    index: number,
  ): ColumnProps<PlayerStatistic> => {
    const column: ColumnProps<PlayerStatistic> = {
      dataIndex: key.split("."),
      defaultSortOrder: "ascend",
      key,
      sortDirections: ["ascend", "descend"],
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

    if (key === 'best_accuracy')
      column.sorter = (a, b) => sorter(a, b, item => item.best_accuracy.accuracy);
    else if (['maps_won', 'maps_played', 'maps_failed', 'full_combos'].includes(key))
      column.sorter = (a, b) => sorter(a, b, item => item[key].length);
    else
      column.sorter = (a, b) => sorter(a, b, item => item[key]);

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

  const showDetailModal = async (detail: DetailModal, record: PlayerStatistic) => {
    let request;

    switch (detail) {
      case DetailModal.FullCombos:
        request = record.full_combos.length > 0 ? BeatmapRequests.getBeatmaps({ ids: record.full_combos }) : null;
        break;

      case DetailModal.BestAccuracy:
        request = BeatmapRequests.getBeatmaps({ ids: [record.best_accuracy.beatmap_id] });
        break;

      case DetailModal.MapsFailed:
        request = record.maps_failed.length > 0 ? BeatmapRequests.getBeatmaps({ ids: record.maps_failed }) : null;
        break;

      case DetailModal.MapsPlayed:
        request = record.maps_played.length > 0 ? BeatmapRequests.getBeatmaps({ ids: record.maps_played }) : null;
        break;

      case DetailModal.MapsWon:
        request = record.maps_won.length > 0 ? BeatmapRequests.getBeatmaps({ ids: record.maps_won }) : null;
        break;

      case DetailModal.PerfectMaps:
        request = record.perfect_maps.length > 0 ? BeatmapRequests.getBeatmaps({ ids: record.perfect_maps }) : null;
        break;

      default:
        break;
    }

    if (request === null) {
      message.info('No details for record!');
      return;
    }

    const details = {
      isLoading: true,
      type: detail,
      title: `${detail} for ${record.player.name}`,
      statistic: record,
    };

    setDetailModal(details);

    try {
      const response = await Api.performRequest(request);

      setDetailModal({ ...details, isLoading: false, data: response });
    } catch (e) {
      message.error(e.message || 'An error occured!');
      setDetailModal(null);
    }
  };

  const renderDetailModal = () => {
    if (detailModal === null)
      return null;

    if (detailModal.isLoading)
      return <LoadingView />;

    switch (detailModal.type) {
      case DetailModal.FullCombos:
      case DetailModal.PerfectMaps:
      case DetailModal.MapsWon:
      case DetailModal.MapsPlayed:
      case DetailModal.MapsFailed:
      case DetailModal.BestAccuracy:
        return (
          <ul>
            {
              detailModal.data?.map(d => <li key={d.id}>{d.name}</li>) ?? null
            }
          </ul>
        );

      default:
        return null;
    }
  };

  const augmentedData = data.map(d => ({
    ...d,
    maps_won_percent: Math.round(d.maps_won.length / d.maps_played.length * 100 * 100) / 100,
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
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.MapsPlayed, record)}>
          {record.maps_played.length}
        </Button>
      ),
    }, {
      key: "maps_won",
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.MapsWon, record)}>
          {record.maps_won.length}
        </Button>
      ),
    }, {
      key: "maps_won_percent",
      render: text => <span>{text}%</span>,
      title: "Maps win %",
    }, {
      key: "best_accuracy",
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.BestAccuracy, record)}>
          {record.best_accuracy.accuracy}%
        </Button>
      ),
    }, {
      key: "average_accuracy",
      render: (text, record) => <span>{record.average_accuracy}%</span>,
    }, {
      key: "perfect_count",
      title: "Perfect maps",
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.PerfectMaps, record)}>
          {record.perfect_maps.length}
        </Button>
      ),
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
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.MapsFailed, record)}>
          {record.maps_failed.length}
        </Button>
      ),
    }, {
      key: "full_combos",
      titleTooltip: "Approximated FC. Doesn't count maps that have been deleted from osu servers.",
      render: (text, record) => (
        <Button className="link" onClick={() => showDetailModal(DetailModal.FullCombos, record)}>
          {record.full_combos.length}
        </Button>
      ),
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
          position: ["topRight"],
        }}
        scroll={{ x: "100%" }}
      />
      <Modal
        visible={detailModal !== null}
        title={detailModal?.title}
        onOk={() => setDetailModal(null)}
        onCancel={() => setDetailModal(null)}
        footer={null}
      >
        {renderDetailModal()}
      </Modal>
    </React.Fragment>
  );
}
