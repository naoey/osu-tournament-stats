import { Button, Col, Row, Table } from "antd";
import * as React from "react";
import { IRecentActivity } from "../../types/IRecentActivity";
import ITournament from "../../types/ITournament";
import AddButton from "./AddButton";
import TournamentListTable from "./TournamentListTable";

export interface ITournamentHomeProps {
  list: ITournament[];
  recent_activity: IRecentActivity[];
}

export default class Home extends React.Component<ITournamentHomeProps> {
  public render() {
    const { list } = this.props;

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

  private onAddTournament() {
    console.log("Adding new tournament");
  }
}
