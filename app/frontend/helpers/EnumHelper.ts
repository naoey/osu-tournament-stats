import { EnumDeclaration } from "@babel/types";
import { PreferredColourScheme } from "../models/Player";

export default {
  getReadablePairs<T extends Record<string, number | string>>(e: T) {
    return Object.entries(e).filter(([k]) => isNaN(Number(k)));
}
}
