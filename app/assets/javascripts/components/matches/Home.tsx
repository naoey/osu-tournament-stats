import * as React from "react";
import { Match } from "../../entities/Match";
import MatchListTable from "./MatchListTable";
import AddMatchButton from "../tournaments/AddMatchButton";

interface IHomeProps {
  data: Match[];
}

export default function Home(props: IHomeProps) {
  const isAuthenticated = (window as any).isAuthenticated;

  return (
    <div className="h-100">
      <AddMatchButton />
      <MatchListTable initialData={props.data} />
    </div>
  );
}
