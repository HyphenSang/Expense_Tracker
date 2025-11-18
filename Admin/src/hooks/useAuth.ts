import { useState } from 'react';

const useAuth = () => {
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    const login = async (credentials) => {
        const response = await fetch('/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(credentials),
        });

        if (response.ok) {
            setIsAuthenticated(true);
            return true;
        } else {
            return false;
        }
    };

    const logout = () => {
        setIsAuthenticated(false);
    };

    return {
        isAuthenticated,
        login,
        logout,
    };
};

export default useAuth;