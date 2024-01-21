# ステージ1: ビルド用のイメージ
FROM node:latest AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

# ステージ2: 実行用の軽量イメージ
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
# 任意の設定ファイルをコピーする場合
# COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]