import { Button, Col, Input, message, Row, Table } from "antd";
import * as qs from "query-string";
import * as React from "react";
import Api from "../../api/Api";
import TournamentRequests from "../../api/requests/TournamentRequests";
import { IRecentActivity } from "../../entities/IRecentActivity";
import ITournament from "../../entities/ITournament";
import { TournamentEvents } from "../../events/TournamentEvents";
import AddButton from "./AddTournamentButton";
import TournamentListTable from "./TournamentListTable";

interface ITournamentHomeProps {
  list: ITournament[];
  recent_activity: IRecentActivity[];
}

interface ITournamentHomeState {
  list: ITournament[];
  recentActivity: IRecentActivity[];
  isLoading: boolean;
  searchQuery?: string;
}

export default class Home extends React.Component<ITournamentHomeProps, ITournamentHomeState> {
  private searchDebounce: number = null;

  constructor(props: ITournamentHomeProps) {
    super(props);

    const q: any = qs.parse(window.location.search);

    this.state = {
      isLoading: false,
      list: props.list || [],
      recentActivity: props.recent_activity || [],
      searchQuery: q.name || null,
    };
  }

  public componentDidMount() {
    $(document).on(TournamentEvents.Created, () => this.reloadTournaments());
    $(document).on(TournamentEvents.Updated, () => this.reloadTournaments());
    $(document).on(TournamentEvents.Deleted, () => this.reloadTournaments());
  }

  public componentWillUnmount() {
    $(document).off();
  }

  public render() {
    const { list, isLoading, searchQuery } = this.state;

    const isAuthenticated: boolean = (window as any).isAuthenticated;

    return (
      <Row className="h-100">
        <Col sm={24} md={14} className="p-3">
          <Row>
            <Col xs={isAuthenticated ? 1 : 0}>
              <AddButton />
            </Col>
            <Col xs={isAuthenticated ? 23 : 24} className="px-2">
              <Input.Search
                className="h-100 w-100"
                placeholder="Search tournaments..."
                value={searchQuery}
                onChange={this.onSearchQueryChange}
              />
            </Col>
          </Row>
          <TournamentListTable isLoading={isLoading} data={list} className="mt-2" />
        </Col>

        <Col sm={24} md={10} className="p-3">
          <h3>Recent Activity</h3>

          <p className="mt-4 font-italic">Been pretty quiet lately...</p>
        </Col>
      </Row>
    );
  }

  private onSearchQueryChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (this.searchDebounce) {
      clearTimeout(this.searchDebounce);
    }

    const query = e.target.value;

    this.setState({ searchQuery: query });

    this.searchDebounce = window.setTimeout(() => this.reloadTournaments(query), 800);
  }

  private reloadTournaments = async (query: string = null) => {
    this.setState({ isLoading: true });

    try {
      const request = TournamentRequests.getTournaments({ name: query });

      const response = await Api.performRequest<ITournament[]>(request);

      this.setState({ list: response });
    } catch (e) {
      message.error(e.message);
    } finally {
      this.setState({ isLoading: false });
    }
  }
}
