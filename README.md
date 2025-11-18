# Expenses Platform

Monorepo gom hai thành phần chính giúp theo dõi và phân tích chi tiêu cá nhân/doanh nghiệp:

- `App/`: ứng dụng Flutter đa nền tảng (mobile, desktop, web) tích hợp Supabase cho auth và dữ liệu.
- `Admin/`: backend Express + dashboard React/Vite phục vụ quản trị, thống kê và theo dõi người dùng.

## 1. Kiến trúc & code preview

```
expenses/
├─ App/                 # Flutter client (Riverpod, Supabase, clean UI)
│  ├─ lib/
│  │  ├─ core/          # Cấu hình Supabase (`supabase_flutter.dart`)
│  │  ├─ service/       # Tầng gọi Supabase (ví dụ `auth_service.dart`)
│  │  ├─ presentation/  # Screens, state, widgets
│  │  └─ data/          # Mẫu dữ liệu/UI seed
│  └─ docker*/          # Workflow chạy Flutter trong container
├─ Admin/
│  ├─ src/              # Server Express, routes, services
│  ├─ client/           # React + Material UI dashboard (Vite)
│  └─ config/           # Supabase client, middleware, utils
├─ .gitignore           # Quy tắc ignore toàn cục (Flutter + Node)
└─ README.md            # Tài liệu tổng quan (file hiện tại)
```

- Auth: `App/lib/service/auth_service.dart` gói `supabase_flutter` thành API đồng nhất (sign up/in/out, cập nhật người dùng, listeners).
- Người dùng & thống kê: `App/lib/service/user_service.dart` + `Admin/src/services/*.js` (mock data + REST).
- UI dashboard: `Admin/client/src` chứa `components/StatCard.jsx`, `hooks/useDashboardData.js`.

## 2. Yêu cầu môi trường

| Thành phần | Yêu cầu chính |
|------------|---------------|
| Flutter App | Flutter SDK ≥ 3.22, Dart ≥ 3, Android/iOS toolchain, Chrome (web), VS Build Tools (Desktop) |
| Admin Server | Node.js ≥ 18, npm ≥ 10, Supabase (hoặc REST API) cho dữ liệu |
| Admin Client | Node.js ≥ 18, npm ≥ 10, trình duyệt Chromium/Firefox mới nhất |
| Tuỳ chọn | Docker Desktop (App có `Dockerfile` & `docker-compose.yml`) |

## 3. Thiết lập nhanh (Quick start)

### Flutter App
```bash
cd App
flutter pub get
cp env.example env.development   # tạo file chứa SUPABASE_URL & SUPABASE_ANON_KEY
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...

# Test & build
flutter analyze
flutter test
flutter build apk|ipa|macos|windows|linux|web
```

### Admin backend + dashboard
```bash
cd Admin
npm install
cp .env.example .env.local       # khai báo API keys, SUPABASE_URL, JWT_SECRET
npm run dev                      # backend (mặc định :4000)

# Dashboard
cd client
npm install
cp .env.example .env.local       # VITE_API_BASE_URL, SUPABASE_ANON_KEY, ...
npm run dev                      # http://localhost:5173
```

## 4. Biến môi trường bắt buộc

| Thành phần | Biến chính | Ghi chú |
|------------|------------|---------|
| App (Flutter) | `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Truyền qua `--dart-define` hoặc `env.*` + script |
| Admin server | `PORT`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `JWT_SECRET` | Lưu trong `.env.local` (không commit) |
| Admin client | `VITE_API_BASE_URL`, `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` | Vite chỉ nhận biến prefix `VITE_` |

> Tip: tạo các file `env.example` tương ứng để dễ onboarding. Tất cả `.env*` đã được ignore trong repo.

## 5. Testing, lint & chất lượng

- Flutter: `flutter analyze`, `flutter test`, cân nhắc `flutter test integration_test`. Lưu kết quả tại `App/coverage/`.
- Admin server: thêm Jest/Supertest; hiện tại có thể chạy `npm run lint` + `npm run test` (khi cấu hình).
- Admin client: dùng `npm run lint` (ESLint + React). Có thể thêm Vitest/RTL.
- CI gợi ý:
  - Job 1: cài Flutter SDK, chạy `flutter analyze` + `flutter test`.
  - Job 2: Node 20, cache npm, chạy `npm run lint` ở `Admin` và `Admin/client`.

## 6. Ghi chú mở rộng

1. Supabase: `App/lib/core/supabase_flutter.dart` tạo singleton client; đảm bảo cấu hình `Supabase.initialize` trong `main.dart`.
2. UI: `App/lib/common/theme.dart` áp dụng `Material 3` với `seed color`, support dark/light.
3. Docker: `App/docker-compose.yml` hỗ trợ `flutter run -d web-server` với hot reload; thêm env trong file compose để tránh nhập tay.
4. Tài liệu chi tiết: xem `App/README.md` (Flutter) và các comment trong `Admin/src`.

---

> Luôn chạy `git status` trước khi commit để đảm bảo `.gitignore` đã loại bỏ build artefact. Repo hiện đã chuẩn hoá toàn bộ `.gitignore` cho Flutter, Android/iOS, Node.js và Vite.
