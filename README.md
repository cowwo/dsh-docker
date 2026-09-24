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

## 镜像标签

| 标签 | 含义 |
|---|---|
| `0.1.5-rc.3` | 与上游 dsh 版本一一对应 |
| `latest` | 最近一次**手动**发布对应的版本 |
| `sha-<短哈希>` | 可追溯的构建快照 |

> 上游当前处于 rc（候选发布）通道，`latest` 指向的也是 rc 版本，不是稳定版。

支持的架构：`linux/amd64`、`linux/arm64`

## 自己构建

```bash
docker build -t dsh .

# 指定 dsh 版本
docker build --build-arg DSH_VERSION=0.1.5-rc.3 -t dsh .
```

## 自动发布怎么工作

`.github/workflows/publish.yml`：

1. 解析要发布的 dsh 版本（手动触发可指定，留空则取 npm 上的 `latest`）
2. 该版本已存在于 GHCR 且是定时触发 → 直接跳过，不重复构建
3. 构建 `linux/amd64` + `linux/arm64` 并推送
4. 拉回镜像执行 `dsh -V`，**校验镜像内版本与标签一致**，不一致就失败

| 触发方式 | 行为 |
|---|---|
| 手动（Actions → publish → Run workflow） | 总是构建，并更新 `latest` |
| 每天定时 | 上游有新版本才构建，**不覆盖** `latest` |

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
