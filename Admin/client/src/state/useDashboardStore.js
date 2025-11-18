import { create } from 'zustand';
import { fetchCategoryBreakdown, fetchExpenses, fetchOverview, fetchUsers } from '../api/adminApi';

const useDashboardStore = create((set) => ({
  isLoading: false,
  overview: null,
  categoryBreakdown: [],
  expenses: [],
  users: [],
  error: null,
  refresh: async () => {
    set({ isLoading: true, error: null });
    try {
      const [overview, categories, expenses, users] = await Promise.all([
        fetchOverview(),
        fetchCategoryBreakdown(),
        fetchExpenses(10),
        fetchUsers(10),
      ]);

      set({
        overview,
        categoryBreakdown: categories,
        expenses,
        users,
        isLoading: false,
      });
    } catch (error) {
      set({ error: error.message, isLoading: false });
    }
  },
}));

export default useDashboardStore;

