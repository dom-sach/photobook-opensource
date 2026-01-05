import { useEffect, useState } from "react";
import ImageCard from "./ImageCard";
import keycloak from "../auth/keycloak";

interface ImageItem {
  id: string;
  url: string;
  caption: string;
  uploadTime: string;
}

export default function ImageGrid() {
  const [images, setImages] = useState<ImageItem[]>([]);
  const API = import.meta.env.VITE_BACKEND_URL;

  useEffect(() => {
    const loadImages = async () => {
      try {
        // upewniamy się, że token jest aktualny
        await keycloak.updateToken(30);

        const token = keycloak.token;
        if (!token) {
          console.error("[ImageGrid] No Keycloak token available");
          return;
        }

        const res = await fetch(`${API}/api/images`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!res.ok) {
          const txt = await res.text();
          console.error(
            "[ImageGrid] Backend error:",
            res.status,
            txt
          );
          return;
        }

        const data = await res.json();
        setImages(data);
      } catch (err) {
        console.error("[ImageGrid] Failed to load images", err);
      }
    };

    loadImages();
  }, [API]);

  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "repeat(3, 1fr)",
        gap: "10px",
        maxWidth: "100%",
        margin: "auto",
      }}
    >
      {images.map((img) => (
        <ImageCard key={img.id} image={img} />
      ))}
    </div>
  );
}
