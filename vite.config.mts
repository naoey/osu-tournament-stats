import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  server: {
    host: '0.0.0.0',
  },
  plugins: [
    RubyPlugin(),
  ],
})
