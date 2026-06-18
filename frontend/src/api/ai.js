import request from "../utils/request";

// AI 接口响应较慢，需要更长的超时时间
const aiRequest = (config) => request({ ...config, timeout: 120000 });

/**
 * 前期构思：输入题材 + 核心冲突，AI 生成人物卡、世界观、故事线
 */
export function aiBrainstorm(data) {
  return aiRequest({ method: "post", url: "/ai/brainstorm", data });
}

/**
 * 正文续写：输入前文，AI 续写下一段
 */
export function aiContinue(data) {
  return aiRequest({ method: "post", url: "/ai/continue", data });
}

/**
 * 构思→正文：输入构思 markdown 内容，AI 生成纯文本小说章节（标题+正文）
 */
export function aiGenerateChapter(data) {
  return aiRequest({ method: "post", url: "/ai/generate-chapter", data });
}

/**
 * 构思→多章节：输入构思 + 历史上下文，AI 生成多个连贯的纯文本小说章节
 * @param {Object} data - { brainstormRaw, historyContext, chapterCount }
 * @returns {Promise} - { chapters: [{title, content}, ...] }
 */
export function aiGenerateChapters(data) {
  return aiRequest({ method: "post", url: "/ai/generate-chapters", data });
}
