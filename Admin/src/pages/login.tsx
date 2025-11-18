import React from 'react';
import LoginForm from '../components/LoginForm';
import Layout from '../components/Layout';

const LoginPage = () => {
    return (
        <Layout>
            <h1>Login</h1>
            <LoginForm />
        </Layout>
    );
};

export default LoginPage;