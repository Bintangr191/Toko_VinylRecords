import { Hono } from "hono";
import { cors } from "hono/cors";
import { connectDB } from "./db";
import vinylRoutes from "./routes/vinylRoutes";
import authRoutes from "./routes/authRoutes";
import catalogRoutes from "./routes/catalogRoutes";
import adminUserRoutes from "./routes/adminUserRoutes";
import reservationRoutes from "./routes/reservationRouter";
import whislistRoutes from "./routes/wishlist";
import adminReservation from "./routes/reservationAdminRoute";
import userRoutes from "./routes/user";
import path from "path";
import fs from "fs/promises";
import mime from "mime";

const app = new Hono();

// CORS middleware
app.use("*", cors());

// Connect MongoDB
connectDB();

// =======================================
//    STATIC FILE SERVE: /uploads/*
// =======================================
app.get("/uploads/:file{.+}", async (c) => {
  const filePath = c.req.param("file"); // menangkap full filename
  const fullPath = path.join(process.cwd(), "uploads", filePath);

  try {
    const data = await fs.readFile(fullPath);
    const contentType = mime.getType(fullPath) || "application/octet-stream";

    return c.body(data, 200, {
      "Content-Type": contentType,
      "Access-Control-Allow-Origin": "*",
    });
  } catch (err) {
    return c.json({ error: "File not found" }, 404);
  }
});

// Mount routes
app.route("/auth", authRoutes);
app.route("/vinyl", vinylRoutes);
app.route("/catalog", catalogRoutes);
app.route("/admin", adminUserRoutes);
app.route("/reservations", reservationRoutes);
app.route("/wishlist", whislistRoutes);
app.route("/admin/reservations", adminReservation);
app.route("/users", userRoutes);

// =======================================
//            RUN SERVER
// =======================================
import { serve } from "@hono/node-server";

serve(
  {
    fetch: app.fetch,
    port: 3000,
  },
  () => {
    console.log("Server running on http://localhost:3000");
  }
);
