import * as React from "react";
import { Match } from "../../entities/Match";
import { MatchListTable } from "./MatchListTable";
import AddMatchButton from "../tournaments/AddMatchButton";

type HomeProps = {
  data: Match[];
}

export function Home(props: HomeProps) {
  return (
    <div className="h-100">
      <AddMatchButton />
      <MatchListTable initialData={props.data} />
    </div>
  );
}
