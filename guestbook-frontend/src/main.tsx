import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { AuthProvider } from "./contexts/AuthContext";
import keycloak from "./auth/keycloak.ts";

async function bootstrap() {
  try {
    await keycloak.init({
      onLoad: "login-required",
      pkceMethod: "S256",
    });

    ReactDOM.createRoot(document.getElementById("root")!).render(
      <React.StrictMode>
        <AuthProvider>
          <App />
        </AuthProvider>
      </React.StrictMode>
    );
  } catch (err) {
    console.error("Keycloak init failed", err);
  }
}

bootstrap();
