import { Radio, Tabs } from "antd";
import { RadioChangeEvent } from "antd/lib/radio";
import moment from "moment";
import * as React from "react";
import { Match } from "../../entities/Match";
import { PlayerStatistic } from "../../entities/PlayerStatistic";
import { Tournament } from "../../entities/Tournament";
import { User } from "../../entities/User";
import AddMatchButton from "./AddMatchButton";
import { MatchListTable } from "../matches/MatchListTable";
import PlayerStatsListTable from "../matches/PlayerStatsListTable";
import TournamentContext from "./TournamentContext";

export interface ITournamentDetailsProps {
  tournament: Tournament;
  matches: Match[];
  players: PlayerStatistic[];
}

interface ITournamentDetailsState {
  activeTab: string;
}

const DATE_DISPLAY_FORMAT = "DD MMM YYYY";

export default class TournamentDetails extends React.Component<ITournamentDetailsProps, ITournamentDetailsState> {
  public state = {
    activeTab: "matches",
  };

  public render() {
    const { tournament } = this.props;
    const { activeTab } = this.state;

    return (
      <TournamentContext.Provider value={tournament}>
        <div className="p-4">
          <div className="flex_ends">
            <div>
              <h2>{tournament.name}</h2>
              <h5>hosted by {this.getHostLink()}</h5>
              <h6>
                {`${moment(tournament.start_date).format(DATE_DISPLAY_FORMAT)} - ${moment(tournament.end_date).format(DATE_DISPLAY_FORMAT)}`}
              </h6>
            </div>

            <div>
              <AddMatchButton tournamentId={tournament.id} checkAllowed={this.checkUserIsTournamentHost} />
            </div>
          </div>

          <Tabs
            activeKey={activeTab}
            renderTabBar={this.renderTabBar}
          >
            <Tabs.TabPane key="matches" tab="Matches">
              <MatchListTable isFocused={activeTab === "matches"} tournamentId={tournament.id} />
            </Tabs.TabPane>
            <Tabs.TabPane key="players" tab="Player statistics">
              <PlayerStatsListTable isFocused={activeTab === "players"} tournamentId={tournament.id} />
            </Tabs.TabPane>
          </Tabs>
        </div>
      </TournamentContext.Provider>
    );
  }

  private getHostLink(): React.ReactNode {
    const { tournament: { host_player: { name, id } } } = this.props;

    return <a href={`https://osu.ppy.sh/users/${id}`} target="_blank">{name}</a>;
  }

  private onChangeTab = (e: RadioChangeEvent) => this.setState({ activeTab: e.target.value });

  private renderTabBar = () => (
    <div className="my-4 flex_center">
      <Radio.Group value={this.state.activeTab} onChange={this.onChangeTab} buttonStyle="solid">
        <Radio.Button value="matches">Matches</Radio.Button>
        <Radio.Button value="players">Player statistics</Radio.Button>
      </Radio.Group>
    </div>
  )

  private checkUserIsTournamentHost = (user: User): boolean => {
    const { tournament } = this.props;

    return tournament.host_player.id === user.id;
  }
}
