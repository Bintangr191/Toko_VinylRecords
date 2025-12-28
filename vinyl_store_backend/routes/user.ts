// routes/user.ts
import { Hono } from "hono";
import { requireAuth } from "../middleware/auth";
import {
  getMe,
  updateProfile,
  updatePassword
} from "../controllers/userController";

const router = new Hono();

router.get("/me", requireAuth, getMe);
router.put("/profile", requireAuth, updateProfile);
router.put("/password", requireAuth, updatePassword);

export default router;