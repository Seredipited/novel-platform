package com.novel.novel.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.novel.common.exception.BusinessException;
import com.novel.common.result.PageResult;
import com.novel.novel.entity.Novel;
import com.novel.novel.mapper.NovelMapper;
import com.novel.novel.service.NovelService;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class NovelServiceImpl extends ServiceImpl<NovelMapper, Novel> implements NovelService {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor());
        return interceptor;
    }

    @Override
    public PageResult<Novel> getNovelList(Integer page, Integer size, Integer categoryId, String keyword, String sortBy) {
        LambdaQueryWrapper<Novel> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null && categoryId > 0) {
            wrapper.eq(Novel::getCategoryId, categoryId);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(Novel::getTitle, keyword).or().like(Novel::getAuthor, keyword);
        }
        if ("score".equals(sortBy)) {
            wrapper.orderByDesc(Novel::getScore);
        } else if ("click".equals(sortBy)) {
            wrapper.orderByDesc(Novel::getClickCount);
        } else if ("newest".equals(sortBy)) {
            wrapper.orderByDesc(Novel::getCreateTime);
        } else {
            wrapper.orderByDesc(Novel::getFavoriteCount);
        }
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<Novel> mpPage =
                page(new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(page, size), wrapper);
        PageResult<Novel> result = new PageResult<>();
        result.setTotal(mpPage.getTotal());
        result.setPage(page);
        result.setSize(size);
        result.setRecords(mpPage.getRecords());
        return result;
    }

    @Override
    public Novel getNovelDetail(Long novelId) {
        Novel novel = getById(novelId);
        if (novel == null) throw new BusinessException("小说不存在");
        novel.setClickCount(novel.getClickCount() == null ? 1 : novel.getClickCount() + 1);
        updateById(novel);
        return novel;
    }

    @Override
    public Long publishNovel(Novel novel) {
        if (!StringUtils.hasText(novel.getTitle())) throw new BusinessException("书名不能为空");
        novel.setClickCount(0L);
        novel.setFavoriteCount(0L);
        novel.setWordCount(0L);
        novel.setScore(new java.math.BigDecimal("0.0"));
        novel.setStatus("ongoing");
        save(novel);
        return novel.getId();
    }

    @Override
    public PageResult<Novel> getMyNovels(Long authorId, Integer page, Integer size) {
        LambdaQueryWrapper<Novel> wrapper = new LambdaQueryWrapper<Novel>()
                .eq(Novel::getAuthorId, authorId)
                .orderByDesc(Novel::getUpdateTime);
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<Novel> mpPage =
                page(new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(page, size), wrapper);
        PageResult<Novel> result = new PageResult<>();
        result.setTotal(mpPage.getTotal());
        result.setPage(page);
        result.setSize(size);
        result.setRecords(mpPage.getRecords());
        return result;
    }

    @Override
    public void deleteNovel(Long novelId, Long authorId) {
        Novel novel = getById(novelId);
        if (novel == null) throw new BusinessException("小说不存在");
        if (!novel.getAuthorId().equals(authorId)) throw new BusinessException("无权删除他人的小说");
        removeById(novelId);
    }
}
