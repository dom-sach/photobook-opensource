import { useEffect, useState } from "react";
import keycloak from "../auth/keycloak";

interface Comment {
  id: string;
  text: string;
  authorEmail: string;
  createdAt: string;
}

interface ImageItem {
  id: string;
  url: string;
  caption: string;
  uploadTime: string;
}

export default function ImageCard({ image }: { image: ImageItem }) {
  const API = import.meta.env.VITE_BACKEND_URL;

  const [comments, setComments] = useState<Comment[]>([]);
  const [showCommentBox, setShowCommentBox] = useState(false);
  const [text, setText] = useState("");

  // 🔁 wspólna funkcja do pobierania komentarzy
  const loadComments = async () => {
    try {
      await keycloak.updateToken(30);

      const token = keycloak.token;
      if (!token) {
        console.error("[ImageCard] No Keycloak token");
        setComments([]);
        return;
      }

      const res = await fetch(`${API}/api/images/${image.id}/comments`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const txt = await res.text();
        console.error(
          "[ImageCard] Failed to load comments:",
          res.status,
          txt
        );
        setComments([]);
        return;
      }

      const data = await res.json();
      setComments(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error("[ImageCard] Comment fetch error", err);
      setComments([]);
    }
  };

  // 🔄 pobranie komentarzy po załadowaniu karty
  useEffect(() => {
    loadComments();
  }, [image.id]);

  // ✍️ wysyłanie komentarza
  const sendComment = async () => {
    if (text.trim().length === 0 || text.length > 300) return;

    try {
      await keycloak.updateToken(30);
      const token = keycloak.token;

      if (!token) {
        console.error("[ImageCard] No token on sendComment");
        return;
      }

      const res = await fetch(
        `${API}/api/images/${image.id}/comments`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ text }),
        }
      );

      if (!res.ok) {
        const txt = await res.text();
        console.error(
          "[ImageCard] Failed to send comment:",
          res.status,
          txt
        );
        return;
      }

      // 🔄 odśwież komentarze po sukcesie
      await loadComments();

      setText("");
      setShowCommentBox(false);
    } catch (err) {
      console.error("[ImageCard] Send comment error", err);
    }
  };

  return (
    <div style={{ border: "1px solid #ccc", padding: "10px" }}>
      <img src={image.url} alt={image.caption} style={{ width: "100%" }} />

      <h4 style={{ marginTop: "1rem" }}>{image.caption}</h4>
      <small>{new Date(image.uploadTime).toLocaleDateString()}</small>

      <hr />

      {/* Lista komentarzy */}
      <div>
        <h4>Komentarze:</h4>

        {comments.length === 0 && (
          <p style={{ fontStyle: "italic", color: "#777" }}>
            Brak komentarzy.
          </p>
        )}

        {comments.map((c) => (
          <div key={c.id} style={{ marginBottom: "0.8rem" }}>
            <strong>User:</strong> {c.authorEmail} <br />
            <span>{c.text}</span> <br />
            <small style={{ color: "#777" }}>
              {new Date(c.createdAt).toLocaleDateString()}
            </small>
          </div>
        ))}
      </div>

      {/* Przycisk */}
      <button
        style={{ marginTop: "0.5rem" }}
        onClick={() => setShowCommentBox(!showCommentBox)}
      >
        Skomentuj
      </button>

      {/* Formularz komentarza */}
      {showCommentBox && (
        <div style={{ marginTop: "1rem" }}>
          <textarea
            placeholder="Napisz komentarz (max 300 znaków)"
            maxLength={300}
            value={text}
            onChange={(e) => setText(e.target.value)}
            style={{ width: "100%", minHeight: "60px" }}
          />

          <button
            onClick={sendComment}
            style={{ marginTop: "0.5rem", width: "100%" }}
          >
            Wyślij
          </button>
        </div>
      )}
    </div>
  );
}
