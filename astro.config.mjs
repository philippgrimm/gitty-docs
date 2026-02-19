import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://philippgrimm.github.io',
  base: '/gitty-docs/',
  output: 'static',
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [
    starlight({
      title: 'Gitty Docs',
      customCss: ['./src/styles/global.css'],
      head: [
        {
          tag: 'link',
          attrs: {
            rel: 'stylesheet',
            href: 'https://fonts.bunny.net/css?family=instrument-sans:400,500,600|jetbrains-mono:400,500,600|pixelify-sans:400,500,600,700|press-start-2p:400',
          },
        },
        // Primary favicon — SVG (Chrome 80+, Firefox 41+, Safari 12+)
        {
          tag: 'link',
          attrs: { rel: 'icon', href: '/gitty-docs/favicon.svg', type: 'image/svg+xml' },
        },
        // ICO fallback for older browsers / OS taskbars
        {
          tag: 'link',
          attrs: { rel: 'icon', href: '/gitty-docs/favicon.ico', sizes: '32x32', type: 'image/x-icon' },
        },
        // iOS home screen icon (180×180 PNG; SVG source at public/apple-touch-icon.svg)
        {
          tag: 'link',
          attrs: { rel: 'apple-touch-icon', href: '/gitty-docs/apple-touch-icon.png' },
        },
        {
          tag: 'meta',
          attrs: { name: 'theme-color', content: '#F2EFE9' },
        },
      ],
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/philippgrimm/gitty',
        },
      ],
      sidebar: [
        { label: 'Getting Started', slug: 'getting-started' },
        { label: 'Staging & Committing', slug: 'staging-and-committing' },
        { label: 'Branching & Merging', slug: 'branching-and-merging' },
        { label: 'Syncing with Remotes', slug: 'syncing-with-remotes' },
        { label: 'Advanced Features', slug: 'advanced-features' },
      ],
    }),
  ],
});
