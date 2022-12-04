import { RequestDescriptor } from "../RequestDescriptor";

const getMatchStatistics = ({ matchId }: { matchId: number }): RequestDescriptor => ({
  url: `/statistics/matches/${matchId}`,
});

const getTournamentStatistics = ({ tournamentId }: { tournamentId: number }): RequestDescriptor => ({
  url: `/statistics/tournaments/${tournamentId}`,
});

const getPlayerStatistics = ({ playerId }: { playerId?: number }): RequestDescriptor => {
  const request = { url: "/statistics/players" };

  if (playerId) request.url += `/${playerId.toString()}`;

  return request;
};

export default {
  getMatchStatistics,
  getPlayerStatistics,
  getTournamentStatistics,
};
