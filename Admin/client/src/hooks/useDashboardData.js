import { useEffect } from 'react';
import useDashboardStore from '../state/useDashboardStore';

const useDashboardData = () => {
  const { overview, categoryBreakdown, expenses, users, isLoading, error, refresh } = useDashboardStore();

  useEffect(() => {
    refresh();
  }, [refresh]);

  return { overview, categoryBreakdown, expenses, users, isLoading, error, refresh };
};

export default useDashboardData;

