// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Success Notes',
  staticDirectories: ['public', 'static'],
  tagline: 'Success Notes',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://your-docusaurus-site.example.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  //organizationName: 'facebook', // Usually your GitHub org/user name.
  //projectName: 'docusaurus', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',              
        // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
        //  editUrl:
        //    'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
        //  editUrl:
        //    'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      navbar: {
        title: 'Success Notes',
        logo: {
          alt: 'Success Notes',
          src: 'img/logo.svg',
        },

        items: [
       //   {
       //     type: 'docSidebar',
       //     sidebarId: 'tutorialSidebar',
       //     position: 'left',
       //     label: 'Tutorial',
       //   },
       {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Success', // foldername
            label: 'Success',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Success_Pillars', // foldername
            label: 'Success_Pillars',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Lifestyle', // foldername
            label: 'Lifestyle',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Health', // foldername
            label: 'Health',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Finance', // foldername
            label: 'Finance',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Studies', // foldername
            label: 'Studies',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Career', // foldername
            label: 'Career',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Language', // foldername
            label: 'Language',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'mgmt', // foldername
            label: 'Mgmt',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'left',
            sidebarId: 'Success_Temp', // foldername
            label: 'Success_Temp',     // navbar title
          },
          {
            type: 'docSidebar',  // docSidebar
            position: 'right',
            sidebarId: 'temp', // foldername
            label: 'temp',     // navbar title
          },
          
        
     //     {to: '/blog', label: 'Blog', position: 'left'},
     //     {
     //       href: 'https://github.com/facebook/docusaurus',
      //      label: 'GitHub',
      //      position: 'right',
      //    },
        ],
      },
      footer: {
        style: 'dark',
        links: [
        
        //  {
        //    title: 'Docs',
        //    items: [
        //      {
        //        label: 'Tutorial',
        //        to: '/docs/intro',
        //      },
        //    ],
        //  },
        
        
          // {
         //   title: 'Community',
         //   items: [
         //     {
         //       label: 'Stack Overflow',
         //       href: 'https://stackoverflow.com/questions/tagged/docusaurus',
         //     },
         //     {
         //       label: 'Discord',
         //       href: 'https://discordapp.com/invite/docusaurus',
         //     },
         //     {
         //       label: 'Twitter',
         //       href: 'https://twitter.com/docusaurus',
         //     },
         //   ],
         // },
        //  {
        //    title: 'More',
        //    items: [
        //      {
        //        label: 'Blog',
        //        to: '/blog',
        //      },
        //      {
        //        label: 'GitHub',
        //        href: 'https://github.com/facebook/docusaurus',
        //      },
        //    ],
        //  },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Success Notes. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;
