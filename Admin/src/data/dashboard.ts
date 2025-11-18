import { ActivityLog, BudgetItem, RecentExpense } from '../types';

export const quickStats = [
  {
    id: 'monthly',
    title: 'Chi tiêu tháng này',
    value: '52.4M ₫',
    trend: '+12% so với tháng trước',
    trendType: 'positive' as const
  },
  {
    id: 'pending',
    title: 'Yêu cầu hoàn ứng',
    value: '18 yêu cầu',
    trend: '5 đang chờ duyệt',
    trendType: 'neutral' as const
  },
  {
    id: 'budget',
    title: 'Ngân sách còn lại',
    value: '147.6M ₫',
    trend: '58% đã dùng',
    trendType: 'negative' as const
  }
];

export const expenseTrends = [
  { month: 'T1', expenses: 21 },
  { month: 'T2', expenses: 24 },
  { month: 'T3', expenses: 28 },
  { month: 'T4', expenses: 32 },
  { month: 'T5', expenses: 31 },
  { month: 'T6', expenses: 36 }
];

export const recentExpenses: RecentExpense[] = [
  {
    id: 'EXP-2044',
    category: 'Marketing',
    amount: 8200000,
    date: '2025-11-15',
    status: 'Đã duyệt'
  },
  {
    id: 'EXP-2039',
    category: 'Đi công tác',
    amount: 12400000,
    date: '2025-11-12',
    status: 'Chờ duyệt'
  },
  {
    id: 'EXP-2033',
    category: 'Vận hành',
    amount: 5600000,
    date: '2025-11-09',
    status: 'Đã duyệt'
  },
  {
    id: 'EXP-2025',
    category: 'Cơ sở hạ tầng',
    amount: 9900000,
    date: '2025-11-04',
    status: 'Từ chối'
  }
];

export const budgetItems: BudgetItem[] = [
  {
    id: 'marketing',
    title: 'Marketing',
    spent: 68,
    limit: 100
  },
  {
    id: 'ops',
    title: 'Vận hành',
    spent: 54,
    limit: 100
  },
  {
    id: 'rd',
    title: 'R&D',
    spent: 32,
    limit: 100
  }
];

export const activities: ActivityLog[] = [
  {
    id: 'ACT-1',
    description: 'Phòng Marketing tạo yêu cầu hoàn ứng 8.2M ₫',
    time: '10 phút trước'
  },
  {
    id: 'ACT-2',
    description: 'Bạn đã duyệt chi phí đi công tác của nhóm Sales',
    time: '2 giờ trước'
  },
  {
    id: 'ACT-3',
    description: 'Phòng R&D cập nhật kế hoạch ngân sách Q1',
    time: 'Hôm qua'
  }
];


