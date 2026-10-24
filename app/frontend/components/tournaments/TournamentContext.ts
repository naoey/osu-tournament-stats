import React from "react";

import { Tournament } from "../../entities/Tournament";

// @ts-expect-error
const TournamentContext = React.createContext<Tournament>(null);

export default TournamentContext;
