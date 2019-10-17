import { Col, message, Row } from "antd";
import * as React from "react";
import Api from "../../api/Api";
import TournamentRequests from "../../api/requests/TournamentRequests";
import { IRecentActivity } from "../../entities/IRecentActivity";
import ITournament from "../../entities/ITournament";
import { TournamentEvents } from "../../events/TournamentEvents";
import { DebouncedSearchField } from "../common";
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
  constructor(props: ITournamentHomeProps) {
    super(props);

    this.state = {
      isLoading: false,
      list: props.list || [],
      recentActivity: props.recent_activity || [],
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
              <DebouncedSearchField onSearch={this.onSearch} placeholder="Search tournaments..." />
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

  private onSearch = (query: string) => this.reloadTournaments(query)

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
