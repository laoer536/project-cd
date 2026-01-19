# Neo Blog – Deployment Guide

本目录包含 **Neo Blog 项目**的完整部署配置，遵循企业级 **前后端分离 + 数据迁移解耦** 的部署实践。

---

## 📁 项目结构

```text
.
├── README.md
├── blog
│   ├── deploy.sh
│   └── docker-compose.yml
├── blog-admin
│   ├── deploy.sh
│   └── docker-compose.yml
└── blog-api
    ├── deploy.sh
    ├── docker-compose.yml
    └── migrate
        └── docker-compose.yml
```
