package com.novel.ai.service;

import java.util.Map;

public interface AiService {

    /**
     * 前期构思：根据题材和核心冲突生成人物卡、世界观设定等
     * @param genre 题材（古言/无限流/现言等）
     * @param conflict 核心冲突
     * @return 生成的人设和世界观文案
     */
    Map<String, Object> brainstorm(String genre, String conflict);

    /**
     * 正文续写：根据前文续写下一段内容
     * @param context 前文内容
     * @param style 写作风格提示（可选）
     * @return 续写内容
     */
    Map<String, Object> continueWriting(String context, String style);

    /**
     * 从构思生成章节正文：输入构思的 markdown 内容，AI 输出纯文本小说正文 + 标题
     * @param brainstormRaw 构思的原始 markdown 内容
     * @return { title: "...", content: "..." }
     */
    Map<String, Object> generateChapter(String brainstormRaw);

    /**
     * 从构思生成多个连续章节：输入构思内容和历史上下文，AI 输出多个连贯章节
     * @param brainstormRaw 当前构思的原始 markdown 内容
     * @param historyContext 历史构思上下文（可选，用于连贯性）
     * @param chapterCount 要生成的章节数（默认3）
     * @return { chapters: [{title, content}, ...] }
     */
    Map<String, Object> generateChapters(String brainstormRaw, String historyContext, int chapterCount);
}
