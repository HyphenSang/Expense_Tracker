import React from 'react';
import Layout from '../../components/Layout';
import Header from '../../components/Header';
import Sidebar from '../../components/Sidebar';

const Dashboard = () => {
    return (
        <Layout>
            <Header />
            <div className="dashboard-container">
                <Sidebar />
                <main className="dashboard-content">
                    <h1>Admin Dashboard</h1>
                    <p>Welcome to the admin dashboard. Here you can manage your application settings and view analytics.</p>
                </main>
            </div>
        </Layout>
    );
};

export default Dashboard;