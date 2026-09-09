# Anolis 8.10 Secure Base

`ghcr.io/scott-wong/anolis-secure:8.10` 是一个默认以非 root 用户 `appuser` 运行的 Anolis OS 8.10 基础镜像。构建时会执行全量包更新，仅额外安装 `ca-certificates` 和 `tzdata`，并将时区设置为 `Asia/Shanghai`。

## 拉取和验证

```bash
docker pull ghcr.io/scott-wong/anolis-secure:8.10
docker image inspect ghcr.io/scott-wong/anolis-secure:8.10 \
  --format '{{ index .Config.Labels "org.opencontainers.image.version" }}'
docker run --rm --user 10001:10001 \
  ghcr.io/scott-wong/anolis-secure:8.10 id
```

执行 `docker run` 时不要指定 `-it`：`appuser` 的登录 shell 是 `/sbin/nologin`。业务进程应通过镜像入口命令或 `docker exec` 的显式命令启动。

## 构建

本仓库的正式构建和发布由 GitHub Actions 完成，推送 `main` 或任意 Git tag 时会触发。本机当前没有 Docker 命令，不要在本地执行构建。

## 定时重建

GitHub Actions 在每周一 `02:00 UTC`，即北京时间每周一 `10:00`，重新构建基础镜像。这样可以在上游 Anolis 8.10 发布安全更新后重新生成镜像层。

## 漏洞处理流程

1. 每次构建先推送固定的 `8.10` 和 `sha-<short-sha>` 标签。
2. Trivy 使用 digest 精确扫描已推送镜像，只检查 `CRITICAL` 和 `HIGH` 级别的可修复漏洞。
3. SARIF 结果会写入 GitHub Security 面板。
4. 只要扫描发现 `CRITICAL` 或 `HIGH` 漏洞，或扫描本身失败，流水线立即失败，不会推送 `latest`。
5. 修复方式是在 `main` 上重新执行包更新或升级基础镜像后提交；待扫描通过后，流水线才会发布 `latest`，并生成 SPDX SBOM artifact。

## 使用建议

下游镜像应继承 `appuser`，不要在后续 `USER` 指令中回到 root。应用文件写入的目录需要显式授权；`/app` 默认属于 `appuser`。
