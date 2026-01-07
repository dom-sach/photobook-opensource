import { useEffect, useState } from "react";
import ImageCard from "./ImageCard";
import keycloak from "../auth/keycloak";
import type {ImageItem} from "../types/ImageItem.tsx";

export default function ImageGrid() {
  const [images, setImages] = useState<ImageItem[]>([]);
  const API = import.meta.env.VITE_BACKEND_URL;

  useEffect(() => {
    const loadImages = async () => {
      try {
        await keycloak.updateToken(30);
        const token = keycloak.token;
        if (!token) return;

        const res = await fetch(`${API}/api/images`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        console.log("Response from get images: ", res)

        if (!res.ok) return;
        const data: ImageItem[] = await res.json();
        setImages(data);
        console.log("Response data from getting images: ", data)
        console.log("IMAGE URL FROM BACKEND:", data[0].url);

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
        gridTemplateColumns: "repeat(auto-fill, minmax(350px, 1fr))",
        gap: "1.5rem",
        width: "100%",
      }}
    >
      {images.map((img) => (
        <ImageCard key={img.id} image={img} />
      ))}
    </div>
  );
}
