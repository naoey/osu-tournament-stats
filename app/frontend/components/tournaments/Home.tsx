import { Col, message, Row } from "antd";
import * as React from "react";
import Api from "../../api/Api";
import TournamentRequests from "../../api/requests/TournamentRequests";
import { RecentActivity } from "../../entities/RecentActivity";
import { Tournament } from "../../entities/Tournament";
import { GeneralEvents } from "../../events/GeneralEvents";
import { DebouncedSearchField } from "../common/DebouncedSearchField";
import AddButton from "./AddTournamentButton";
import TournamentListTable from "./TournamentListTable";
import PageRoot from "../common/PageRoot";

interface ITournamentHomeProps {
  list: Tournament[];
  recent_activity: RecentActivity[];
}

interface ITournamentHomeState {
  list: Tournament[];
  recentActivity: RecentActivity[];
  isLoading: boolean;
  searchQuery?: string;
}

@PageRoot
export class Home extends React.Component<ITournamentHomeProps, ITournamentHomeState> {
  constructor(props: ITournamentHomeProps) {
    super(props);

    this.state = {
      isLoading: false,
      list: props.list || [],
      recentActivity: props.recent_activity || [],
    };
  }

  public componentDidMount() {
    $(document).on(GeneralEvents.TournamentCreated, () => this.reloadTournaments());
    $(document).on(GeneralEvents.TournamentUpdated, () => this.reloadTournaments());
    $(document).on(GeneralEvents.TournamentDeleted, () => this.reloadTournaments());
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
              {/* TODO: restore after ACL is implemented since everyone can login now */}
              {/*<AddButton />*/}
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

  private reloadTournaments = async (query: string | null = null) => {
    this.setState({ isLoading: true });

    try {
      const request = TournamentRequests.getTournaments({ name: query });

      const response = await Api.performRequest<Tournament[]>(request);

      this.setState({ list: response });
    } catch (e: any) {
      message.error(e.message);
    } finally {
      this.setState({ isLoading: false });
    }
  }
}
