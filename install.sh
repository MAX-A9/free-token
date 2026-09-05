#!/bin/sh
# FreeTokenHub 一键安装/升级脚本
# 在线执行: curl -fsSL https://raw.githubusercontent.com/MAX-A9/free-token/main/install.sh | sh
# 可选环境变量: PORT(宿主机端口,默认3000) / LICENSE_KEY(授权码,不填则启动后在激活页输入)

set -e

IMAGE="ghcr.io/max-a9/freetoken:latest"
NAME="freetoken"
PORT="${PORT:-3000}"

echo "==> [1/5] 检查 Docker ..."
if ! command -v docker >/dev/null 2>&1; then
  echo "错误: 未安装 Docker。请先执行: curl -fsSL https://get.docker.com | sh" >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "错误: Docker 未运行或当前用户无权限。请先 systemctl start docker，或用 root 执行本脚本。" >&2
  exit 1
fi

MODE="安装"
if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  MODE="升级"
  echo "==> [2/5] 检测到已有容器，进入升级模式（数据与密码保留）..."
  PASSWORD=$(docker inspect "$NAME" --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^ADMIN_PASSWORD=' | cut -d= -f2- || true)
  OLD_PORT=$(docker port "$NAME" 3000 2>/dev/null | head -1 | sed 's/.*://' || true)
  if [ -n "$OLD_PORT" ]; then PORT="$OLD_PORT"; fi
else
  echo "==> [2/5] 生成随机管理员密码 ..."
  PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
fi
if [ -z "$PASSWORD" ]; then
  PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
fi

echo "==> [3/5] 拉取镜像 $IMAGE ..."
docker pull "$IMAGE"

echo "==> [4/5] 启动容器（宿主机端口 $PORT）..."
if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  docker rm -f "$NAME" >/dev/null
fi
RUN_ENV="-e DB_PATH=/data/freetoken.db -e ADMIN_PASSWORD=$PASSWORD"
if [ -n "$LICENSE_KEY" ]; then
  RUN_ENV="$RUN_ENV -e LICENSE_KEY=$LICENSE_KEY"
fi
if ! docker run -d --name "$NAME" -p "${PORT}:3000" \
  -v freetoken-data:/data \
  $RUN_ENV \
  --restart unless-stopped \
  "$IMAGE" >/dev/null; then
  echo "错误: 容器启动失败。常见原因：端口 $PORT 已被占用，可换端口重试，如 PORT=8080 sh install.sh" >&2
  exit 1
fi

echo "==> [5/5] 等待服务就绪 ..."
STATUS="starting"
i=0
while [ $i -lt 30 ]; do
  STATUS=$(docker inspect "$NAME" --format '{{.State.Health.Status}}' 2>/dev/null || echo starting)
  if [ "$STATUS" = "healthy" ]; then break; fi
  sleep 2
  i=$((i + 1))
done

SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then SERVER_IP="服务器IP"; fi

echo ""
echo "=============================================="
echo "  FreeTokenHub $MODE完成"
echo "=============================================="
echo "  前台地址 : http://$SERVER_IP:$PORT"
echo "  管理后台 : http://$SERVER_IP:$PORT/admin"
echo "  管理账号 : admin"
echo "  管理密码 : $PASSWORD"
echo "----------------------------------------------"
echo "  下一步：浏览器打开前台，按页面提示输入授权码激活。"
echo "  数据保存在 Docker 卷 freetoken-data，升级/换镜像不丢失。"
if [ "$STATUS" != "healthy" ]; then
  echo "  注意：容器仍在启动中，可稍后用 docker logs -f $NAME 查看。"
fi
echo "=============================================="
