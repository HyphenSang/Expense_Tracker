import React from 'react';
import Header from './Header';
import Sidebar from './Sidebar';
import styles from '../styles/dashboard.module.css';

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    return (
        <div className={styles.layout}>
            <Header />
            <div className={styles.container}>
                <Sidebar />
                <main className={styles.main}>
                    {children}
                </main>
            </div>
        </div>
    );
};

export default Layout;