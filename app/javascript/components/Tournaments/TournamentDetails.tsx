import {Input, message, Radio, Row, Tabs} from "antd";
import { RadioChangeEvent } from "antd/lib/radio";
import moment from "moment";
import * as React from "react";
import { IMatch } from "../../entities/IMatch";
import { IPlayerStatistic } from "../../entities/IPlayerStatistic";
import ITournament from "../../entities/ITournament";
import { IUser } from "../../entities/IUser";
import AddMatchButton from "./AddMatchButton";
import MatchListTable from "./MatchListTable";
import PlayerListTable from "./PlayerListTable";
import TournamentRequests from "../../api/requests/TournamentRequests";
import Api from "../../api/Api";

export interface ITournamentDetailsProps {
  tournament: ITournament;
  matches: IMatch[];
  players: IPlayerStatistic[];
}

interface ITournamentDetailsState {
  activeTab: "matches" | "players";
  roundNameFilter: string;
  players: IPlayerStatistic[];
  matches: IMatch[];
  isLoading: boolean,
}

interface IAPITournament {
  tournament: ITournament;
  matches: IMatch[],
  player_statistics: IPlayerStatistic[];
}

const DATE_DISPLAY_FORMAT = "DD MMM YYYY";

export default class TournamentDetails extends React.Component<ITournamentDetailsProps, ITournamentDetailsState> {
  private searchDebounce: number = null;

  constructor(props) {
    super(props);

    this.state = {
      activeTab: "matches",
      roundNameFilter: null,
      players: props.players || [],
      matches: props.matches || [],
      isLoading: false,
    }
  }

  public render() {
    const { tournament } = this.props;
    const { activeTab, matches, players, roundNameFilter } = this.state;

    return (
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
            <AddMatchButton checkAllowed={this.checkUserIsTournamentHost} />
          </div>
        </div>

        <Tabs
          activeKey={activeTab}
          renderTabBar={this.renderTabBar}
        >
          <Tabs.TabPane key="matches" tab="Matches">
            <MatchListTable data={matches} />
          </Tabs.TabPane>
          <Tabs.TabPane key="players" tab="Player statistics">
            <Row>
              <Input.Search
                className="h-100 w-100"
                placeholder="Search tournaments..."
                value={roundNameFilter}
                onChange={this.onSearchQueryChange}
            />
            </Row>
            <PlayerListTable data={players} />
          </Tabs.TabPane>
        </Tabs>
      </div>
    );
  }

  private onSearchQueryChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (this.searchDebounce) {
      clearTimeout(this.searchDebounce);
    }

    const query = e.target.value;

    this.setState({ roundNameFilter: query });

    this.searchDebounce = window.setTimeout(() => this.reloadTournament(query), 800);
  }

  private reloadTournament = async (query: string = null) => {
    const { tournament } = this.props;

    this.setState({ isLoading: true });

    try {
      const request = TournamentRequests.getTournament({ round_name: query, id:  tournament.id });

      const response = await Api.performRequest<IAPITournament>(request);

      this.setState({ players: response.player_statistics });
    } catch (e) {
      message.error(e.message);
    } finally {
      this.setState({ isLoading: false });
    }
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

  private checkUserIsTournamentHost = (user: IUser): boolean => {
    const { tournament } = this.props;

    return tournament.host_player.id === user.id;
  }
}
