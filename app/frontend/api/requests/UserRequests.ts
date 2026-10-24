import { IdentityProvider, UiConfig } from "../../models/Player";
import { HttpMethod } from "../Constants";
import { RequestDescriptor } from "../RequestDescriptor";

export const get = (id) => ({ url: `/users/${id}` });

export const deleteIdentity = ({ provider }: { provider: IdentityProvider }): RequestDescriptor => ({
  url: "/users/me/connection",
  options: { method: HttpMethod.Delete },
  payload: { provider },
});

export const updateUiConfig = ({ config }: { config: UiConfig }): RequestDescriptor => ({
  url: "/users/me/ui_config",
  options: { method: HttpMethod.Put },
  payload: config,
});
