// .vitepress/theme/utils/notes.data.ts
import { createContentLoader } from "vitepress";

// console.log("Script started"); // 确保脚本被执行

interface Post {  // ts定义数据类型
  title: string;
  url: string;
  tags: [];
  created: DateInfo;
  updated: DateInfo;
  dir: string;
}

interface DateInfo {  // ts定义数据类型
  time: number;
  string: string;
}

declare const data: Post[];
export { data };

export default createContentLoader(["../*/*/*.md","../*/*/*/*.md"], {// 扫描文件的目录
  transform(raw): Post[] {
    // console.log("Raw data:", raw); // 输出原始数据

    return raw
      .map(({ url, frontmatter }) => {
        if (!frontmatter) {
          // console.warn(`No frontmatter found for ${url}`); 
          return null; // 忽略没有 frontmatter 的文件  
        }

        const { title, created, updated } = frontmatter;

        // if (!title || !created || !updated) {
        //   // console.warn(`Incomplete frontmatter in ${url}:`, frontmatter);
        //   return null; // 忽略缺少必要字段的文件
        // }

        // console.log(frontmatter.tags)
        // console.log("frontmatter:", frontmatter); // 输出 frontmatter 的值
        const urlParts = url.split('/');

        return {
          title,
          url: '/vpblogs' + url,
          tags: frontmatter.tags || [],
          created: formatDate(created),
          updated: formatDate(updated),
          dir: `${urlParts[1]} / ${title}`,
        };
      })
      .filter((post): post is Post => post !== null && post.title !== null) // 过滤掉无效的条目
      // .sort((a, b) => b.updated.time - a.updated.time)
      ;
  },
});

function formatDate(raw: string): DateInfo {
  const date = new Date(raw);
  date.setUTCHours(12);
  return {
    time: +date,
    string: date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
  };
}