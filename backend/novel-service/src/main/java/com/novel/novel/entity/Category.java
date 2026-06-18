package com.novel.novel.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("novel_category")
public class Category {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private String name;
    private String description;
}
