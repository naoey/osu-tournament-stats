export default class RequestError extends Error {
  public readonly status: number;
  public readonly message: string;
  public readonly code: string;

  constructor(message: string, status: number = 0, code: string = null) {
    super();

    this.message = message;
    this.status = status;
    this.code = code;
  }
}
