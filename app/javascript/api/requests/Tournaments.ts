import { HttpMethod } from "../Constants";
import { IRequest } from "../IRequest";

const createTournament = ({ name, startDate, endDate }): IRequest => ({
  options: {
    method: HttpMethod.Post,
  },
  payload: {
    end_date: endDate,
    name,
    start_date: startDate,
  },
  url: "/tournaments",
});

const getTournaments = (): IRequest => ({
  url: "/tournaments",
});

export default {
  createTournament,
  getTournaments,
};
