import { Navigate, Route, Routes } from 'react-router-dom';

import DashboardLayout from './layouts/DashboardLayout';
import DashboardPage from './pages/DashboardPage';
import ExpensesPage from './pages/ExpensesPage';
import UsersPage from './pages/UsersPage';

const App = () => (
  <Routes>
    <Route element={<DashboardLayout />}>
      <Route index element={<DashboardPage />} />
      <Route path="expenses" element={<ExpensesPage />} />
      <Route path="users" element={<UsersPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Route>
  </Routes>
);

export default App;

