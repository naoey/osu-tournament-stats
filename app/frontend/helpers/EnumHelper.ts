export default {
  getReadablePairs(e) {
    return Object.entries(e).filter(([k]) => isNaN(k));
}
}
