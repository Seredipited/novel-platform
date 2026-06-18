package com.novel.chapter.controller;

import com.novel.chapter.entity.Chapter;
import com.novel.chapter.service.ChapterService;
import com.novel.common.result.Result;
import com.novel.common.util.JwtUtil;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/chapter")
public class ChapterController {

    @Resource
    private ChapterService chapterService;

    @GetMapping("/list/{novelId}")
    public Result<List<Chapter>> list(@PathVariable Long novelId) {
        return Result.success(chapterService.getChaptersByNovelId(novelId));
    }

    @GetMapping("/detail/{id}")
    public Result<Chapter> detail(@PathVariable Long id) {
        return Result.success(chapterService.getChapterDetail(id));
    }

    @PostMapping("/add")
    public Result<Long> add(@RequestHeader("Authorization") String auth,
                            @RequestBody Chapter chapter) {
        String token = auth.replace("Bearer ", "");
        JwtUtil.getUserId(token); // 验证登录
        return Result.success(chapterService.addChapter(chapter));
    }

    @PutMapping("/update")
    public Result<?> update(@RequestHeader("Authorization") String auth,
                            @RequestBody Chapter chapter) {
        String token = auth.replace("Bearer ", "");
        JwtUtil.getUserId(token); // 验证登录
        chapterService.updateChapter(chapter);
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result<?> delete(@RequestHeader("Authorization") String auth,
                            @PathVariable Long id) {
        String token = auth.replace("Bearer ", "");
        JwtUtil.getUserId(token); // 验证登录
        chapterService.deleteChapter(id);
        return Result.success();
    }
}
