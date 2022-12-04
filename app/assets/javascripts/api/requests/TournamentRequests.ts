import { HttpMethod } from "../Constants";
import { RequestDescriptor } from "../RequestDescriptor";

const createTournament = ({ name, startDate, endDate }: { name: string, startDate: string, endDate: string }): RequestDescriptor => ({
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

const getTournaments = ({ name = null }: { name?: string | null | undefined } = {}): RequestDescriptor => ({
  url: `/tournaments${name ? `?name=${name}` : ""}`,
});

const getTournament = ({ id, round_name = '' }: { id?: number, round_name?: string }): RequestDescriptor => ({
  url: `/tournaments/${id}?round_name=${round_name}`
})

export default {
  createTournament,
  getTournaments,
  getTournament,
};
