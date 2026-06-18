-- Nacos 配置数据库初始化
CREATE DATABASE IF NOT EXISTS nacos_config DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE nacos_config;

-- Nacos 2.2.x 官方建表语句
CREATE TABLE IF NOT EXISTS config_info (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT 'id',
    data_id VARCHAR(255) NOT NULL COMMENT 'data_id',
    group_id VARCHAR(128) DEFAULT NULL,
    content LONGTEXT NOT NULL COMMENT 'content',
    md5 VARCHAR(32) DEFAULT NULL COMMENT 'md5',
    gmt_create DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    gmt_modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    src_user TEXT COMMENT 'source user',
    src_ip VARCHAR(50) DEFAULT NULL COMMENT 'source ip',
    app_name VARCHAR(128) DEFAULT NULL,
    tenant_id VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    c_desc VARCHAR(256) DEFAULT NULL,
    c_use VARCHAR(64) DEFAULT NULL,
    effect VARCHAR(64) DEFAULT NULL,
    type VARCHAR(64) DEFAULT NULL,
    c_schema TEXT,
    encrypted_data_key TEXT NOT NULL COMMENT '秘钥',
    PRIMARY KEY (id),
    UNIQUE KEY uk_configinfo_datagrouptenant (data_id,group_id,tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS config_info_aggr (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT 'id',
    data_id VARCHAR(255) NOT NULL COMMENT 'data_id',
    group_id VARCHAR(128) NOT NULL COMMENT 'group_id',
    datum_id VARCHAR(255) NOT NULL COMMENT 'datum_id',
    content LONGTEXT NOT NULL COMMENT '内容',
    gmt_modified DATETIME NOT NULL COMMENT '修改时间',
    app_name VARCHAR(128) DEFAULT NULL,
    tenant_id VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    PRIMARY KEY (id),
    UNIQUE KEY uk_configinfoaggr_datagrouptenantdatum (data_id,group_id,tenant_id,datum_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS config_info_beta (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT 'id',
    data_id VARCHAR(255) NOT NULL COMMENT 'data_id',
    group_id VARCHAR(128) NOT NULL COMMENT 'group_id',
    app_name VARCHAR(128) DEFAULT NULL COMMENT 'app_name',
    content LONGTEXT NOT NULL COMMENT 'content',
    beta_ips VARCHAR(1024) DEFAULT NULL COMMENT 'betaIps',
    md5 VARCHAR(32) DEFAULT NULL COMMENT 'md5',
    gmt_create DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    gmt_modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    src_user TEXT COMMENT 'source user',
    src_ip VARCHAR(50) DEFAULT NULL COMMENT 'source ip',
    tenant_id VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    encrypted_data_key TEXT NOT NULL COMMENT '秘钥',
    PRIMARY KEY (id),
    UNIQUE KEY uk_configinfobeta_datagrouptenant (data_id,group_id,tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS config_info_tag (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT 'id',
    data_id VARCHAR(255) NOT NULL COMMENT 'data_id',
    group_id VARCHAR(128) NOT NULL COMMENT 'group_id',
    tenant_id VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    tag_id VARCHAR(128) NOT NULL COMMENT 'tag_id',
    app_name VARCHAR(128) DEFAULT NULL COMMENT 'app_name',
    content LONGTEXT NOT NULL COMMENT 'content',
    md5 VARCHAR(32) DEFAULT NULL COMMENT 'md5',
    gmt_create DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    gmt_modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    src_user TEXT COMMENT 'source user',
    src_ip VARCHAR(50) DEFAULT NULL COMMENT 'source ip',
    PRIMARY KEY (id),
    UNIQUE KEY uk_configinfotag_datagrouptenanttag (data_id,group_id,tenant_id,tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS config_tags_relation (
    id BIGINT NOT NULL COMMENT 'id',
    tag_name VARCHAR(128) NOT NULL COMMENT 'tag_name',
    tag_type VARCHAR(64) DEFAULT NULL COMMENT 'tag_type',
    data_id VARCHAR(255) NOT NULL COMMENT 'data_id',
    group_id VARCHAR(128) NOT NULL COMMENT 'group_id',
    tenant_id VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    nid BIGINT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (nid),
    UNIQUE KEY uk_configtagrelation_configidtag (id,tag_name,tag_type),
    KEY idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS group_capacity (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    group_id VARCHAR(128) NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
    `quota` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
    `max_aggr_size` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    gmt_create DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    gmt_modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS his_config_info (
    id BIGINT UNSIGNED NOT NULL,
    nid BIGINT NOT NULL AUTO_INCREMENT,
    data_id VARCHAR(255) NOT NULL,
    group_id VARCHAR(128) NOT NULL,
    app_name VARCHAR(128) DEFAULT NULL COMMENT 'app_name',
    content LONGTEXT NOT NULL,
    md5 VARCHAR(32) DEFAULT NULL,
    gmt_create DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user TEXT,
    src_ip VARCHAR(50) DEFAULT NULL,
    op_type CHAR(10) DEFAULT NULL,
    tenant_id VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    encrypted_data_key TEXT NOT NULL COMMENT '秘钥',
    PRIMARY KEY (nid),
    KEY idx_gmt_create (gmt_create),
    KEY idx_gmt_modified (gmt_modified),
    KEY idx_did (data_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS tenant_capacity (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id VARCHAR(128) NOT NULL DEFAULT '' COMMENT 'Tenant ID',
    `quota` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
    `max_aggr_size` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` INT UNSIGNED NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    gmt_create DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    gmt_modified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS tenant_info (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT 'id',
    kp VARCHAR(128) NOT NULL COMMENT 'kp',
    tenant_id VARCHAR(128) default '' COMMENT 'tenant_id',
    tenant_name VARCHAR(128) default '' COMMENT 'tenant_name',
    tenant_desc VARCHAR(256) DEFAULT NULL COMMENT 'tenant_desc',
    create_source VARCHAR(32) DEFAULT NULL COMMENT 'create_source',
    gmt_create BIGINT NOT NULL COMMENT '创建时间',
    gmt_modified BIGINT NOT NULL COMMENT '修改时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_info_kptenantid (kp,tenant_id),
    KEY idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS users (
    username VARCHAR(50) NOT NULL PRIMARY KEY,
    password VARCHAR(500) NOT NULL,
    enabled BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS roles (
    username VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    UNIQUE INDEX idx_user_role (username ASC, role ASC) USING BTREE
);

CREATE TABLE IF NOT EXISTS permissions (
    role VARCHAR(50) NOT NULL,
    resource VARCHAR(128) NOT NULL,
    action VARCHAR(8) NOT NULL,
    UNIQUE INDEX uk_role_permission (role,resource,action) USING BTREE
);
