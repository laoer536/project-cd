## 📄 部署方案使用文档（Summary & Usage Guide）

````md
# Docker 前后端分离部署方案 — 使用文档

本文档用于说明当前 **前后端分离、Infra 解耦、支持多项目多环境** 的 Docker CD 部署方案的整体特性与使用方式。

---

## 🎯 方案目标

- 前端 / 后端 **独立发布、互不影响**
- 数据库迁移 **强一致、可控**
- 基础设施 **稳定，不随业务变更**
- 支持多项目、多环境的持续部署

---

## ✨ 核心特性

### 1️⃣ 前后端完全分离部署
- Frontend / Backend 使用独立 Compose
- 可单独发版
- 发布互不影响

### 2️⃣ 基础设施与业务解耦
- 数据库、Redis、网络由 Infra 统一管理
- 不随业务发布重启
- 多项目可共享同一套 Infra

### 3️⃣ 数据迁移作为一次性部署单元
- Migration 不作为常驻服务
- 每次后端部署前强制执行
- 失败即终止部署流程

### 4️⃣ CI/CD 环境变量统一注入
- 生产环境不依赖 `.env` 文件
- GitLab CI 是唯一配置源
- 本地通过 `.env` 模拟 CI 行为

---

## 📁 标准目录结构

```text
.
├── infra
│   ├── infra.compose.yml
│   └── deploy-infra.sh
│
├── project-a
│   ├── backend
│   ├── frontend
│   ├── migrate
│   └── README.md
└── README.md
````

---

## 🧱 Infra 职责说明

Infra 负责提供 **平台级基础能力**：

* Postgres 数据库实例
* Redis 实例
* Docker 网络
* 平台级数据库管理员用户

⚠️ **Infra 不负责具体业务数据库的创建和管理（表 / schema）**

---

## 🚀 操作使用说明

### 一、启动基础设施（首次或 Infra 更新）

```bash
cd infra
./deploy-infra.sh
```

执行完成后：

* Postgres / Redis 容器处于运行状态
* 平台级网络已创建
* **此时尚未创建任何业务数据库**

---

### 二、手动创建业务数据库（必须执行一次）

> 该步骤属于 **平台初始化（Provisioning）**，
> 不属于应用部署流程，只需在新项目或新环境中执行一次。

#### 1️⃣ 进入 Postgres 容器

```bash
docker exec -it platform-postgres psql -U platform_admin
```

#### 2️⃣ 创建业务数据库

```sql
CREATE DATABASE neo_blog_db;
-- 如果有其他项目
CREATE DATABASE project_a_db;
```

#### 3️⃣ 退出

```sql
\q
```

📌 说明：

* 数据库名称由 **项目自行定义**
* 需与项目中 `DATABASE_URL` 保持一致
* 后续部署 **不需要重复执行该步骤**

---

### 三、部署后端（包含数据库迁移）

```bash
cd project-a/backend
./deploy-backend.sh
```

执行顺序：

1. 加载 CI 环境变量
2. 校验必需变量
3. 拉取 backend / migrate 镜像
4. 执行数据库 migration（表结构变更）
5. 启动 backend 服务

> ❗ 如果业务数据库不存在，migration 将直接失败

---

### 四、部署前端

```bash
cd project-a/frontend
./deploy-frontend.sh
```

* 前端可独立部署
* 不影响后端或数据库

---

## 🔐 环境变量规范

### 生产 / CI 环境

* 所有变量由 GitLab CI 管理
* `docker compose` 自动读取 CI 环境变量
* 不依赖 `.env` 文件

### 本地模拟 CI

* 使用 `.env.backend.deploy` / `.env.frontend.deploy`
* 脚本通过 `source` 加载
* 行为与线上 CI 一致

---

## 🛡️ 稳定性与安全设计

* 强制环境变量校验
* 数据迁移与后端部署强绑定
* Infra 与业务完全解耦
* 不允许 CI 自动创建数据库

---

## 📈 可扩展方向

* 多项目并行部署
* 多环境（dev / staging / prod）
* Worker / Cron 等服务形态
* 平滑演进至 Kubernetes

---

## 📝 最佳实践总结

* Infra 只负责“提供能力”，不负责“业务状态”
* 数据库必须先于 migration 创建
* Migration 只使用 `docker compose run`
* 后端启动前必须 migration 成功

---

