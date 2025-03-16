import { User } from "./app/frontend/models/User";

declare global {
  interface Window {
    currentUser: User;
  }
}

declare module "*.scss" {
  const content: Record<string, string>;
  export default content;
}
