import { Hono } from "hono";
import {
  getUsers,
  getUserById,
  updateUserRole,
  deleteUser,
} from "../controllers/adminUserController";
import { requireAdmin } from "../middleware/auth";

const router = new Hono();

// semua route di sini admin-only
router.use("*", requireAdmin);

router.get("/users", getUsers);
router.get("/users/:id", getUserById);
router.put("/users/:id/role", updateUserRole);
router.delete("/users/:id", deleteUser);

export default router;