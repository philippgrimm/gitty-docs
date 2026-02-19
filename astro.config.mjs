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
        {
          label: 'Documentation',
          autogenerate: { directory: '.' },
        },
      ],
    }),
  ],
});
