import type { Context } from "hono";
import User from "../models/User";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import dotenv from "dotenv";

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET!;

// REGISTER
export const register = async (c: Context) => {
  try {
    const body = await c.req.json();

    const { username, password, role } = body;

    if (!username || !password) {
      return c.json({ error: "username & password required" }, 400);
    }

    const exists = await User.findOne({ username });

    if (exists) {
      return c.json({ error: "User already exists" }, 400);
    }

    const hashed = await bcrypt.hash(password, 10);

    const newUser = await User.create({
      username,
      password: hashed,
      role: role || "user",
    });

    return c.json({ message: "User registered", user: newUser }, 201);
  } catch (error) {
    return c.json({ error: "Register failed" }, 500);
  }
};

// LOGIN (SUDAH DIPERBAIKI)
export const login = async (c: Context) => {
  try {
    const body = await c.req.json();
    const { username, password } = body;

    const user = await User.findOne({ username });

    if (!user) {
      return c.json({ error: "User not found" }, 404);
    }

    const valid = await bcrypt.compare(password, user.password);

    if (!valid) {
      return c.json({ error: "Invalid password" }, 401);
    }

    // sign token
    const token = jwt.sign(
      { id: user._id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: "1d" }
    );

    // 🔥 Perbaikan ada di sini → kirim data user + token
    return c.json({
      message: "Login success",
      token,
      user: {
        _id: user._id,
        username: user.username,
        role: user.role
      }
    });
  } catch (err) {
    return c.json({ error: "Login failed" }, 500);
  }
};