import { Identity, IdentityProvider } from "../../models/Player";
import { RequestDescriptor } from "../RequestDescriptor";
import { HttpMethod } from "../Constants";
export const deleteIdentity = ({ provider }: { provider: IdentityProvider }): RequestDescriptor => ({
  url: "/users/me/connection",
  options: { method: HttpMethod.Delete },
  payload: { provider },
});
