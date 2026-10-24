import * as React from "react";

import { Match } from "../../entities/Match";
import PageRoot from "../common/PageRoot";
import { MatchListTable } from "./MatchListTable";

type HomeProps = {
  data: Match[];
};

export const Home = PageRoot(function Home(props: HomeProps) {
  return (
    <div className="h-100">
      {/* TODO: enable after proper ACL is implemented since everyone can login now */}
      {/*<AddMatchButton />*/}
      <MatchListTable initialData={props.data} />
    </div>
  );
});
