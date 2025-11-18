# Expenses Platform

Monorepo gồm hai phần chính:

- `App/`: Ứng dụng Flutter quản lý chi tiêu (mobile/desktop/web).
- `Admin/`: Dashboard quản trị xây dựng bằng Next.js + Material UI.

## 1. Kiến trúc thư mục

```
expenses/
├─ App/        # Flutter client
├─ Admin/      # Next.js admin dashboard
├─ .gitinorge  # Quy tắc ignore chung
└─ README.md   # Tài liệu này
```

Mỗi thư mục con có cấu trúc và README riêng phục vụ chuyên sâu cho module tương ứng.

## 2. Chuẩn bị môi trường

| Thành phần | Yêu cầu |
|------------|---------|
| Flutter App | Flutter SDK 3.x, Dart SDK, Android/iOS toolchain, Visual Studio (Desktop) |
| Admin Dashboard | Node.js ≥ 18, npm ≥ 10, trình duyệt hiện đại |

**Tuỳ chọn:** Dockerfile và docker-compose có sẵn trong `App/` để dựng nhanh môi trường Flutter.

## 3. Quy trình phát triển

### Flutter App
```bash
cd App
flutter pub get
flutter run               # Chạy thiết bị đã kết nối
flutter test              # Chạy test
flutter build apk|ipa|windows|linux|web
```

### Next.js Admin
```bash
cd Admin
npm install
npm run dev               # http://localhost:3000
npm run lint
npm run build && npm run start
```

## 4. Biến môi trường

- `App/`: Cấu hình Firebase/API trong `lib/` hoặc file `.env` (tuỳ implement). Sao chép template nếu có.
- `Admin/`: Tạo `.env.local` với các biến backend (API base URL, Supabase, v.v.). Không commit file `.env*`.

## 5. Testing & QA

- Flutter: ưu tiên widget test, integration test (`integration_test/`).
- Next.js: kết hợp `jest`/`react-testing-library` (chưa cấu hình, có thể bổ sung).
- CI/CD: dễ dàng tích hợp GitHub Actions bằng cách chạy `flutter test` và `npm run test`.

## 6. Gợi ý mở rộng

1. Đồng bộ API giữa App và Admin (ví dụ sử dụng cùng backend hoặc Supabase).
2. Triển khai auth thực tế cho Admin (hiện đang mock).
3. Thêm localization, theming cho Flutter App.
4. Dùng Docker Compose ở root để chạy cả hai dịch vụ song song.

---

> **Mẹo:** Luôn chạy `flutter pub upgrade` / `npm update` định kỳ, và đảm bảo `.gitinorge` được áp dụng trước khi commit để tránh đẩy artefact build lên repo.


