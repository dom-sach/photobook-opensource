import React, { createContext, useContext, type ReactNode } from "react";
import keycloak from "../auth/keycloak";

interface AuthContextType {
  isLoggedIn: boolean;
  username?: string;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

keycloak.init({
  onLoad: "login-required",
  pkceMethod: "S256",
});


// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
};

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const isLoggedIn = !!keycloak.authenticated;

  const username =
    keycloak.tokenParsed?.email ||
    keycloak.tokenParsed?.preferred_username;

  const logout = () => {
    keycloak.logout({ redirectUri: window.location.origin });
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, username, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
