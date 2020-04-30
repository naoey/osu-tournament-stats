const getBeatmaps = ({ ids }: { ids: number[] }) => ({
  url: `/beatmaps?${ids.map(i => `ids[]=${i}`).join('&')}`
});

export default {
  getBeatmaps,
}
