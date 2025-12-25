# Deployment Repository

本仓库用于统一管理 **基础设施（Infra）** 以及 **多个业务项目的持续部署（CD）流程**。

该仓库的目标是：

- 前后端完全分离部署
- 基础设施与业务应用解耦
- Docker Compose 作为最小、可控的部署单元
- 支持本地模拟 CI 与真实 GitLab CI 行为一致
- 适用于多项目、多环境的企业级部署场景

---

## 📁 仓库结构

```text
.
├── infra
│   ├── infra.compose.yml
│   └── deploy-infra.sh
│
├── neo-blog
│   ├── backend
│   ├── frontend
│   ├── migrate
│   └── README.md
│
└── README.md