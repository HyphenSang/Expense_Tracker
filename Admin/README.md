# Next Admin Dashboard

This project is a static admin dashboard built with React and Next.js. It features a login functionality without registration, allowing users to access the admin dashboard after successful authentication.

## Project Structure

```
next-admin-dashboard
├── src
│   ├── pages
│   │   ├── _app.tsx
│   │   ├── _document.tsx
│   │   ├── index.tsx
│   │   ├── login.tsx
│   │   └── admin
│   │       ├── dashboard.tsx
│   │       └── settings.tsx
│   ├── components
│   │   ├── Layout.tsx
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   └── LoginForm.tsx
│   ├── hooks
│   │   └── useAuth.ts
│   ├── lib
│   │   └── auth.ts
│   ├── utils
│   │   └── withAuth.tsx
│   ├── styles
│   │   ├── globals.css
│   │   └── dashboard.module.css
│   └── types
│       └── index.ts
├── package.json
├── tsconfig.json
├── next.config.js
├── .eslintrc.json
└── README.md
```

## Features

- **Login Page**: Users can log in using their credentials.
- **Admin Dashboard**: Accessible only after successful login, displaying admin-related information.
- **Settings Page**: Allows configuration of various settings for the admin dashboard.

## Getting Started

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd next-admin-dashboard
   ```

3. Install dependencies:
   ```
   npm install
   ```

4. Run the development server:
   ```
   npm run dev
   ```

5. Open your browser and go to `http://localhost:3000` to view the application.

## Usage

- Navigate to the login page to enter your credentials.
- Upon successful login, you will be redirected to the admin dashboard.
- Use the sidebar for navigation between the dashboard and settings.

## License

This project is licensed under the MIT License.