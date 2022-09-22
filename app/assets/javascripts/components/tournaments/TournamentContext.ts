import React from "react";
import Tournament from "../../entities/Tournament";

const TournamentContext = React.createContext<Tournament>(null);

export default TournamentContext;
