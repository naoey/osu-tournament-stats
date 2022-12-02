import { ContentType, HttpStatus } from "./Constants";
import { RequestDescriptor } from "./RequestDescriptor";
import RequestError from "./RequestError";
import { UserEvents } from "../events/UserEvents";

export default class Api {
  public static async performRequest<P>({ url, payload, options }: RequestDescriptor): Promise<P> {
    const headers = {
      ...(options && options.headers) || {},
      "Accept": ContentType.Json,
      "Content-Type": ContentType.Json,
    };

    let body: string | null = null;

    if (payload !== null) {
      body = JSON.stringify(payload);
    }

    return this.performRequestInternal<P>(url, body, { ...options, headers });
  }

  private static async performRequestInternal<P>(url: string, body: any, options: RequestInit): Promise<P> {
    // TODO: set up the request here first with auth headers and whatnot

    const opts: RequestInit = {
      ...options || {},
      credentials: "same-origin",
      mode: "same-origin",
    };

    if (body !== null) {
      opts.body = body;
    }

    try {
      const response = await fetch(url, opts);

      const json = this.tryGetJson(await response.text());

      if (response.status === HttpStatus.Unauthorised) {
        $(document).trigger(UserEvents.SessionExpired);
        throw new RequestError(json.error, response.status);
      }

      if (response.status >= 400) {
        console.log('Response status greater than 400, json is', json);
        throw new RequestError(json?.error ?? "An error occurred!", response.status, (json && json.code) || null);
      }

      if (response.status >= 300) {
        throw new RequestError("Request resulted in a redirect!", response.status);
      }

      console.debug(`Request to ${url} succcessfully completed!`);

      return json;
    } catch (e: any) {
      console.error(`Request to ${url} failed!`, e.code, e.status);

      if (e.code === "AbortError") {
        throw new RequestError("Request cancelled!", 0, 'E_REQUEST_CANCELLED');
      }

      throw e;
    }
  }

  private static tryGetJson(text: string): any {
    try {
      return JSON.parse(text);
    } catch {
      return null;
    }
  }
}
