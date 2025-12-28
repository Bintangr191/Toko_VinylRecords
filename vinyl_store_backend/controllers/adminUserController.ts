import type { Context } from "hono";
import User from "../models/User";

/**
 * GET /admin/users
 */
export const getUsers = async (c: Context) => {
  const users = await User.find().select("-password").sort({ createdAt: -1 });
  return c.json(users);
};

/**
 * GET /admin/users/:id
 */
export const getUserById = async (c: Context) => {
  const id = c.req.param("id");
  const user = await User.findById(id).select("-password");

  if (!user) return c.json({ error: "User not found" }, 404);

  return c.json(user);
};

/**
 * PUT /admin/users/:id/role
 */
export const updateUserRole = async (c: Context) => {
  const id = c.req.param("id");
  const { role } = await c.req.json();
  const currentUser = (c as any).currentUser;

  if (!currentUser) return c.json({ error: "Unauthorized" }, 401);

  // Ambil user target dari DB
  const targetUser = await User.findById(id);
  if (!targetUser) return c.json({ error: "User not found" }, 404);

  // ❌ Tidak bisa ubah role sendiri
  if (currentUser.id.toString() === targetUser.id.toString()) {
    return c.json({ error: "Tidak bisa mengubah role sendiri" }, 403);
  }

  if (!["admin", "user"].includes(role)) {
    return c.json({ error: "Invalid role" }, 400);
  }

  targetUser.role = role;
  await targetUser.save();

  return c.json(targetUser);
};

/**
 * DELETE /admin/users/:id
 */
export const deleteUser = async (c: Context) => {
  const id = c.req.param("id");
  const currentUser = (c as any).currentUser;

  if (!currentUser) return c.json({ error: "Unauthorized" }, 401);

  // Ambil target user dari DB
  const targetUser = await User.findById(id);
  if (!targetUser) return c.json({ error: "User not found" }, 404);

  // ❌ Tidak bisa hapus akun sendiri
  if (currentUser.id.toString() === targetUser.id.toString()) {
    return c.json({ error: "Tidak bisa menghapus akun sendiri" }, 403);
  }

  // Opsional: cek user sedang aktif (misal field isActive)
  if (targetUser.isActive) {
    return c.json({ error: "User sedang aktif, tidak bisa dihapus" }, 403);
  }

  await User.findByIdAndDelete(id);

  return c.json({ message: "User deleted" });
};