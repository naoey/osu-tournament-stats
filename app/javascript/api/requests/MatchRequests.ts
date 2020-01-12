import { HttpMethod } from "../Constants";
import { IRequest } from "../IRequest";

const createMatch = ({
  roundName,
  matchId,
  referees,
  redCaptain,
  blueCaptain,
  discardList,
  tournamentId = null,
}): IRequest => ({
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

const getMatches = (params = {}): IRequest => ({
  url: `/matches?${$.param(params)}`,
});

export default {
  createMatch,
  getMatches,
};
