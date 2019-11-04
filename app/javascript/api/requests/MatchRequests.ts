import { HttpMethod } from "../Constants";
import { IRequest } from "../IRequest";

const createMatch = ({ name, onlineId }): IRequest => ({
  options: {
    method: HttpMethod.Post,
  },
  payload: {
    name,
    online_id: onlineId,
  },
  url: "/tournaments",
});

const getMatches = (params = {}): IRequest => ({
  url: `/matches?${$.param(params)}`,
});

export default {
  createMatch,
  getMatches,
};
