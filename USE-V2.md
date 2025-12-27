# 使用文档（v2.1）

> 本文档描述当前 **多项目 / 多服务 Docker CD 仓库** 的使用方式。
> 本仓库用于 **运行态部署（CD）**，不负责构建（CI）。

---

## 一、仓库定位

### 1. 本仓库是什么？

这是一个 **CD（Continuous Delivery）仓库**，用于：

* 描述基础设施（infra）
* 描述服务运行方式（docker-compose）
* 管理多项目、多服务的部署流程

### 2. 本仓库不做什么？

* ❌ 不构建镜像
* ❌ 不运行测试
* ❌ 不管理业务源码

镜像由各业务仓库的 **CI** 构建并推送，本仓库只负责 **拉取并运行指定版本**。

---

## 二、整体目录结构

```text
.
├── README.md
├── USE.md
├── infra
│   ├── deploy-infra.sh
│   └── infra.compose.yml
└── neo-blog
    ├── README.md
    ├── blog
    │   ├── .env.frontend.deploy
    │   ├── blog.frontend.compose.yml
    │   └── deploy-frontend.sh
    ├── blog-admin
    │   ├── .env.frontend.deploy
    │   ├── blog-admin.frontend.compose.yml
    │   └── deploy-frontend.sh
    └── blog-api
        ├── .env.backend.deploy
        ├── blog-api.backend.compose.yml
        ├── deploy-backend.sh
        └── migrate
            └── blog-api.migrate.compose.yml
```

---

## 三、环境与变量说明（重要）

### 1. 真实 CI 环境（GitLab）

在真实 GitLab CI / CD 场景下：

* **不需要任何 `.env.*.deploy` 文件**
* 所有变量由 GitLab CI/CD Variables 注入
* `docker compose` 会自动读取 shell 环境变量

`.env.*.deploy` **不会提交到生产环境**。

---

### 2. 本地模拟 CI（当前仓库做法）

为了在本地模拟真实 CI 行为：

* 每个服务目录下提供一个 `.env.*.deploy`
* `deploy-*.sh` 会 `source` 该文件

👉 这些文件的作用是：

> **模拟 GitLab Runner 执行 deploy 脚本时的环境变量注入**

---

## 四、基础设施（Infra）部署

### 1. Infra 职责

Infra 负责：

* PostgreSQL
* Redis
* Docker 网络：

    * `database-network`
    * `app-network`

Infra 是 **全局共享、长期运行** 的。

---

### 2. 部署 Infra

```bash
cd infra
./deploy-infra.sh
```

该步骤通常只在以下情况下执行：

* 新服务器初始化
* Infra 组件变更

---

### 3. 手动创建数据库（必须）

PostgreSQL 容器 **不会自动创建业务数据库**。

首次部署某个后端服务前，需要手动创建数据库：

```bash
docker exec -it neo-prod-postgres psql -U <db_user>
```

```sql
CREATE DATABASE blog_api;
```

之后：

* migrate 只负责 schema 变更
* 不负责 database lifecycle

---

## 五、后端服务（blog-api）部署

### 1. 后端由两部分组成

| 组件      | 说明                     |
| ------- | ---------------------- |
| backend | 长期运行的 API 服务           |
| migrate | 一次性 Prisma schema 迁移任务 |

两者 **强相关，但不自动绑定**。

---

### 2. 本地模拟 CI 部署后端

```bash
cd neo-blog/blog-api
./deploy-backend.sh
```

执行顺序为：

1. 加载 `.env.backend.deploy`
2. 校验关键 CI 变量
3. Docker Registry 登录（如配置）
4. 拉取 backend / migrate 镜像
5. 执行 migrate（强制 gate）
6. 启动 backend 服务

---

### 3. Migration 执行原则（生产级）

* Migration **必须显式执行**
* Migration 失败 → backend 不会启动
* backend 启动 **不会隐式触发 migration**

这是为了避免生产环境出现不可控 schema 变更。

---

## 六、前端服务部署

### 1. 前端服务列表

| 服务         | 目录                    |
| ---------- | --------------------- |
| blog       | `neo-blog/blog`       |
| blog-admin | `neo-blog/blog-admin` |

每个前端：

* 独立 compose
* 独立 deploy 脚本
* 独立环境变量

---

### 2. 部署前端

```bash
cd neo-blog/blog
./deploy-frontend.sh
```

或：

```bash
cd neo-blog/blog-admin
./deploy-frontend.sh
```

前端部署：

* 不影响 backend
* 不影响数据库
* 可独立发版

---

## 七、网络与隔离模型

### 1. 网络设计

| 网络               | 用途                     |
| ---------------- | ---------------------- |
| database-network | backend / migrate ↔ DB |
| app-network      | frontend ↔ backend     |

网络由 infra 创建，其它 compose 通过 `external: true` 使用。

---

### 2. 多项目是否会“串台”？

不会。

原因：

* Docker network ≠ 数据隔离
* 实际隔离依赖：

    * DATABASE_URL
    * 服务名
    * 端口

只要变量不同，多个项目可以安全共存。

---

## 八、CI / CD 协作模型

### CI（业务仓库）

* 构建镜像
* 打 tag
* 推送 registry

### CD（本仓库）

* 拉取指定 tag
* 执行 migrate
* 启动服务

**唯一契约：镜像 + tag**

---

## 九、多环境部署方式（企业实践）

| 环境      | 方式    |
| ------- | ----- |
| dev     | 独立服务器 |
| staging | 独立服务器 |
| prod    | 独立服务器 |

每台服务器：

* clone 同一份 CD 仓库
* 注入不同环境变量
* 执行相同部署命令

---

## 十、总结

* 本仓库是 **运行态描述**
* Migration 是 **受控任务**
* CI / CD 明确解耦
* 结构可扩展到多个项目、多个服务

---
