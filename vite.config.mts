import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import react from '@vitejs/plugin-react';

export default defineConfig({
  server: {
    host: '0.0.0.0',
    allowedHosts: true,
    watch: {
      usePolling: true,
    },
  },
  plugins: [
    react(),
    RubyPlugin(),
  ],
})
