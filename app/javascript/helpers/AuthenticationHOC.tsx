import { ReactComponentLike } from "prop-types";
import * as React from "react";

export function authenticated<P extends object>(Component: React.ComponentType<P>) {
  return (props: P) => {
    if ((window as any)._currentUser) {
      return <Component {...props} />;
    }

    return null;
  };
}
