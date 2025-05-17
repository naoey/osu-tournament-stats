import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import react from "@vitejs/plugin-react";
import checker from "vite-plugin-checker";

export default defineConfig(({ mode }) => ({
  esbuild: {
    drop: mode === "production" ? ["console", "debugger"] : undefined,
  },
  server: {
    host: "0.0.0.0",
    allowedHosts: true,
    watch: {
      usePolling: true
    }
  },
  plugins: [
    react({ babel: { parserOpts: { plugins: ["decorators-legacy"] } } }),
    RubyPlugin()
    // checker({ typescript: true }),
  ]
}));
