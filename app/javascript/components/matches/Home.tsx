import * as React from "react";
import { IMatch } from "../../entities/IMatch";
import MatchListTable from "./MatchListTable";

interface IHomeProps {
  data: IMatch[];
}

export default function Home(props: IHomeProps) {
  return <MatchListTable initialData={props.data} />;
}
