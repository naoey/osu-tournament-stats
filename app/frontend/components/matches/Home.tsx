import * as React from "react";
import { Match } from "../../entities/Match";
import { MatchListTable } from "./MatchListTable";
import AddMatchButton from "../tournaments/AddMatchButton";
import PageRoot from "../common/PageRoot";

type HomeProps = {
  data: Match[];
}

export const Home = PageRoot(function Home(props: HomeProps) {
  return (
    <div className="h-100">
      {/* TODO: enable after proper ACL is implemented since everyone can login now */}
      {/*<AddMatchButton />*/}
      <MatchListTable initialData={props.data} />
    </div>
  );
})
