# ステージ1: ビルド用のイメージ
FROM golang:latest AS builder
WORKDIR /app
COPY . .
# 依存関係のダウンロードとアプリケーションのビルド
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# ステージ2: 実行用の軽量イメージ
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
# ビルドしたバイナリをコピー
COPY --from=builder /app/main .
# 起動コマンド
CMD ["./main"]