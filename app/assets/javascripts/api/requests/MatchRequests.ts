import { HttpMethod } from "../Constants";
import { RequestDescriptor } from "../RequestDescriptor";

const createMatch = ({
  roundName,
  matchId,
  referees,
  redCaptain,
  blueCaptain,
  discardList,
  tournamentId = null,
}: any): RequestDescriptor => ({
  options: {
    method: HttpMethod.Post,
  },
  payload: {
    blue_captain: blueCaptain,
    discard_list: discardList,
    osu_match_id: matchId,
    red_captain: redCaptain,
    referees,
    round_name: roundName,
    tournament_id: tournamentId,
  },
  url: "/matches",
});

const getMatches = (params = {}): RequestDescriptor => ({
  url: `/matches?${$.param(params)}`,
});

export default {
  createMatch,
  getMatches,
};
