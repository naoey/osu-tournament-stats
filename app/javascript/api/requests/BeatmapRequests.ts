const getBeatmaps = ({ ids }: { ids: number[] }) => ({
  url: `/beatmaps?${$.param({ ids })}`
});

export default {
  getBeatmaps,
}
