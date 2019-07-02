import { Radio, Tabs } from "antd";
import { RadioChangeEvent } from "antd/lib/radio";
import moment from "moment";
import * as React from "react";
import { IMatch } from "../../entities/IMatch";
import { IPlayerStatistic } from "../../entities/IPlayerStatistic";
import ITournament from "../../entities/ITournament";
import MatchListTable from "./MatchListTable";
import PlayerListTable from "./PlayerListTable";

export interface ITournamentDetailsProps {
  tournament: ITournament;
  matches: IMatch[];
  players: IPlayerStatistic[];
}

interface ITournamentDetailsState {
  activeTab: "matches" | "players";
  roundNameFilter: string;
}

const DATE_DISPLAY_FORMAT = "DD MMM YYYY";

export default class TournamentDetails extends React.Component<ITournamentDetailsProps, ITournamentDetailsState> {
  public state: ITournamentDetailsState = { activeTab: "matches", roundNameFilter: null };

  public render() {
    const { tournament, matches, players } = this.props;
    const { activeTab } = this.state;

    return (
      <div className="p-4">
        <h2>{tournament.name}</h2>
        <h5>hosted by {this.getHostLink()}</h5>
        <h6>
          {`${moment(tournament.start_date).format(DATE_DISPLAY_FORMAT)} - ${moment(tournament.end_date).format(DATE_DISPLAY_FORMAT)}`}
        </h6>

        <Tabs
          activeKey={activeTab}
          renderTabBar={this.renderTabBar}
        >
          <Tabs.TabPane key="matches" tab="Matches">
            <MatchListTable data={matches} />
          </Tabs.TabPane>
          <Tabs.TabPane key="players" tab="Player statistics">
            <PlayerListTable data={players} />
          </Tabs.TabPane>
        </Tabs>
      </div>
    );
  }

  private getHostLink(): React.ReactNode {
    const { tournament: { host_player: { name, id } } } = this.props;

    return <a href={`https://osu.ppy.sh/users/${id}`} target="_blank">{name}</a>;
  }

  private onChangeTab = (e: RadioChangeEvent) => this.setState({ activeTab: e.target.value });

  private renderTabBar = () => (
    <div className="my-4 mx-auto flex_center--row">
      <Radio.Group value={this.state.activeTab} onChange={this.onChangeTab} buttonStyle="solid">
        <Radio.Button value="matches">Matches</Radio.Button>
        <Radio.Button value="players">Player statistics</Radio.Button>
      </Radio.Group>
    </div>
  )
}
