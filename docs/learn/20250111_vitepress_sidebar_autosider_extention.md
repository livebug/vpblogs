---
title: VitePress 动态侧边栏插件
tags:
  - VitePress
---
# VitePress Sidebar 动态侧边栏插件

文档地址 [VitePress Sidebar ](https://vitepress-sidebar.cdget.com/)

## 安装
```shell
# via pnpm
$ pnpm i -D vitepress-sidebar
```
## 使用说明

### 基本使用
```javascript
const vitePressOptions = {
  // VitePress's options here...
  title: "Livebug's Space",
  description: "学习、心得、记录、随笔",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
  }
}; 
const vitePressSidebarOptions_: VitePressSidebarOptions[] = [ 
  {
    // VitePress Sidebar's options here...
    documentRootPath: 'docs',
    resolvePath: `/`,
  }
];

// https://vitepress.dev/reference/site-config
export default defineConfig(withSidebar(vitePressOptions, vitePressSidebarOptions_))
```

### 目录名称和文章名称
```
      useTitleFromFileHeading: true, 
      useTitleFromFrontmatter: true,
      useFolderTitleFromIndexFile: true,
      frontmatterTitleFieldName: 'title',
```
`frontmatterTitleFieldName` 指定文章在菜单中的名称配置，配置为 `title` ，就会从这个配置取数，默认其实就是 `title` ；和 `useTitleFromFrontmatter` 配合使用，为 `true` 时就会启用。
```markdown
---
title: [该名称展示在侧边栏中]
---
```

`useFolderTitleFromIndexFile` 菜单名称读取目录名，如果这个设置为 `true` ，则读取目录 `index.md` 文件下的配置项，默认也是取 `frontmatterTitleFieldName` 。
 


## 案例介绍：本博客的配置
```javascript
const vitePressOptions = {
  // VitePress's options here...
  // 这里就是普通的配置，比如sidebar即便写了也会被自动生成处理掉
  title: "Livebug's Space",
  description: "学习、心得、记录、随笔",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'About', link: '/examples/' }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/livebug' }
    ]
  }
};

/**
 * 因为四个主题，所以做了一个四个主题分页的和总的
 * 其实配置一样
 */
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

```