FROM registry.openanolis.cn/openanolis/anolisos:8.10

LABEL org.opencontainers.image.source="https://github.com/scott-wong/anolis-secure" \
      org.opencontainers.image.title="Anolis 8.10 Secure Base" \
      org.opencontainers.image.version="8.10"

ENV TZ=Asia/Shanghai

RUN set -eux; \
    if command -v dnf >/dev/null 2>&1; then \
      dnf -y update; \
      dnf -y install ca-certificates tzdata; \
      dnf clean all; \
    else \
      yum -y update; \
      yum -y install ca-certificates tzdata; \
      yum clean all; \
    fi; \
    # 基座预装的 pip/setuptools 只是无解释器的残留文件（dnf 升不动），删掉以消除其 CVE
    rm -rf /usr/lib/python3*/site-packages/pip* \
           /usr/lib/python3*/site-packages/setuptools* \
           /usr/lib/python3*/site-packages/pkg_resources* \
           /usr/bin/pip*; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    useradd --uid 10001 --user-group --create-home --home-dir /home/appuser --shell /sbin/nologin appuser; \
    mkdir -p /app; \
    chown appuser:appuser /app

USER appuser
WORKDIR /app
