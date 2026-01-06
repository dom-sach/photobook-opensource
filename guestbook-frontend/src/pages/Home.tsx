import { useState } from 'react';
import {useAuth} from "../contexts/AuthContext.tsx";
import {useNavigate} from "react-router-dom";
import ImageGrid from "../components/ImageGrid.tsx";
import keycloak from "../auth/keycloak";

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
    <div>
      <div style={{
        display: 'flex',
        flexDirection: 'row',
        margin: 'auto',
        width: '80%',
        justifyContent: 'center'
      }} >
        {/* Przyciski */}
        <button style={{
          display: 'flex',
          margin: 'auto',
          marginBottom: '2rem',
          marginTop: '2rem',
          fontSize: '1rem',
        }} onClick={() => setShowUpload(true)}>
          Dodaj obrazek
        </button>

        <button style={{
          display: 'flex',
          margin: 'auto',
          marginBottom: '2rem',
          marginTop: '2rem',
          fontSize: '1rem',
        }} onClick={handleLogout}>
          Wyloguj
        </button>

        <button
          style={{
            display: 'flex',
            margin: 'auto',
            marginBottom: '2rem',
            marginTop: '2rem',
            fontSize: '1rem',
          }}
          onClick={() => navigate("/profile")}
        >
          Mój Profil
        </button>
      </div>



      {/* Dodawanie nowego obrazka */}
      {showUpload && (
        <div style={{
          width: '80%',
          margin: 'auto',
          marginBottom: '2rem',
          display: 'flex',
          flexDirection: 'column',
        }}>
          <h3>Dodaj obrazek</h3>
          <input
            type="file"
            style={{
              lineHeight: '2rem',
            }}
            accept=".jpg,.png"
            onChange={handleFileChange}/>

          <input
            type="text"
            style={{
              lineHeight: '2rem',
            }}
            placeholder="Podpis"
            value={caption}
            onChange={(e) => setCaption(e.target.value)}
          />

          <div style={{
            display: 'flex',
            width: '100%',
            margin: 'auto',
            flexDirection: 'row',
            justifyContent: 'space-around',
            alignContent: 'space-around',
          }}>
            <button
              onClick={handleUpload}
              style={{
                width: '30%',
              }}>
              Wyślij
            </button>

            <button
              onClick={() => setShowUpload(false)}
              style={{
                width: '30%',
              }}>
              Anuluj
            </button>

          </div>

        </div>
      )}

      {/* Lista wszystkich obrazków */}
      <div style={{marginTop: "2rem"}}>
        <ImageGrid/>
      </div>


    </div>
  );
}