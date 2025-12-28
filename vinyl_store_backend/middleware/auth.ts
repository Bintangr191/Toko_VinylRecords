import type { Context, Next } from "hono";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET!;
if (!JWT_SECRET) throw new Error("Missing JWT_SECRET");

export const requireAuth = async (c: Context, next: Next) => {
  const header = c.req.header("Authorization");

  if (!header || !header.startsWith("Bearer ")) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  try {
    const token = header.split(" ")[1];
    const decoded = jwt.verify(token, JWT_SECRET) as any;

    // ⚠ pastikan controller bisa akses currentUser
    (c as any).currentUser = decoded;

    return next(); // wajib return
  } catch (err) {
    return c.json({ error: "Invalid token" }, 401);
  }
};

export const requireAdmin = async (c: Context, next: Next) => {
  return requireAuth(c, async () => {
    const currentUser = (c as any).currentUser;

    if (!currentUser || currentUser.role !== "admin") {
      return c.json({ error: "Forbidden (Admin only)" }, 403);
    }

    return next();
  });
};