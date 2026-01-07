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

  const loadComments = async () => {
    try {
      await keycloak.updateToken(30);
      const token = keycloak.token;
      if (!token) return;

      const res = await fetch(
        `${API}/api/images/${image.id}/comments`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!res.ok) return;

      const data = await res.json();
      setComments(Array.isArray(data) ? data : []);
    } catch {
      setComments([]);
    }
  };

  useEffect(() => {
    loadComments();
  }, [image.id]);

  const sendComment = async () => {
    if (text.trim().length === 0) return;

    try {
      await keycloak.updateToken(30);
      const token = keycloak.token;
      if (!token) return;

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

      if (!res.ok) return;

      await loadComments();
      setText("");
      setShowCommentBox(false);
    } catch { /* empty */ }
  };

  return (
    <div
      style={{
        background: "white",
        borderRadius: "12px",
        overflow: "hidden",
        boxShadow: "0 8px 20px rgba(0,0,0,0.08)",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* IMAGE */}
      <img
        src={image.url}
        alt={image.caption}
        loading="lazy"
        style={{
          width: "100%",
          height: "220px",
          objectFit: "cover",
          background: "#eee",
        }}
      />

      {/* META */}
      <div style={{ padding: "1rem" }}>
        <h4 style={{ margin: "0 0 0.3rem 0" }}>
          {image.caption || "Bez opisu"}
        </h4>
        <small style={{ color: "#6b7280" }}>
          {new Date(image.uploadTime).toLocaleString()}
        </small>
      </div>

      {/* COMMENTS */}
      <div style={{ padding: "0 1rem 1rem" }}>
        {comments.length === 0 && (
          <p style={{ fontStyle: "italic", color: "#9ca3af" }}>
            Brak komentarzy
          </p>
        )}

        {comments.map((c) => (
          <div
            key={c.id}
            style={{
              borderTop: "1px solid #eee",
              paddingTop: "0.5rem",
              marginTop: "0.5rem",
              fontSize: "0.9rem",
            }}
          >
            <strong>{c.authorEmail}</strong>
            <div>{c.text}</div>
            <small style={{ color: "#9ca3af" }}>
              {new Date(c.createdAt).toLocaleString()}
            </small>
          </div>
        ))}
      </div>

      {/* ACTIONS */}
      <div style={{ padding: "0 1rem 1rem" }}>
        <button onClick={() => setShowCommentBox(!showCommentBox)}>
          Skomentuj
        </button>

        {showCommentBox && (
          <div style={{ marginTop: "0.5rem" }}>
            <textarea
              value={text}
              maxLength={300}
              onChange={(e) => setText(e.target.value)}
              placeholder="Napisz komentarz…"
              style={{
                width: "100%",
                minHeight: "60px",
                marginBottom: "0.5rem",
              }}
            />
            <button onClick={sendComment} style={{ width: "100%" }}>
              Wyślij
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

