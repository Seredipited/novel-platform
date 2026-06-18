package com.novel.chapter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("novel_chapter")
public class Chapter {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long novelId;
    private String title;
    private String content;
    private Integer chapterNumber;
    private Long wordCount;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
