import { useState } from 'react';
import {useAuth} from "../contexts/AuthContext.tsx";
import {useNavigate} from "react-router-dom";
import ImageGrid from "../components/ImageGrid.tsx";
import keycloak from "../auth/keycloak";
import "../styles/Home.css";


export default function Home() {

  console.log("[Home.tsx] TOKEN PARSED:", keycloak.tokenParsed);

  // Constants
  const [showUpload, setShowUpload] = useState(false);
  const [file, setFile] = useState<File | null>(null);
  const [caption, setCaption] = useState('');
  const { logout } = useAuth();
  const navigate = useNavigate();

  // Logowanie
  const API = import.meta.env.VITE_BACKEND_URL;
  console.log("[Home] Logging backend URL = ", API);




  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  // Upload obrazka
  const handleUpload = async () => {
    if (!file) return;

    try {
      await keycloak.updateToken(30);
      const token = keycloak.token;

      if (!token) {
        console.error("[Upload] No token");
        return;
      }

      const formData = new FormData();
      formData.append("file", file);
      formData.append("caption", caption);

      const res = await fetch(`${API}/api/images`, {
        method: "POST",
        body: formData,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const text = await res.text();

      if (!res.ok) {
        console.error("[Upload] Backend error:", res.status, text);
        alert("Upload error: " + text);
        return;
      }

      console.log("[Upload] Success:", text);

      setShowUpload(false);
      setFile(null);
      setCaption("");
    } catch (err) {
      console.error("[Upload] Network error:", err);
    }
  };


  // Logout
  const handleLogout = () => {
    logout();
  };



  return (
    <div className="page">
      {/* Buttons */}
      <div className="actions">
        <button onClick={() => setShowUpload(true)}>Dodaj obrazek</button>
        <button className="secondary" onClick={handleLogout}>Wyloguj</button>
        <button className="secondary" onClick={() => navigate("/profile")}>
          Mój profil
        </button>
      </div>

      {/* Upload panel */}
      {showUpload && (
        <div className="upload-panel">
          <h3>Dodaj obrazek</h3>

          <input
            type="file"
            accept=".jpg,.png"
            onChange={handleFileChange}
          />

          <input
            type="text"
            placeholder="Podpis"
            value={caption}
            onChange={(e) => setCaption(e.target.value)}
          />

          <div className="upload-actions">
            <button onClick={handleUpload}>Wyślij</button>
            <button className="secondary" onClick={() => setShowUpload(false)}>
              Anuluj
            </button>
          </div>
        </div>
      )}

      {/* Gallery */}
      <div className="gallery">
        <ImageGrid />
      </div>
    </div>
  );

}