import Keycloak from "keycloak-js";

console.log("Frontend URL:", import.meta.env.VITE_FRONTEND_URL);
console.log("KeyCloak URL:", import.meta.env.VITE_KEYCLOAK_URL);
console.log("KeyCloak Realm:", import.meta.env.VITE_KEYCLOAK_REALM);
console.log("KeyCloak Client ID:", import.meta.env.VITE_KEYCLOAK_CLIENT_ID);

const keycloak = new Keycloak({
  url: import.meta.env.VITE_KEYCLOAK_URL,
  realm: import.meta.env.VITE_KEYCLOAK_REALM,
  clientId: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
});

export default keycloak;
