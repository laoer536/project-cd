# Neo Blog – Deployment Guide

本目录包含 **Neo Blog 项目**的完整部署配置，遵循企业级 **前后端分离 + 数据迁移解耦** 的部署实践。

---

## 📁 项目结构

```text
neo-blog/
├── backend
│   ├── backend.compose.yml
│   └── deploy-backend.sh
│
├── frontend
│   ├── frontend.compose.yml
│   └── deploy-frontend.sh
│
├── migrate
│   └── migrate.compose.yml
│
└── README.md
```
