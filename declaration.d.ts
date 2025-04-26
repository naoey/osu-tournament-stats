import { Player } from "./app/frontend/models/Player";

declare global {
  interface Window {
    currentUser: Player;
  }
}

declare module "*.scss" {
  const content: Record<string, string>;
  export default content;
}
