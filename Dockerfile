# syntax=docker/dockerfile:1.7

FROM ghcr.io/cirruslabs/flutter:stable AS flutter-base

LABEL org.opencontainers.image.source="https://github.com/cirruslabs/docker-images-flutter"
LABEL maintainer="expenses dev team"

# Tạo user không phải root để tránh cảnh báo
RUN groupadd -r flutter && useradd -r -g flutter -m flutter

WORKDIR /app
RUN mkdir -p /usr/local/flutter && \
    chown -R flutter:flutter /app && \
    chown -R flutter:flutter /sdks/flutter && \
    chown -R flutter:flutter /usr/local/flutter

# Cài đặt Chromium cho Flutter web
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

# Dành riêng các thư mục cache để chia sẻ giữa các build.
ENV PUB_CACHE=/usr/local/flutter/.pub-cache \
    FLUTTER_HOME=/usr/local/flutter \
    PATH=/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:$PATH \
    CHROME_NO_SANDBOX=true \
    CHROME_EXECUTABLE=/usr/bin/chromium-browser

# Sao chép file cấu hình phụ thuộc trước để tận dụng cache layer của Docker.
COPY --chown=flutter:flutter pubspec.yaml pubspec.lock ./
USER flutter
# Cấu hình Git để cho phép truy cập Flutter SDK
RUN git config --global --add safe.directory /sdks/flutter
RUN flutter pub get

# Sao chép toàn bộ mã nguồn vào container và cài lại dependency để đảm bảo đồng bộ.
COPY --chown=flutter:flutter . .
RUN flutter pub get

# Tạo stage build web release (sử dụng --target build-web).
FROM flutter-base AS build-web
RUN flutter build web --release

# Stage cuối dùng cho phát triển (mặc định của docker build).
FROM flutter-base AS dev

# Đảm bảo user flutter được sử dụng
USER flutter

# Cho phép hot-reload qua web-server nội bộ.
EXPOSE 8080

# Command mặc định để chạy ứng dụng Flutter ở chế độ web-server.
CMD ["flutter", "run", "-d", "web-server", "--web-hostname=0.0.0.0", "--web-port=8080"]

