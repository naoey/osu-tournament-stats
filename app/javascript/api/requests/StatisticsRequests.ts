import { IRequest } from "../IRequest";

const getMatchStatistics = ({ matchId }): IRequest => ({
  url: `/statistics/matches/${matchId}`,
});

const getTournamentStatistics = ({ tournamentId }): IRequest => ({
  url: `/statistics/tournaments/${tournamentId}`,
});

const getPlayerStatistics = ({ playerId = null }): IRequest => {
  const request = { url: "/statistics/players" };

  if (playerId) request.url += `/${playerId.toString()}`;

  return request;
};

export default {
  getMatchStatistics,
  getPlayerStatistics,
  getTournamentStatistics,
};