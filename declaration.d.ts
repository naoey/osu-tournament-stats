import { User } from "./app/assets/javascripts/models/User";

declare global {
  interface Window { currentUser: User }
}

declare module '*.scss' {
  const content: Record<string, string>;
  export default content;
}
