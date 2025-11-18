import React from 'react';
import Link from 'next/link';
import styles from '../styles/dashboard.module.css';

const Sidebar: React.FC = () => {
    return (
        <div className={styles.sidebar}>
            <h2>Admin Menu</h2>
            <ul>
                <li>
                    <Link href="/admin/dashboard">Dashboard</Link>
                </li>
                <li>
                    <Link href="/admin/settings">Settings</Link>
                </li>
            </ul>
        </div>
    );
};

export default Sidebar;