import { Context } from "hono";
import User from "../models/User";
import bcrypt from "bcryptjs";

// =======================
// GET CURRENT USER
// =======================
export const getMe = async (c: Context) => {
  const currentUser = (c as any).currentUser;

  if (!currentUser) {
    return c.json({ message: "Unauthorized" }, 401);
  }

  const user = await User.findById(currentUser.id)
    .select("username role");

  if (!user) {
    return c.json({ message: "User tidak ditemukan" }, 404);
  }

  return c.json({
    _id: user._id,
    username: user.username,
    role: user.role,
  });
};

// =======================
// UPDATE PROFILE (USERNAME)
// =======================
export const updateProfile = async (c: Context) => {
  const currentUser = (c as any).currentUser;

  if (!currentUser) {
    return c.json({ message: "Unauthorized" }, 401);
  }

  const { username } = await c.req.json();

  if (!username || username.trim() === "") {
    return c.json({ message: "Username tidak boleh kosong" }, 400);
  }

  const updated = await User.findByIdAndUpdate(
    currentUser.id,         
    { username },
    { new: true }
  ).select("username role");

  if (!updated) {
    return c.json({ message: "User tidak ditemukan" }, 404);
  }

  return c.json({
    success: true,
    user: {
      _id: updated._id,
      username: updated.username,
      role: updated.role,
    },
  });
};

// =======================
// UPDATE PASSWORD
// =======================
export const updatePassword = async (c: Context) => {
  const currentUser = (c as any).currentUser;

  if (!currentUser) {
    return c.json({ message: "Unauthorized" }, 401);
  }

  const { oldPassword, newPassword } = await c.req.json();

  if (!oldPassword || !newPassword) {
    return c.json(
      { message: "Password lama & baru wajib diisi" },
      400
    );
  }

  const dbUser = await User.findById(currentUser.id); 

  if (!dbUser) {
    return c.json({ message: "User tidak ditemukan" }, 404);
  }

  const match = await bcrypt.compare(
    oldPassword,
    dbUser.password
  );

  if (!match) {
    return c.json(
      { message: "Password lama salah" },
      400
    );
  }

  const hashed = await bcrypt.hash(newPassword, 10);
  dbUser.password = hashed;
  await dbUser.save();

  return c.json({ success: true });
};