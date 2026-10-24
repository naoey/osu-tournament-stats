import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig({
  server: {
    host: "0.0.0.0",
    allowedHosts: true,
    watch: {
      usePolling: true,
    },
  },
  plugins: [
    react({ babel: { parserOpts: { plugins: ["decorators-legacy"] } } }),
    RubyPlugin(),
    // checker({ typescript: true }),
  ],
});
