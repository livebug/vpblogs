import { defineConfig } from 'vitepress'
import { withSidebar } from 'vitepress-sidebar';
import { VitePressSidebarOptions } from 'vitepress-sidebar/types';

const vitePressOptions = {
  // VitePress's options here...
  base: '/vpblogs/',
  title: "Livebug's Space",
  description: "学习、心得、记录、随笔",
  lastUpdated: true,
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'About', link: '/examples/' },
      { text: 'Tags', link: '/note/tags' }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/livebug' }
    ],
    outline: {
      level:[2,4]
    }
    ,commitRepoUrl: 'https://github.com/livebug/vpblogs/',
  },
};

function f1() {
  // 每个文章主题的页面
  let res: VitePressSidebarOptions[] = [];
  let menus = ['learn', 'note', 'think', 'write']
  for (const v in menus) {
    let name = menus[v]
    let subMenu: VitePressSidebarOptions = {
      documentRootPath: 'docs',
      scanStartPath: `${name}`,
      basePath: `/${name}/`,
      resolvePath: `/${name}/`,
      sortMenusByFileDatePrefix: true,
      sortMenusOrderByDescending: true,

      collapsed: false,
      capitalizeFirst: true,
      // ============ [ GETTING MENU TITLE ] ============
      useTitleFromFileHeading: true,
      useTitleFromFrontmatter: true,
      useFolderLinkFromIndexFile: true,
      useFolderTitleFromIndexFile: true,
      frontmatterTitleFieldName: 'title',
      // ============ [ GETTING MENU LINK ] ============
      // useFolderLinkFromSameNameSubFile: true,
      // folderLinkNotIncludesFileName: true,
      excludeFilesByFrontmatterFieldName: 'exclude'
    }
    res.push(subMenu)
  }
  return res;
}

const vitePressSidebarOptions_: VitePressSidebarOptions[] = [...f1(),
{
  // 全部的展示页面 
  // VitePress Sidebar's options here...
  documentRootPath: 'docs',
  resolvePath: `/`,
  collapsed: false,
  capitalizeFirst: true,
  // ============ [ GETTING MENU TITLE ] ============
  useTitleFromFileHeading: true,
  useTitleFromFrontmatter: true,
  useFolderLinkFromIndexFile: true,
  useFolderTitleFromIndexFile: true,
  frontmatterTitleFieldName: 'title',
  // ============ [ GETTING MENU LINK ] ============
  // useFolderLinkFromSameNameSubFile: true,
  // folderLinkNotIncludesFileName: true,
  excludeFilesByFrontmatterFieldName: 'exclude'
}
];

// https://vitepress.dev/reference/site-config
export default defineConfig(withSidebar(vitePressOptions, vitePressSidebarOptions_))
