# FreeTokenHub — AI Token 中转站导航平台

> 开箱即用的 AI API 中转站导航站：**自动测活 · 自动比价 · SEO/GEO 双流量引擎**。
> Docker 镜像仅约 20MB，一条命令安装，一台最低配 VPS 即可运营。

![Go](https://img.shields.io/badge/Go-1.23-00ADD8) ![Vue](https://img.shields.io/badge/Vue-3-4FC08D) ![SQLite](https://img.shields.io/badge/SQLite-单文件-003B57) ![Docker](https://img.shields.io/badge/Docker-一键部署-2496ED)

---

## 快速开始

```bash
curl -fsSL https://raw.githubusercontent.com/MAX-A9/free-token/main/install.sh | sh
```

脚本自动完成：拉取镜像 → 生成随机管理员密码 → 启动容器 → 打印访问地址与账号密码。首次打开站点，按页面提示输入授权码即可完成激活。

---

## 一、为什么做这个产品

AI API 中转站（new-api / one-api 系）爆发式增长，用户找"免费、可用、便宜"的中转站时面临三大痛点：

| 痛点 | 现状 | FreeTokenHub 的答案 |
|------|------|---------------------|
| 站点死活没人管 | 收藏夹里的站三天两头失联 | 小时级自动探活，死站自动标记 |
| 价格全靠人工问 | 每个站都要注册充值才知道价格 | 自动抓取 new-api 价格接口，模型单价实时比价 |
| 流量入口分散 | 靠群聊、贴吧口口相传 | 服务端直出 + SEO/GEO 优化，搜索引擎与 AI 搜索都能带量 |

**一句话：一个不需要人工运营的 AI 中转站导航站。**

## 二、核心卖点

### 1. 全自动测活 + 比价，零人工运营
- 内置 prober 引擎：小时级轻量探针（`max_tokens=1` 探测），不烧对方 token，即可持续监测站点可用性
- 自动抓取 new-api `/api/pricing` 价格接口，模型单价、分组倍率实时更新
- 可用性与定价全自动，人工只需补一句编辑点评

### 2. SEO + GEO 双流量引擎
- 服务端直出（SSR），百度 / Google / 360 / 搜狗零适配收录
- 自动生成 `sitemap.xml`、`robots.txt`、canonical、OG 标签、JSON-LD 结构化数据
- 原生面向 **AI 搜索（GEO）**：内置 `llms.txt` / `llms-full.txt`（llmstxt.org 规范），放行 GPTBot、ClaudeBot、PerplexityBot、Bytespider 等 AI 爬虫
- 当用户在 ChatGPT / Perplexity / 豆包里问"有哪些免费 AI 中转站"，你的站就是答案

### 3. 20MB Docker 镜像，最低配 VPS 可跑
| 指标 | 数值 |
|------|------|
| Docker 镜像 | ~20MB（scratch 基础，三阶段构建） |
| 内存占用 | 空载 ~20MB / 满载 ~50MB |
| 启动时间 | <100ms |
| 并发能力 | 单机 1000+ QPS |
| 数据库 | SQLite 单文件（纯 Go 驱动，无 CGO），复制即备份 |

管理后台（Vue 3 + Vite + Element Plus）构建产物通过 `go:embed` 直接嵌入镜像——**一个文件就是整个产品**。

### 4. 内置 68 个种子站点
首次启动自动导入 68 个真实中转站数据，上线即有内容，无需冷启动。

### 5. 机甲风可视化后台
Vue 3 + Element Plus 机甲风主题，仪表盘 / 站点管理 / 投稿审核 / 模板与菜单配置 / 账号安全全部可视化，菜单与页面均为配置驱动，不改代码即可调整。

## 三、产品能力清单

| 模块 | 能力 |
|------|------|
| 前台 | 导航首页（分类 / 标签 / 搜索 / 排序）、站点详情评测页、在线投稿页 |
| 数据 | 站点可用性自动探测、价格接口抓取、站点统计 |
| 后台 | 站点增删改查、投稿审核（通过 / 拒绝）、全局设置、菜单与模板配置、账号管理 |
| SEO/GEO | sitemap / robots / llms.txt / JSON-LD / OG / canonical，支持站点独立配置域名与关键词 |
| 安全 | JWT 认证、接口限流（投稿 5 次/小时/IP）、XSS 过滤、路径净化 |

## 四、5 分钟部署

### 方式一：一键脚本

```bash
curl -fsSL https://raw.githubusercontent.com/MAX-A9/free-token/main/install.sh | sh
```

脚本自动检查 Docker、拉取镜像、生成随机管理员密码、启动容器并打印访问地址 / 账号 / 密码。**重复执行即为升级**：自动检测已有容器，保留数据与密码。

- 进阶用法：`PORT=8080 sh ...` 指定宿主机端口；`LICENSE_KEY=授权码 sh ...` 安装时直接激活
- 首次启动自动完成：建库（SQLite 单文件）→ 导入 68 个种子站点 → 创建管理员 → 生成 JWT 密钥，全程无需手动初始化
- 未填授权码时，首次打开站点会自动跳转激活页，填入授权码即可使用

### 数据与升级

- **数据安全**：数据保存在 Docker 卷 `freetoken-data`，升级、重建容器均不丢失
- **升级**：重新执行安装脚本即可（自动保留数据与密码）
- **备份**：SQLite 单文件，从卷中拷出即备份：

```bash
docker run --rm -v freetoken-data:/data -v $(pwd):/backup alpine cp /data/freetoken.db /backup/
```

## 五、适用场景

- **站长 / 流量主**：做一个 AI 工具导航站吃 SEO + AI 搜索流量，广告或导流变现
- **中转站运营者**：为自己的 new-api 站搭生态导航，拉新、留存、展示价格优势
- **企业 / 个人开发者**：私有化部署，换上自己的品牌，做一个专属 AI 导航站

## 六、FAQ

**Q: 需要什么配置的服务器？**
A: 任意 1 核 1G VPS 即可（需已安装 Docker），一条脚本命令完成部署。SQLite 无外部依赖，数据卷持久化，升级不丢数据。

**Q: 数据怎么备份？**
A: SQLite 单文件，`cp` 即备份，恢复即替换（具体路径见「数据与升级」）。

**Q: 可以二次开发吗？**
A: Go 1.23 + chi + Vue 3 全部为主流技术栈，模块划分清晰（handlers / prober / i18n 等），交付文档含完整 API 列表与部署手册。

## 七、联系与获取

- 产品说明仓库：<https://github.com/MAX-A9/free-token>
- Docker 镜像：`ghcr.io/max-a9/freetoken`
- 试用 / 购买 / 定制：**请联系作者**（微信 / QQ /  —— zl93339 / 1102465916）

---

> FreeTokenHub © 2026 MAX-A9 · 本页为产品销售文档，镜像托管于 ghcr.io（见「快速开始」），源码包通过私下渠道提供。
