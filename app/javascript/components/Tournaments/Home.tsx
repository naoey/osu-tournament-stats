import { Button, Col, Row, Table } from "antd";
import * as React from "react";
import Api from "../../api/Api";
import Tournaments from "../../api/requests/Tournaments";
import { TournamentEvents } from "../../events/TournamentEvents";
import { IRecentActivity } from "../../types/IRecentActivity";
import ITournament from "../../types/ITournament";
import AddButton from "./AddButton";
import TournamentListTable from "./TournamentListTable";

interface ITournamentHomeProps {
  list: ITournament[];
  recent_activity: IRecentActivity[];
}

interface ITournamentHomeState {
  list: ITournament[];
  recentActivity: IRecentActivity[];
}

export default class Home extends React.Component<ITournamentHomeProps, ITournamentHomeState> {
  constructor(props) {
    super(props);

    this.state = {
      list: props.list || [],
      recentActivity: props.recent_activity || [],
    };
  }

  public componentDidMount() {
    $(document).on(TournamentEvents.Created, this.reloadTournaments);
    $(document).on(TournamentEvents.Updated, this.reloadTournaments);
    $(document).on(TournamentEvents.Deleted, this.reloadTournaments);
  }

  public componentWillUnmount() {
    $(document).off();
  }

  public render() {
    const { list } = this.state;

    return (
      <Row className="h-100">
        <Col sm={24} md={14} className="p-3">
          <AddButton />
          <TournamentListTable data={list} className="mt-2" />
        </Col>

        <Col sm={24} md={10} className="p-3">
          <h3>Recent Activity</h3>

          <p className="mt-4 font-italic">Been pretty quiet lately...</p>
        </Col>
      </Row>
    );
  }

  private reloadTournaments = async () => {
    try {
      const request = Tournaments.getTournaments();

      const response = await Api.performRequest<ITournament[]>(request);

      this.setState({ list: response });
    } catch (e) {
      console.error(e);
    }
  }
}
