import * as React from "react";
import { ReactComponentLike } from "prop-types";

export function authenticated(props: any) {
  return function (Component: ReactComponentLike): React.ReactNode {
    if ((window as any)._currentUser) {
      return <Component {...props} />;
    }

    return null;
  }
}
