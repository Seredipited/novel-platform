package com.novel.ai.controller;

import com.novel.ai.service.AiService;
import com.novel.common.result.Result;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Map;

@RestController
@RequestMapping("/ai")
public class AiController {

    @Resource
    private AiService aiService;

    /**
     * 前期构思：输入题材和核心冲突，生成人物卡 + 世界观
     */
    @PostMapping("/brainstorm")
    public Result<Map<String, Object>> brainstorm(@RequestBody Map<String, String> body) {
        String genre = body.getOrDefault("genre", "古言");
        String conflict = body.getOrDefault("conflict", "");
        return Result.success(aiService.brainstorm(genre, conflict));
    }

    /**
     * 正文续写：输入前文，AI续写下一段
     */
    @PostMapping("/continue")
    public Result<Map<String, Object>> continueWriting(@RequestBody Map<String, String> body) {
        String context = body.getOrDefault("context", "");
        String style = body.getOrDefault("style", null);
        return Result.success(aiService.continueWriting(context, style));
    }

    /**
     * 构思→正文：输入构思 markdown 内容，生成纯文本小说章节标题+正文
     */
    @PostMapping("/generate-chapter")
    public Result<Map<String, Object>> generateChapter(@RequestBody Map<String, String> body) {
        String brainstormRaw = body.getOrDefault("brainstormRaw", "");
        return Result.success(aiService.generateChapter(brainstormRaw));
    }

    /**
     * 构思→多章节：输入构思 + 历史上下文，生成多个连贯的纯文本小说章节
     */
    @PostMapping("/generate-chapters")
    public Result<Map<String, Object>> generateChapters(@RequestBody Map<String, Object> body) {
        String brainstormRaw = (String) body.getOrDefault("brainstormRaw", "");
        String historyContext = (String) body.getOrDefault("historyContext", "");
        int chapterCount = body.containsKey("chapterCount")
                ? ((Number) body.get("chapterCount")).intValue()
                : 3;
        return Result.success(aiService.generateChapters(brainstormRaw, historyContext, chapterCount));
    }
}
