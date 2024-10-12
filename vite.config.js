import { defineConfig } from 'vite'
import elmPlugin from 'vite-plugin-elm'

export default defineConfig({
    plugins: [elmPlugin.plugin()],
    server: {
        proxy:{
            "/test": {
                target: 'http://localhost:3000/save',
                changeOrigin: true,
                secure: false,
            }
        }
    }
})