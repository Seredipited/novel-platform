package com.novel.chapter.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.novel.chapter.entity.Chapter;

public interface ChapterService extends IService<Chapter> {
    java.util.List<Chapter> getChaptersByNovelId(Long novelId);
    Chapter getChapterDetail(Long chapterId);
    Long addChapter(Chapter chapter);
    void updateChapter(Chapter chapter);
    void deleteChapter(Long id);
    Integer getMaxChapterNumber(Long novelId);
}
