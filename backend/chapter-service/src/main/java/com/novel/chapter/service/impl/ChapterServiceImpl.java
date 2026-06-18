package com.novel.chapter.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.novel.chapter.entity.Chapter;
import com.novel.chapter.mapper.ChapterMapper;
import com.novel.chapter.service.ChapterService;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ChapterServiceImpl extends ServiceImpl<ChapterMapper, Chapter> implements ChapterService {

    @Override
    public List<Chapter> getChaptersByNovelId(Long novelId) {
        return list(new LambdaQueryWrapper<Chapter>()
                .eq(Chapter::getNovelId, novelId)
                .orderByAsc(Chapter::getChapterNumber));
    }

    @Override
    public Chapter getChapterDetail(Long chapterId) {
        return getById(chapterId);
    }

    @Override
    public Long addChapter(Chapter chapter) {
        chapter.setChapterNumber(getMaxChapterNumber(chapter.getNovelId()) + 1);
        if (chapter.getContent() != null) {
            chapter.setWordCount((long) chapter.getContent().length());
        }
        save(chapter);
        return chapter.getId();
    }

    @Override
    public void updateChapter(Chapter chapter) {
        if (chapter.getContent() != null) {
            chapter.setWordCount((long) chapter.getContent().length());
        }
        updateById(chapter);
    }

    @Override
    public void deleteChapter(Long id) {
        removeById(id);
    }

    @Override
    public Integer getMaxChapterNumber(Long novelId) {
        Chapter chapter = getOne(new LambdaQueryWrapper<Chapter>()
                .eq(Chapter::getNovelId, novelId)
                .orderByDesc(Chapter::getChapterNumber)
                .last("LIMIT 1"));
        return chapter == null ? 0 : chapter.getChapterNumber();
    }
}
