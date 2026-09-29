const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for all origins (or customize for your Vercel domain)
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// In-Memory Database (Seeded with Figma data)
let userData = {
  id: 'user_01',
  firstName: 'Rahul',
  lastName: 'Sharma',
  email: 'sharahul@ledgerly.in',
  phone: '+91 98765 43210'
};

let budgetData = {
  month: 'April 2026',
  totalBudget: 50000.0,
  categories: [
    { id: 'cat_food', name: 'Food', subtitle: 'Groceries & Dining', allocated: 10000.0, spent: 8000.0, recommended: 10500.0, color: '#FB923C' },
    { id: 'cat_travel', name: 'Travel', subtitle: 'Commute & Trips', allocated: 5000.0, spent: 3200.0, recommended: 4500.0, color: '#3B82F6' },
    { id: 'cat_rent', name: 'Rent', subtitle: 'House & Maintenance', allocated: 15000.0, spent: 15000.0, recommended: 22000.0, color: '#8B5CF6' },
    { id: 'cat_shopping', name: 'Shopping', subtitle: 'Apparel & Personal', allocated: 6000.0, spent: 5250.0, recommended: 11000.0, color: '#EC4899' },
    { id: 'cat_bills', name: 'Bills', subtitle: 'Utilities & Subs', allocated: 14000.0, spent: 1000.0, recommended: 7000.0, color: '#EF4444' }
  ]
};

let transactionsData = [
  {
    id: 'tx_01',
    title: 'Chroma',
    amount: 1290.00,
    type: 'expense',
    category: 'Electronics',
    date: new Date().toISOString(),
    paymentMode: 'Bank Account',
    note: 'USB-C Cable and adapter'
  },
  {
    id: 'tx_02',
    title: 'Starbucks',
    amount: 650.00,
    type: 'expense',
    category: 'Food',
    date: new Date(Date.now() - 86400000).toISOString(),
    paymentMode: 'UPI',
    note: 'Caramel Macchiato & Croissant'
  },
  {
    id: 'tx_03',
    title: 'Salary Deposit',
    amount: 42000.00,
    type: 'income',
    category: 'Salary',
    date: new Date(Date.now() - 172800000).toISOString(),
    paymentMode: 'HDFC Direct',
    note: 'Monthly salary credit'
  },
  {
    id: 'tx_04',
    title: 'Blue Tokai Coffee',
    amount: 340.00,
    type: 'expense',
    category: 'Food',
    date: new Date(Date.now() - 259200000).toISOString(),
    paymentMode: 'UPI'
  },
  {
    id: 'tx_05',
    title: 'Pizza Hut',
    amount: 1290.00,
    type: 'expense',
    category: 'Food',
    date: new Date(Date.now() - 345600000).toISOString(),
    paymentMode: 'Credit Card'
  },
  {
    id: 'tx_06',
    title: 'Burger King',
    amount: 560.00,
    type: 'expense',
    category: 'Food',
    date: new Date(Date.now() - 432000000).toISOString(),
    paymentMode: 'UPI'
  },
  {
    id: 'tx_07',
    title: 'The Social',
    amount: 4800.00,
    type: 'expense',
    category: 'Food',
    date: new Date(Date.now() - 518400000).toISOString(),
    paymentMode: 'Credit Card'
  }
];

let notificationsData = [
  {
    id: 'notif_01',
    title: 'Savings Milestone Achieved',
    time: '2h ago',
    group: 'TODAY',
    description: 'Congratulations! You have spent ₹300 less than your set budget for travel.',
    type: 'milestone'
  },
  {
    id: 'notif_02',
    title: 'Budget Alert: Food',
    time: '5h ago',
    group: 'TODAY',
    description: 'You have spent more today than usual in food. Consider reviewing your daily limit.',
    type: 'alert'
  },
  {
    id: 'notif_03',
    title: 'Monthly Report Ready',
    time: 'Yesterday',
    group: 'YESTERDAY',
    description: 'Monthly Analytics for May are now ready to view. Tap to see your spending breakdown.',
    type: 'report'
  },
  {
    id: 'notif_04',
    title: 'Bank Account Synced',
    time: 'Yesterday',
    group: 'YESTERDAY',
    description: 'Your HDFC Bank account has been successfully re-synced for automated tracking.',
    type: 'sync'
  }
];

// --- ROUTES ---

// Root & Health Check
app.get('/', (req, res) => {
  res.json({
    app: 'Ledgerly Backend API',
    status: 'online',
    version: '1.0.0',
    documentation: '/api/health'
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// User Profile
app.get('/api/user', (req, res) => {
  res.json({ success: true, data: userData });
});

app.put('/api/user', (req, res) => {
  userData = { ...userData, ...req.body };
  res.json({ success: true, data: userData });
});

// Authentication
app.post('/api/auth/login', (req, res) => {
  const { phone } = req.body;
  if (!phone) {
    return res.status(400).json({ success: false, message: 'Phone number is required' });
  }
  userData.phone = phone;
  res.json({
    success: true,
    message: 'OTP sent successfully',
    otp: '123456' // Mock OTP
  });
});

app.post('/api/auth/signup', (req, res) => {
  const { firstName, lastName, email, phone } = req.body;
  if (!firstName || !email) {
    return res.status(400).json({ success: false, message: 'First name and email are required' });
  }
  userData = {
    id: `user_${Date.now()}`,
    firstName,
    lastName: lastName || '',
    email,
    phone: phone || ''
  };
  res.json({ success: true, data: userData });
});

// Budget Endpoints
app.get('/api/budget', (req, res) => {
  const totalSpent = budgetData.categories.reduce((sum, c) => sum + c.spent, 0);
  const totalRemaining = Math.max(0, budgetData.totalBudget - totalSpent);
  const percentageUsed = budgetData.totalBudget > 0 ? (totalSpent / budgetData.totalBudget) : 0;

  res.json({
    success: true,
    data: {
      ...budgetData,
      totalSpent,
      totalRemaining,
      percentageUsed: Math.round(percentageUsed * 100),
      dailyLimit: Math.round(budgetData.totalBudget / 30)
    }
  });
});

app.put('/api/budget', (req, res) => {
  const { totalBudget, categories } = req.body;
  if (totalBudget) budgetData.totalBudget = Number(totalBudget);
  if (categories && Array.isArray(categories)) {
    budgetData.categories = categories;
  }
  res.json({ success: true, message: 'Budget updated successfully', data: budgetData });
});

// Transactions Endpoints
app.get('/api/transactions', (req, res) => {
  const { type, category } = req.query;
  let filtered = [...transactionsData];

  if (type) {
    filtered = filtered.filter(tx => tx.type.toLowerCase() === type.toLowerCase());
  }
  if (category) {
    filtered = filtered.filter(tx => tx.category.toLowerCase() === category.toLowerCase());
  }

  res.json({
    success: true,
    count: filtered.length,
    data: filtered
  });
});

app.post('/api/transactions', (req, res) => {
  const { title, amount, type, category, paymentMode, note, transferTo, date } = req.body;

  if (!amount || !category) {
    return res.status(400).json({ success: false, message: 'Amount and category are required' });
  }

  const newTx = {
    id: `tx_${Date.now()}`,
    title: title || category,
    amount: Number(amount),
    type: type || 'expense',
    category,
    paymentMode: paymentMode || 'Bank Account',
    note: note || '',
    transferTo: transferTo || null,
    date: date || new Date().toISOString()
  };

  transactionsData.unshift(newTx);

  // Update budget category spent if expense
  if (newTx.type === 'expense') {
    const cat = budgetData.categories.find(c => c.name.toLowerCase() === category.toLowerCase());
    if (cat) {
      cat.spent += newTx.amount;
    }
  }

  res.status(201).json({ success: true, data: newTx });
});

app.delete('/api/transactions/:id', (req, res) => {
  const { id } = req.params;
  const initialLength = transactionsData.length;
  transactionsData = transactionsData.filter(tx => tx.id !== id);

  if (transactionsData.length === initialLength) {
    return res.status(404).json({ success: false, message: 'Transaction not found' });
  }

  res.json({ success: true, message: 'Transaction deleted' });
});

// Analytics Overview
app.get('/api/analytics', (req, res) => {
  res.json({
    success: true,
    month: 'October 2023',
    totalSpent: 42800.0,
    donutShares: [
      { category: 'Housing', percent: 45, color: '#0D1424' },
      { category: 'Transport', percent: 25, color: '#047857' },
      { category: 'Dining', percent: 15, color: '#64748B' },
      { category: 'Other', percent: 15, color: '#CBD5E1' }
    ],
    categoryBreakdown: [
      { name: 'Rent', subtitle: 'Mortgage & Utilities', amount: 19260.00, percent: '45.0%', progress: 0.45 },
      { name: 'Travel', subtitle: 'Fuel & Transit', amount: 10700.00, percent: '25.0%', progress: 0.25 },
      { name: 'Dining', subtitle: 'Restaurants & Bars', amount: 6420.00, percent: '15.0%', progress: 0.15 }
    ],
    smartInsight: 'Your dining spend is 12% lower than last month. Keep it up!'
  });
});

// Ledgerly AI Financial Assistant
app.post('/api/ai/chat', (req, res) => {
  const { query } = req.body;
  const lower = (query || '').toLowerCase();

  let answer = "Based on your spending patterns, you've used 65% of your ₹50,000 budget with 14 days remaining.";
  let insight = "You are on track to save ₹6,200 this month if current trajectory continues!";

  if (lower.includes('dining') || lower.includes('food')) {
    answer = "You spent ₹3,420 on Food & Dining last week across 4 visits.";
    insight = "This is 15% lower than your weekly average. Great job staying on track!";
  } else if (lower.includes('summarize') || lower.includes('month')) {
    answer = "Total monthly outflow is ₹32,450 across 5 categories. Dining (₹12,450) and Rent (₹15,000) are your largest expenditures.";
    insight = "Rent is 100% fulfilled. Dining has 17% buffer remaining.";
  } else if (lower.includes('over budget') || lower.includes('budget')) {
    answer = "You are currently within safe limits! Only Housing/Rent reached its exact threshold (₹15,000).";
    insight = "Bills & Utilities are 93% under budget (₹1,000 spent out of ₹14,000).";
  }

  res.json({
    success: true,
    data: {
      answer,
      insight,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }
  });
});

// Notifications
app.get('/api/notifications', (req, res) => {
  res.json({
    success: true,
    data: notificationsData
  });
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Ledgerly API server running on port ${PORT}`);
});
