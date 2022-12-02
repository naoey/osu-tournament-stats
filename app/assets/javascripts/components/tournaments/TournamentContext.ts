import React from "react";
import { Tournament } from "../../entities/Tournament";

// @ts-ignore
const TournamentContext = React.createContext<Tournament>(null);

export default TournamentContext;
