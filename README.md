# dsh-docker

DeepSeek Harness（`dsh`）Web GUI 的**非官方**容器镜像。镜像地址：`ghcr.io/cowwo/dsh`

## 直接用现成镜像

```bash
docker pull ghcr.io/cowwo/dsh:latest

docker run --rm -it --network host \
  -e DEEPSEEK_API_KEY=你的key \
  ghcr.io/cowwo/dsh:latest
```

启动后日志会打印一行：

```
dsh web: http://127.0.0.1:3080/?token=xxxx
```

浏览器打开这个链接即可。

想保留会话、设置与技能（重启不丢），加一个卷：

```bash
docker run --rm -it --network host \
  -e DEEPSEEK_API_KEY=你的key \
  -v ~/dsh-home:/root/.dsh \
  ghcr.io/cowwo/dsh:latest
```

## 镜像里有什么

| 类别 | 内容 |
|---|---|
| 运行时 | Node.js 24、npm 11、pnpm、dsh |
| 版本控制 | `git`、`openssh-client`、`gh`（GitHub CLI） |
| 网络 | `curl`、`wget`、`ca-certificates` |
| Python | `python3`、`pip3`、`venv` |

> Debian 12 的 Python 受 PEP 668 保护，全局装包需加 `--break-system-packages`，建议改用 `python3 -m venv`。

`gh` 认证方式：容器内执行 `gh auth login`，或运行时传 `-e GH_TOKEN=xxx`。

## 镜像标签

| 标签 | 含义 |
|---|---|
| `<版本号>`（如 `0.1.7-rc.2`） | 与上游 dsh 版本一一对应，**内容永久不变** |
| `latest` | 跟随 npm 的 `latest` 通道（**会移动**） |
| `next` | 跟随 npm 的 `next` 通道（**会移动**） |
| `sha-<提交>-<版本>` | 可追溯的构建快照 |

> `latest` / `next` 是"通道名"，指向哪个版本由上游 npm 的 dist-tags 决定；要长期固定就用具体版本号。
> 上游当前处于 rc（候选发布）通道，所以 `latest` 指向的也是 rc 版本，不是稳定版。

支持的架构：`linux/amd64`、`linux/arm64`

## 自己构建

```bash
docker build -t dsh .

# 指定 dsh 版本
docker build --build-arg DSH_VERSION=0.1.5-rc.3 -t dsh .
```

> 提示：若本机外网走代理，容器内下载 apt/npm 包会非常慢，建议交给 CI 构建。

## 自动发布怎么工作

`.github/scripts/plan.mjs` + `.github/workflows/publish.yml` 组成一条"跟随上游"的流水线：

1. **解析**：把 npm 的 dist-tags 反解成「版本 → 通道标签」矩阵（例如 `0.1.7-rc.2 ← latest`）
2. **幂等**：版本标签已存在、且它该带的通道名都已指向同一个镜像 → 跳过，不重复构建
3. **构建**：每个版本构建一次 `linux/amd64` + `linux/arm64`，一次构建打上「版本号 + 通道名 + sha」三个标签
4. **校验**：拉回镜像执行 `dsh -V`，与版本号不一致就失败

| 触发方式 | 行为 |
|---|---|
| 手动（Actions → publish → Run workflow） | 总是构建；可指定版本，留空则跟随 `latest` / `next` |
| 定时（每小时，第 17 分） | 只在"上游有新版本"或"通道名没指对"时构建；已发过的版本自动跳过，不会重复推送 |

跟随的通道在 workflow 的 `CHANNELS` 变量里配置，目前是 `latest next`。

## 三条必须知道的事

| 事项 | 说明 |
|---|---|
| 必须 `--network host` | dsh 为安全只监听容器内 `127.0.0.1`，`-p 3080:3080` 端口映射连不通 |
| 数据默认不持久 | 加 `-v ~/dsh-home:/root/.dsh` 才会保留会话与设置 |
| 容器内是 root | 挂载目录会变成 root 属主；介意的话自行在镜像里加非 root 用户 |

## 说明

- 本项目为非官方镜像，与 DeepSeek 官方无关。
- 上游项目：<https://github.com/deepseek-ai/deepseek-harness>（MIT）
- npm 包：`@deepseek-ai/dsh`