import React from 'react';

const Header: React.FC = () => {
    return (
        <header>
            <h1>Admin Dashboard</h1>
            <nav>
                <ul>
                    <li><a href="/admin/dashboard">Dashboard</a></li>
                    <li><a href="/admin/settings">Settings</a></li>
                </ul>
            </nav>
        </header>
    );
};

export default Header;