import keycloak from "./auth/keycloak.ts";

export async function initAuth(): Promise<void> {
  await keycloak.init({
    onLoad: "login-required",
    pkceMethod: "S256",
  });
}

export function getToken(): string | undefined {
  return keycloak.token;
}

export function getUserInfo() {
  if (!keycloak.tokenParsed) return null;

  return {
    username:
      keycloak.tokenParsed.email ||
      keycloak.tokenParsed.preferred_username ||
      keycloak.tokenParsed.sub,
  };
}

export function logout() {
  return keycloak.logout({
    redirectUri: window.location.origin,
  });
}
