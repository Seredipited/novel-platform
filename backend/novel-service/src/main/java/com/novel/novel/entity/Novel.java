package com.novel.novel.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("novel")
public class Novel {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String author;
    private Long authorId;
    private Integer categoryId;
    private String description;
    private String coverImg;
    private String status; // ongoing, completed
    private BigDecimal score;
    private Long wordCount;
    private Long clickCount;
    private Long favoriteCount;
    private String tags;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
