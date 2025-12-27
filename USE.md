# Project CD

> A production-ready Docker-based Continuous Delivery (CD) repository
> for multi-project, multi-service deployment.

---

## 一、项目简介

**Project CD** 是一个用于 **生产环境部署（CD）** 的基础设施与服务运行仓库。

它基于：

* Docker
* Docker Compose
* 环境变量驱动（CI/CD Variables）

用于统一管理：

* 多项目
* 多服务（frontend / backend / migrate）
* 多环境（dev / staging / prod）

---

## 二、设计目标

本项目的核心设计目标：

* ✅ **CI / CD 职责严格解耦**
* ✅ **服务部署可重复、可审计**
* ✅ **数据库迁移可控、可回滚**
* ✅ **支持多项目并行运行**
* ✅ **适配企业级环境隔离模型**

---

## 三、项目定位

### 这个仓库是做什么的？

* 描述 **基础设施运行方式**
* 描述 **服务的运行态**
* 管理 **镜像版本 → 实际运行实例**

### 这个仓库不做什么？

* ❌ 不构建镜像
* ❌ 不管理业务源码
* ❌ 不跑测试
* ❌ 不负责 CI Pipeline

> **镜像构建属于业务仓库的 CI，
> 本仓库只关心“用哪个镜像，怎么跑”。**

---

## 四、整体架构

```text
┌────────────┐
│  CI (App)  │  Build / Test / Push Image
└─────┬──────┘
      │
      ▼
┌────────────────────┐
│   Container Registry│
└─────┬──────────────┘
      │
      ▼
┌──────────────────────────┐
│      Project CD           │
│  (This Repository)        │
│                            │
│  - Infra                   │
│  - Docker Compose          │
│  - Migration Control       │
└───────────┬────────────────┘
            │
            ▼
     Production Servers
```

---

## 五、仓库结构

```text
.
├── README.md        # 项目总览（你正在看的）
├── USE.md           # 使用说明（如何部署）
├── infra            # 基础设施（DB / Redis / Network）
│   ├── deploy-infra.sh
│   └── infra.compose.yml
└── neo-blog         # 示例项目（可扩展为多个项目）
    ├── README.md
    ├── blog
    ├── blog-admin
    └── blog-api
```

---

## 六、核心设计思想

### 1️⃣ CI / CD 解耦

* CI：**构建与发布**
* CD：**运行与部署**

通过镜像 + tag 作为唯一契约，避免环境漂移。

---

### 2️⃣ 迁移（Migration）是显式行为

* 数据库迁移不会“自动发生”
* 每次 migration 都是一次明确的操作
* migration 失败 = 服务不会启动

> 这是生产系统最重要的安全边界之一。

---

### 3️⃣ 多项目、多服务天然支持

* 每个项目是一个目录
* 每个服务一个 compose 文件
* 环境变量决定一切

不依赖服务名、不依赖 container_name、不依赖固定端口。

---

### 4️⃣ 本地 ≈ 线上

* 本地通过 `.env.*.deploy` 模拟 CI
* 线上由 GitLab CI/CD Variables 注入

**部署脚本完全一致**。

---

## 七、适用场景

本仓库非常适合以下团队或项目：

* 中小型技术团队
* 微服务 / 多前端项目
* 希望从单机部署演进到规范化 CD
* 不想引入 Kubernetes，但仍然追求工程秩序

---

## 八、不适合的场景

* ❌ 超大规模集群（建议 Kubernetes）
* ❌ 强依赖 Service Mesh
* ❌ 需要自动弹性伸缩

---

## 九、如何开始

👉 **请直接阅读：**

```text
USE.md
```

该文档包含：

* Infra 初始化
* 后端 / 前端部署流程
* 数据库创建与迁移
* 本地模拟 CI 的方法

---

## 十、设计原则总结

* 一切皆显式
* 不做“隐式魔法”
* 人比系统重要
* 可维护性优先于自动化

---

