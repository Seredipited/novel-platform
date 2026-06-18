-- 文澜阁 - 小说阅读平台 数据库初始化脚本
-- Database: novel_platform

CREATE DATABASE IF NOT EXISTS novel_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE novel_platform;

-- 用户表
DROP TABLE IF EXISTS novel_user;
CREATE TABLE novel_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(200) NOT NULL COMMENT '密码(加密)',
    nickname VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    email VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    bio VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
    gender TINYINT DEFAULT 0 COMMENT '性别：0-未知 1-男 2-女',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 小说分类表
DROP TABLE IF EXISTS novel_category;
CREATE TABLE novel_category (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    description VARCHAR(200) DEFAULT NULL COMMENT '分类描述'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小说分类表';

-- 小说表
DROP TABLE IF EXISTS novel;
CREATE TABLE novel (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '小说ID',
    title VARCHAR(200) NOT NULL COMMENT '小说标题',
    author VARCHAR(100) DEFAULT NULL COMMENT '作者名',
    author_id BIGINT DEFAULT NULL COMMENT '作者用户ID',
    category_id INT DEFAULT NULL COMMENT '分类ID',
    description TEXT COMMENT '小说简介',
    cover_img VARCHAR(500) DEFAULT NULL COMMENT '封面图片URL',
    status VARCHAR(20) DEFAULT 'ongoing' COMMENT '状态：ongoing-连载中 completed-已完结',
    score DECIMAL(3,1) DEFAULT 0.0 COMMENT '评分',
    word_count BIGINT DEFAULT 0 COMMENT '字数',
    click_count BIGINT DEFAULT 0 COMMENT '点击量',
    favorite_count BIGINT DEFAULT 0 COMMENT '收藏数',
    tags VARCHAR(500) DEFAULT NULL COMMENT '标签(逗号分隔)',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小说表';

-- 章节表
DROP TABLE IF EXISTS novel_chapter;
CREATE TABLE novel_chapter (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '章节ID',
    novel_id BIGINT NOT NULL COMMENT '所属小说ID',
    title VARCHAR(200) NOT NULL COMMENT '章节标题',
    content MEDIUMTEXT COMMENT '章节内容',
    chapter_number INT NOT NULL COMMENT '章节序号',
    word_count BIGINT DEFAULT 0 COMMENT '章节字数',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_novel_id (novel_id),
    INDEX idx_novel_chapter (novel_id, chapter_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='章节表';

-- 初始化分类数据
INSERT INTO novel_category (id, name, description) VALUES
(1, '玄幻', '东方玄幻、异界大陆、王朝争霸'),
(2, '仙侠', '修真文明、神话志怪、现代修真'),
(3, '都市', '都市生活、都市异能、都市爱情'),
(4, '历史', '历史穿越、架空历史、古代战争'),
(5, '科幻', '星际文明、未来世界、末世危机'),
(6, '悬疑', '推理侦探、灵异惊悚、冒险解谜'),
(7, '游戏', '游戏竞技、游戏异界、电子竞技'),
(8, '言情', '古代言情、现代言情、浪漫青春');

-- 初始化测试用户 (密码均为: 123456)
INSERT INTO novel_user (id, username, password, nickname, bio) VALUES
(1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', '文澜阁主', '文澜阁的守护者，热爱阅读与创作。'),
(2, 'author_wang', 'e10adc3949ba59abbe56e057f20f883e', '墨香书童', '一支笔，写尽世间冷暖。'),
(3, 'reader_li', 'e10adc3949ba59abbe56e057f20f883e', '书虫小李', '读书破万卷，下笔如有神。');

-- 初始化测试小说
INSERT INTO novel (id, title, author, author_id, category_id, description, status, score, word_count, click_count, favorite_count, tags) VALUES
(1, '星辰变', '墨香书童', 2, 1, '在浩瀚的星辰大海中，一个少年踏上了修仙之路。他历经磨难，最终成就星辰大道，成为一代传说。', 'ongoing', 8.5, 1520000, 25800, 3200, '玄幻,修仙,热血'),
(2, '都市奇缘', '墨香书童', 2, 3, '平凡的大学生林逸在一次意外中获得了神秘的能力，从此他的生活发生了翻天覆地的变化。', 'ongoing', 7.8, 890000, 18600, 2100, '都市,异能,轻松'),
(3, '大唐风华录', '文澜阁主', 1, 4, '一个现代历史系学生意外穿越到大唐贞观年间，凭借历史知识在这个辉煌的时代书写属于自己的传奇。', 'completed', 9.2, 2100000, 45200, 5600, '历史,穿越,权谋'),
(4, '星际迷航之归途', '文澜阁主', 1, 5, '公元3000年，人类已经迈入星际时代。一艘探索飞船在未知星域遇险，船员们为了回到地球开始了漫长而惊险的旅程。', 'ongoing', 8.9, 1250000, 32100, 4100, '科幻,星际,冒险'),
(5, '古墓谜踪', '书虫小李', 3, 6, '考古系教授带着学生在深山中发现了一座神秘古墓，随着调查的深入，一个跨越千年的惊天秘密逐渐浮出水面。', 'ongoing', 8.1, 680000, 15200, 1800, '悬疑,考古,推理'),
(6, '仙途漫漫', '墨香书童', 2, 2, '在一个修仙世界里，资质平平的少年凭借坚韧不拔的意志，一步步踏上通天仙途。', 'ongoing', 7.5, 980000, 12500, 1500, '仙侠,修真,成长'),
(7, '电竞之王', '书虫小李', 3, 7, '天才少年在电竞领域大放异彩，带领队伍走向世界之巅的燃情故事。', 'completed', 8.7, 780000, 28900, 3400, '电竞,热血,青春'),
(8, '花开半夏', '文澜阁主', 1, 8, '一段发生在江南小镇的纯美爱情故事，两个年轻人在最美的年华相遇，共同谱写了一段刻骨铭心的恋曲。', 'completed', 8.3, 450000, 19800, 2600, '言情,青春,温馨');

-- 初始化测试章节
INSERT INTO novel_chapter (id, novel_id, title, content, chapter_number, word_count) VALUES
(1, 1, '第一章 星辰初现', '在遥远的天元大陆上，有一个叫星辰镇的小镇。\n小镇的东边住着一个叫林星的少年，他自幼父母双亡，与年迈的爷爷相依为命。\n这一日，天降异象，一颗流星划破夜空，坠落在小镇后山。\n林星被这奇异的天象吸引，独自一人前往后山探查。\n他并不知道，这次普通的探查，将彻底改变他的命运。\n当他来到流星坠落之处时，发现了一块散发着淡蓝色光芒的奇异石头。\n石头中似乎蕴含着无穷的力量，不断散发出星辰般的光芒。\n林星小心翼翼地捡起石头，一股温暖的能量瞬间涌入他的体内。\n从此，他踏上了一条充满艰险与机遇的修仙之路。', 1, 240),
(2, 1, '第二章 初入宗门', '三个月后，星辰镇的平静被一群不速之客打破。\n他们是天星宗的弟子，奉命下山寻找拥有修仙资质的少年。\n天星宗是天元大陆上赫赫有名的修仙门派之一，以星辰功法闻名于世。\n林星凭借体内的星辰能量，轻松通过了入门测试。\n在爷爷的鼓励下，他决定跟随天星宗弟子前往宗门修行。\n临行前，爷爷将一块祖传的玉佩交给了他，叮嘱他一定要好好保管。\n林星含泪告别了爷爷，踏上了前往天星宗的旅程。\n山门巍峨，云雾缭绕，天星宗坐落于天元山脉的最高峰。\n站在山门前，林星感受到了前所未有的震撼。\n他知道，属于自己的传奇，才刚刚开始。', 2, 280),
(3, 1, '第三章 星辰诀', '进入天星宗后，林星被分配到了外门弟子居住的青云院。\n这里住着几十名和他一样刚刚入门的弟子。\n宗门长老传授给他们基础的心法——星辰诀。\n星辰诀共分九层，据说修炼到第九层可以引动星辰之力，拥有毁天灭地之能。\n林星天赋异禀，仅仅七天就突破到了星辰诀第一层。\n这让他的师父张长老对这个普通的少年刮目相看。\n然而，林星的快速进步也引来了一些师兄的嫉妒。\n外门弟子中实力最强的赵天龙，开始处处针对林星。\n林星深知自己实力尚浅，选择了隐忍。\n他白天完成杂务，晚上则刻苦修炼星辰诀。\n在月圆之夜，他发现星辰诀的修炼速度会大大提升。\n这让他更加确定了要以星辰为师的决心。', 3, 310),
(4, 1, '第四章 秘境试炼', '三个月后，天星宗举行了一年一度的秘境试炼。\n所有外门弟子都有资格参加，试炼成绩优异者可以晋升为内门弟子。\n秘境中充满了各种危险，但也有着丰富的修炼资源。\n林星和几位相熟的弟子组成了小队，一起进入秘境。\n秘境内是一个独立的小世界，里面灵兽遍地，灵药丛生。\n他们小心翼翼地前行，避开了一些强大的灵兽。\n在一处山谷中，他们发现了一株千年灵芝。\n然而，守护灵芝的是一只三阶灵兽——烈焰虎。\n一场激烈的战斗就此展开。\n林星凭借星辰诀的力量，与队友们配合默契，最终击败了烈焰虎。\n但战斗的动静引来了更多的灵兽，他们不得不仓促撤退。', 4, 290);
