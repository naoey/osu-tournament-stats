import { IRequest } from "../IRequest";

const getMatchStatistics = ({ matchId }): IRequest => ({
  url: `/statistics/match/${matchId}`,
});

const getTournamentStatistics = ({ tournamentId }): IRequest => ({
  url: `/statistics/tournament/${tournamentId}`,
});

const getPlayerStatistics = ({ playerId = null }): IRequest => {
  const request = { url: "/statistics/player" };

  if (playerId) request.url += playerId.toString();

  return request;
};

export default {
  getMatchStatistics,
  getPlayerStatistics,
  getTournamentStatistics,
};