const getServers = () => ({
  url: '/discord/servers',
});

const getExpLeaderboard = ({ serverId, page = 1, limit = 50 }: { serverId: number, page?: number, limit?: number }) => ({
  url: `/discord/servers/${serverId}/exp?page=${page}&limit=${limit}`,
});

export default {
  getServers,
  getExpLeaderboard,
}
