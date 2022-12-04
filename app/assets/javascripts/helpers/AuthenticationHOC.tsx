import * as React from "react";
import { User } from "../entities/User";

interface IAuthenticatedComponent {
  /**
   * An optional function to perform additional checks over basic authentication to determine whether the wrapped component
   * should be rendered.
   */
  checkAllowed?: (user: User) => boolean;
}

export function authenticated<P extends object>(Component: React.ComponentType<P>) {
  return (props: P & IAuthenticatedComponent) => {
    const { checkAllowed: predicate, ...rest } = props;

    const currentUser = (window as any).currentUser;

    if (!currentUser) return null;

    // We need to render the component if:
    //  - a predicate is given and the predicate returns true for the current user
    //  - there is no predicate given at all in which case the presence of a user object is permission to render it
    if ((typeof predicate === "function" && predicate(currentUser)) || typeof predicate !== "function")
      return <Component {...(rest as P)} />;

    return null;
  };
}
