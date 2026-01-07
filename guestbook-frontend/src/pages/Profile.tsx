import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import keycloak from "../auth/keycloak.ts";

interface Profile {
  email: string;
  bio: string;
  favoriteColor: string;
}

export default function Profile() {
  const navigate = useNavigate();
  const API = import.meta.env.VITE_BACKEND_URL;

  const [profile, setProfile] = useState<Profile | null>(null);
  const [email, setEmail] = useState("");
  const [bio, setBio] = useState("");
  const [favoriteColor, setFavoriteColor] = useState("");

  useEffect(() => {
    const loadProfile = async () => {
      try {
        // @ts-ignore
        await keycloak.updateToken(30);
        // @ts-ignore
        const token = keycloak.token;

        if (!token) return;

        const res = await fetch(`${API}/api/profile`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!res.ok) {
          console.error("Profile fetch failed", res.status);
          return;
        }

        const data = await res.json();
        setProfile(data);
        setEmail(data.email);
        setBio(data.bio);
        setFavoriteColor(data.favoriteColor);

      } catch (err) {
        console.error("Błąd pobierania profilu:", err);
      }
    };

    loadProfile();
  }, [API]);


  // Aktualizacja profilu
  const handleSave = async () => {
    // @ts-ignore
    await keycloak.updateToken(30);
    // @ts-ignore
    const token = keycloak.token;

    await fetch(`${API}/api/profile`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        bio,
        favoriteColor,
      }),
    });

    alert("Zapisano!");
  };



  if (!profile) return <p>Ładowanie profilu...</p>;

  return (
    <div style={{ width: "60%", margin: "auto", marginTop: "2rem" }}>
      <h2>Mój Profil</h2>

      <p><strong>Id:</strong> {email}</p>

      <label>Bio:</label>
      <textarea
        value={bio}
        onChange={(e) => setBio(e.target.value)}
        maxLength={300}
        style={{ width: "100%", minHeight: "80px", marginBottom: "1rem" }}
      />

      <label>Ulubiony kolor:</label>
      <input
        type="text"
        value={favoriteColor}
        onChange={(e) => setFavoriteColor(e.target.value)}
        placeholder="np. red, blue, #ffcc00"
        style={{ width: "100%", lineHeight: "2rem", marginBottom: "1rem" }}
      />

      <div style={{ display: "flex", gap: "1rem" }}>
        <button onClick={handleSave} style={{ width: "40%" }}>
          Zapisz
        </button>

        <button onClick={() => navigate("/")} style={{ width: "40%" }}>
          Powrót
        </button>
      </div>
    </div>
  );
}
