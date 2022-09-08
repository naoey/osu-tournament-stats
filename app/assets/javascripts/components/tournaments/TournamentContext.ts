import React from "react";
import ITournament from "../../entities/ITournament";

const TournamentContext = React.createContext<ITournament>(null);

export default TournamentContext;
