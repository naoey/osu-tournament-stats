import * as React from 'react';
import { Table, Tooltip, Input } from 'antd';
import { ColumnProps } from 'antd/lib/table';
import * as v from 'voca';
import * as _ from 'lodash';
import * as qs from 'query-string';

export interface PlayerListItem {
  name: string;
  online_id: number;
  matches_played: number;
  matches_won: number;
  maps_played: number;
  maps_won: number;
  total_score: number;
  average_score: number;
  accuracy: number;
  perfect_count: number;
  average_misses: number;
  total_misses: number;
  best_accuracy: number;
  average_accuracy:number;
  maps_failed: number;
  full_combos: number;
}

export interface PlayerListTableProps {
  data: Array<PlayerListItem>;
}

export interface PlayerListTableState {
  roundNameQuery: string;
}

export interface PlayerListTableColumnDefinition {
  key: string;
  title?: string;
  render?: (text: string, record: PlayerListItem) => React.ReactNode;
  titleTooltip?: string;
}

export default class PlayerListTable extends React.Component<PlayerListTableProps, PlayerListTableState> {
  private _roundNameSearchDebounce: number = null;

  private static sorter(a:PlayerListItem, b:PlayerListItem, valueExtractor: (PlayerListItem) => number|string): number {
    let aValue = valueExtractor(a);
    let bValue = valueExtractor(b);

    if (typeof aValue === 'string') aValue = aValue.toLowerCase();
    if (typeof bValue === 'string') bValue = bValue.toLowerCase();

    if (aValue > bValue) return 1;
    if (aValue < bValue) return -1;
    return 0;
  }

  constructor(props) {
    super(props);

    const q: { round_name?: string } = qs.parse(window.location.search);

    this.state = {
      roundNameQuery: q.round_name || '',
    }
  }

  private createSortedColumn = ({
    key,
    title = null,
    render = null,
    titleTooltip = null,
  }: {
    key: string,
    title: string,
    render: (text: string, item: PlayerListItem) => any,
    titleTooltip: string,
  }, index: number): ColumnProps<PlayerListItem> => {
    const { data } = this.props;

    const column: ColumnProps<PlayerListItem> = {
      key,
      dataIndex: key,
      title: titleTooltip ?
        () => <Tooltip title={titleTooltip}>{title || v.titleCase(key.split('_').join(' '))}</Tooltip>
        : title || v.titleCase(key.split('_').join(' ')),
      sorter: (a, b) => PlayerListTable.sorter(a, b, item => item[key]),
      defaultSortOrder: 'ascend',
      sortDirections: ['ascend', 'descend'],
    };

    if (render !== null) column.render = render;

    if (index === 0) {
      column.fixed = 'left';
      column.filters = _.sortBy(
        _.uniqBy(data.map(p => ({ text: p.name, value: p.name.toLowerCase() })), i => i.text),
        p => p.value,
      );
      column.onFilter = (value, record) => record.name.toLowerCase().indexOf(value) > -1;
      column.width = 175;
    }

    return column;
  }

  private onRoundNameFilterChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (this._roundNameSearchDebounce) {
      clearTimeout(this._roundNameSearchDebounce);
      this._roundNameSearchDebounce = null;
    }

    const query = e.target.value;

    this.setState({ roundNameQuery: query });

    this._roundNameSearchDebounce = window.setTimeout(() => {
      // there is probably a much better way to do this but meh this will become ajax soon(TM)
      let search = `${window.location.protocol}//${window.location.host}${window.location.pathname}`;

      if (!!query) search += `?round_name=${encodeURIComponent(query)}`;

      window.location.href = search;
    }, 750);
  }

  render() {
    const { data } = this.props;
    const { roundNameQuery } = this.state;

    const augmentedData = data.map(d => ({
      ...d,
      maps_won_percent: Math.round(d.maps_won / d.maps_played * 100 * 100) / 100,
      matches_won_percent: Math.round(d.matches_won / d.matches_played * 100 * 100) / 100,
    }));

    const columns: PlayerListTableColumnDefinition[]  = [
      {
        key: 'name',
        render: (text, record) => (
          <a target="_blank" href={`https://osu.ppy.sh/users/${record.online_id}`}>
            {text} <i className="fas fa-external-link-alt" />
          </a>
        ),
      }, {
        key: 'matches_played',
      }, {
        key: 'matches_won',
      }, {
        key: 'matches_won_percent',
        title: 'Match win %',
        render: text => <span>{text}%</span>,
      }, {
        key: 'maps_played',
      }, {
        key: 'maps_won',
      }, {
        key: 'maps_won_percent',
        title: 'Maps win %',
        render: text => <span>{text}%</span>,
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
      }, {
        key: 'full_combos',
        titleTooltip: 'Approximated FC. Doesn\'t count maps that have been deleted from osu servers.',
      }
    ];

    return (
      <div>
        <div>
          <Input.Search
            onChange={this.onRoundNameFilterChange}
            value={roundNameQuery}
            placeholder="Filter stats by round name..."
          />
        </div>

        <Table
          dataSource={augmentedData}
          columns={columns.map(this.createSortedColumn)}
          rowKey={record => record.online_id.toString()}
          sortDirections={['ascend', 'descend']}
          pagination={false}
          scroll={{ x: '150%' }}
        />
      </div>
    );
  }
}
