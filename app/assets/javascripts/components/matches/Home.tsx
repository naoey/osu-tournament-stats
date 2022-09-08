import * as React from "react";
import { IMatch } from "../../entities/IMatch";
import MatchListTable from "./MatchListTable";
import AddMatchButton from "../tournaments/AddMatchButton";

interface IHomeProps {
  data: IMatch[];
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
