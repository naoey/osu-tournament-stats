export default {
  getCsrfToken(): string | null {
    return $('meta[name="csrf-token"]').attr('content') ?? null;
  }
}
