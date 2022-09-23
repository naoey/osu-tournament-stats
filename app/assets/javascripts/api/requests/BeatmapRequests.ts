import { RequestDescriptor } from "../RequestDescriptor";

const getBeatmaps = ({ ids }: { ids: number[] }): RequestDescriptor => ({
  url: `/beatmaps?${ids.map(i => `ids[]=${i}`).join('&')}`
});

export default {
  getBeatmaps,
}
