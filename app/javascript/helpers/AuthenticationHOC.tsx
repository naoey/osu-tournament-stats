import { ReactComponentLike } from "prop-types";
import * as React from "react";
import { IUser } from "../entities/IUser";

export function authenticated<P extends object>(Component: React.ComponentType<P>, predicate: (user: IUser) => boolean = null) {
  return (props: P) => {
    const currentUser = (window as any).currentUser;

    if (currentUser) {
      if ((typeof predicate === "function" && predicate(currentUser)) || typeof predicate !== "function") {
        return <Component {...props} />;
      }
    }

    return null;
  };
}
