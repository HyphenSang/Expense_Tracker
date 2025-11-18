import type { NextApiRequest, NextApiResponse } from 'next';

const users = [
  {
    username: 'admin',
    password: 'admin123',
    email: 'admin@expenses.app',
    role: 'admin'
  }
];

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'POST') {
    const { username, password } = req.body;

    const user = users.find(
      (user) => user.username === username && user.password === password
    );

    if (user) {
      res.status(200).json({
        message: 'Login successful',
        token: 'demo-token',
        user: {
          username: user.username,
          email: user.email,
          role: user.role
        }
      });
    } else {
      res.status(401).json({ message: 'Invalid credentials' });
    }
  } else {
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}