package com.novel.novel.controller;

import com.novel.common.result.PageResult;
import com.novel.common.result.Result;
import com.novel.common.util.JwtUtil;
import com.novel.novel.entity.Category;
import com.novel.novel.entity.Novel;
import com.novel.novel.service.CategoryService;
import com.novel.novel.service.NovelService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/novel")
public class NovelController {

    @Resource
    private NovelService novelService;
    @Resource
    private CategoryService categoryService;

    @GetMapping("/list")
    public Result<PageResult<Novel>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "12") Integer size,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "favorite") String sortBy) {
        return Result.success(novelService.getNovelList(page, size, categoryId, keyword, sortBy));
    }

    @GetMapping("/categories")
    public Result<List<Category>> categories() {
        return Result.success(categoryService.getAllCategories());
    }

    @GetMapping("/detail/{id}")
    public Result<Novel> detail(@PathVariable Long id) {
        return Result.success(novelService.getNovelDetail(id));
    }

    @PostMapping("/publish")
    public Result<Long> publish(@RequestHeader("Authorization") String auth, @RequestBody Novel novel) {
        String token = auth.replace("Bearer ", "");
        Long userId = JwtUtil.getUserId(token);
        novel.setAuthorId(userId);
        return Result.success(novelService.publishNovel(novel));
    }

    @GetMapping("/my")
    public Result<PageResult<Novel>> myNovels(
            @RequestHeader("Authorization") String auth,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        String token = auth.replace("Bearer ", "");
        Long userId = JwtUtil.getUserId(token);
        return Result.success(novelService.getMyNovels(userId, page, size));
    }

    @DeleteMapping("/{id}")
    public Result<?> deleteNovel(@RequestHeader("Authorization") String auth, @PathVariable Long id) {
        String token = auth.replace("Bearer ", "");
        Long userId = JwtUtil.getUserId(token);
        novelService.deleteNovel(id, userId);
        return Result.success();
    }
}
