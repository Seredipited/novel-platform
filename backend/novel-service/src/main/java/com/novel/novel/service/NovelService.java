package com.novel.novel.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.novel.common.result.PageResult;
import com.novel.novel.entity.Novel;

public interface NovelService extends IService<Novel> {
    PageResult<Novel> getNovelList(Integer page, Integer size, Integer categoryId, String keyword, String sortBy);
    Novel getNovelDetail(Long novelId);
    Long publishNovel(Novel novel);
    PageResult<Novel> getMyNovels(Long authorId, Integer page, Integer size);
    void deleteNovel(Long novelId, Long authorId);
}
