package com.novel.ai.service.impl;

import com.alibaba.dashscope.aigc.generation.Generation;
import com.alibaba.dashscope.aigc.generation.GenerationParam;
import com.alibaba.dashscope.aigc.generation.GenerationResult;
import com.alibaba.dashscope.common.Message;
import com.alibaba.dashscope.common.Role;
import com.alibaba.dashscope.exception.ApiException;
import com.alibaba.dashscope.exception.InputRequiredException;
import com.alibaba.dashscope.exception.NoApiKeyException;
import com.alibaba.dashscope.utils.JsonUtils;
import com.novel.ai.service.AiService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
public class AiServiceImpl implements AiService {

    @Value("${ai.dashscope.api-key}")
    private String apiKey;

    @Value("${ai.dashscope.model:qwen-flash}")
    private String model;

    // ========== 前期构思 Prompt ==========
    private static final String BRAINSTORM_SYSTEM_PROMPT =
        "你是一名资深小说家，擅长世界观构建和人物设计。" +
        "请根据用户提供的题材和核心冲突，输出一份完整的小说构思方案。\n\n" +
        "要求输出以下内容（用 Markdown 格式，分隔清晰）：\n" +
        "## 一、世界观设定\n" +
        "- 时代背景（年代/地域/社会形态）\n" +
        "- 势力格局（有哪些主要势力、组织、门派）\n" +
        "- 修炼/力量体系（如适用，说明等级划分和晋升规则）\n" +
        "- 世界地图概要（核心场景、特色地点）\n\n" +
        "## 二、主角人物卡\n" +
        "- 姓名 / 年龄 / 外貌\n" +
        "- 性格特征（3个核心特质 + 优缺点）\n" +
        "- 背景故事（成长经历、核心创伤或动力来源）\n" +
        "- 能力/金手指（如有特殊能力）\n" +
        "- 动机与目标\n\n" +
        "## 三、关键配角（2-3个）\n" +
        "- 姓名 / 与主角关系 / 性格 / 作用\n\n" +
        "## 四、故事主线\n" +
        "- 开篇钩子（一句话引爆剧情）\n" +
        "- 三幕式结构（起、承、转）\n" +
        "- 预期高潮与结局方向\n\n" +
        "请确保内容有新意、有网感、符合当前网文市场趋势。每部分不少于150字。";

    // ========== 正文续写 Prompt ==========
    private static final String CONTINUE_SYSTEM_PROMPT =
        "你是一名资深小说家，擅长根据已有内容进行高质量续写。" +
        "请根据用户提供的前文内容，用自己的写作风格续写下一段。" +
        "要求：\n" +
        "1. 保持前文的文风、人称和叙事节奏\n" +
        "2. 自然过渡，人物性格不崩坏\n" +
        "3. 内容要有推动剧情的实质性进展（不要水字数）\n" +
        "4. 续写字数在 300-800 字之间\n" +
        "5. 以一段完整的剧情或对话结束，留有悬念感\n" +
        "6. 直接输出续写正文，不要加任何前缀说明";

    // ========== 构思 → 正文 Prompt ==========
    private static final String GENERATE_CHAPTER_PROMPT =
        "你是一名资深小说家，擅长根据设定集创作开篇章节。" +
        "请根据用户提供的小说构思内容（包含世界观、人物卡、故事主线等），创作小说的第一章正文。\n\n" +
        "要求：\n" +
        "1. 第一行必须是章节标题（纯文本，不要带\"标题：\"等前缀，不要带#号，不要带**等markdown标记），标题要有吸引力\n" +
        "2. 空一行后再输出正文内容\n" +
        "3. 正文必须是纯文本小说内容：场景描写+人物对话+叙事，不要任何 Markdown 格式（不要**、##、-等标记）\n" +
        "4. 正文字数 800-1500 字\n" +
        "5. 开篇要有强烈的钩子吸引读者\n" +
        "6. 文风要符合构思中设定的题材和时代背景\n" +
        "7. 第一章结束时留有悬念";

    // ========== 构思 → 多章节 Prompt ==========
    private static final String GENERATE_CHAPTERS_PROMPT =
        "你是一名资深小说家，擅长根据设定集创作连贯的多章节小说。" +
        "请根据用户提供的小说构思内容（包含世界观、人物卡、故事主线等），连续创作小说的前几个章节。\n\n" +
        "要求：\n" +
        "1. 必须严格按照以下格式输出多个章节，每个章节用【】包裹标题作为分隔：\n" +
        "【第1章 标题内容】\n" +
        "正文内容（纯文本，场景描写+人物对话+叙事）...\n\n" +
        "【第2章 标题内容】\n" +
        "正文内容...\n\n" +
        "【第3章 标题内容】\n" +
        "正文内容...\n\n" +
        "2. 每个章节标题用【】包裹，标题中不要出现#、**等markdown格式符号，标题要有吸引力且各不相同\n" +
        "3. 正文必须是纯文本小说内容，不要任何 Markdown 格式（不要**##-等标记）\n" +
        "4. 每章正文 600-1200 字\n" +
        "5. 各章之间剧情必须连贯，前章的悬念在下一章得到推进\n" +
        "6. 开篇要有强烈的钩子吸引读者\n" +
        "7. 文风要符合构思中设定的题材和时代背景\n" +
        "8. 如果提供了历史构思上下文，请确保章节内容与历史设定保持一致不矛盾";

    @Override
    public Map<String, Object> brainstorm(String genre, String conflict) {
        String userPrompt = "题材：" + genre + "\n核心冲突：" + conflict;
        String result = callQwen(BRAINSTORM_SYSTEM_PROMPT, userPrompt);
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("raw", result);
        map.put("parsed", parseBrainstormResult(result));
        return map;
    }

    @Override
    public Map<String, Object> continueWriting(String context, String style) {
        String userPrompt = "前文内容：\n" + context;
        if (style != null && !style.isEmpty()) {
            userPrompt += "\n\n风格要求：" + style;
        }
        String result = callQwen(CONTINUE_SYSTEM_PROMPT, userPrompt);
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("content", result.trim());
        return map;
    }

    @Override
    public Map<String, Object> generateChapter(String brainstormRaw) {
        String userPrompt = "以下是小说构思内容，请据此创作小说第一章：\n\n" + brainstormRaw;
        String result = callQwen(GENERATE_CHAPTER_PROMPT, userPrompt, 2000);

        // 第一行为标题，之后为空行+正文
        String[] lines = result.split("\n", 2);
        String title = stripMarkdown(lines[0].trim());
        String content = lines.length > 1 ? lines[1].trim() : "";

        if (title.isEmpty()) {
            title = "第1章";
        }

        Map<String, Object> map = new LinkedHashMap<>();
        map.put("title", title);
        map.put("content", content);
        return map;
    }

    @Override
    public Map<String, Object> generateChapters(String brainstormRaw, String historyContext, int chapterCount) {
        if (chapterCount < 1) chapterCount = 3;
        if (chapterCount > 5) chapterCount = 5; // 限制最多5章

        StringBuilder userPrompt = new StringBuilder();
        userPrompt.append("以下是小说构思内容，请据此连续创作").append(chapterCount).append("个章节：\n\n");
        userPrompt.append(brainstormRaw);

        // 如果有历史构思上下文，附加上去确保连贯性
        if (historyContext != null && !historyContext.isEmpty()) {
            userPrompt.append("\n\n---\n\n【历史构思上下文，请确保新章节与以下历史设定保持一致】\n");
            userPrompt.append(historyContext);
        }

        // 多章节使用更大的 maxTokens
        int tokens = Math.max(4000, chapterCount * 1500);
        String result = callQwen(GENERATE_CHAPTERS_PROMPT, userPrompt.toString(), tokens);

        // 按 【第X章 标题】 分隔各章节
        List<Map<String, String>> chapters = new ArrayList<>();
        String[] parts = result.split("\\n(?=【第\\d+章)");
        for (String part : parts) {
            String trimmed = part.trim();
            if (trimmed.isEmpty()) continue;

            // 提取标题（第一行【...】中的内容）
            int titleEnd = trimmed.indexOf("\n");
            String titleLine, content;
            if (titleEnd > 0) {
                titleLine = trimmed.substring(0, titleEnd).trim();
                content = trimmed.substring(titleEnd + 1).trim();
            } else {
                titleLine = trimmed;
                content = "";
            }

            // 清理标题：去除【】包裹和 markdown
            String title = titleLine
                    .replaceFirst("^【", "")
                    .replaceFirst("】$", "");
            title = stripMarkdown(title);

            if (title.isEmpty()) continue;

            Map<String, String> chapter = new LinkedHashMap<>();
            chapter.put("title", title);
            chapter.put("content", content);
            chapters.add(chapter);
        }

        Map<String, Object> map = new LinkedHashMap<>();
        map.put("chapters", chapters);
        return map;
    }

    /**
     * 去除文本中的 Markdown 格式标记
     */
    private String stripMarkdown(String text) {
        if (text == null) return "";
        return text
                // 去除标题前缀
                .replaceAll("^(标题[：:]\\s*)", "")
                // 去除 # 标记
                .replaceAll("#+\\s*", "")
                // 去除粗体/斜体标记 ** __ * _
                .replaceAll("\\*\\*(.+?)\\*\\*", "$1")
                .replaceAll("__(.+?)__", "$1")
                .replaceAll("\\*(.+?)\\*", "$1")
                .replaceAll("_(.+?)_", "$1")
                // 去除多余空白
                .replaceAll("\\s+", " ")
                .trim();
    }

    // ========== 底层调用通义千问 ==========

    private String callQwen(String systemPrompt, String userPrompt) {
        return callQwen(systemPrompt, userPrompt, 2000);
    }

    private String callQwen(String systemPrompt, String userPrompt, int maxTokens) {
        try {
            Generation gen = new Generation();
            Message systemMsg = Message.builder()
                    .role(Role.SYSTEM.getValue())
                    .content(systemPrompt)
                    .build();
            Message userMsg = Message.builder()
                    .role(Role.USER.getValue())
                    .content(userPrompt)
                    .build();

            GenerationParam param = GenerationParam.builder()
                    .apiKey(apiKey)
                    .model(model)
                    .messages(Arrays.asList(systemMsg, userMsg))
                    .resultFormat(GenerationParam.ResultFormat.MESSAGE)
                    .topP(0.8)
                    .temperature(0.7F)
                    .maxTokens(maxTokens)
                    .build();

            GenerationResult result = gen.call(param);
            String content = result.getOutput().getChoices().get(0).getMessage().getContent();
            log.info("Qwen API 调用成功，返回字符数: {}", content.length());
            return content;
        } catch (NoApiKeyException e) {
            log.error("DashScope API Key 未配置", e);
            throw new RuntimeException("AI 服务未配置 API Key，请在 application.yml 中设置 ai.dashscope.api-key");
        } catch (ApiException | InputRequiredException e) {
            log.error("Qwen API 调用失败", e);
            throw new RuntimeException("AI 调用失败: " + e.getMessage());
        }
    }

    // ========== 解析构思结果为结构化数据 ==========

    private Map<String, Object> parseBrainstormResult(String raw) {
        Map<String, Object> parsed = new LinkedHashMap<>();
        String[] sections = raw.split("(?=## )");
        for (String section : sections) {
            String trimmed = section.trim();
            if (trimmed.startsWith("## 一、世界观设定")) {
                parsed.put("worldSetting", trimmed.replace("## 一、世界观设定", "").trim());
            } else if (trimmed.startsWith("## 二、主角人物卡")) {
                parsed.put("mainCharacter", trimmed.replace("## 二、主角人物卡", "").trim());
            } else if (trimmed.startsWith("## 三、关键配角")) {
                parsed.put("supportingCast", trimmed.replace("## 三、关键配角", "").trim());
            } else if (trimmed.startsWith("## 四、故事主线")) {
                parsed.put("storyOutline", trimmed.replace("## 四、故事主线", "").trim());
            }
        }
        return parsed;
    }
}
