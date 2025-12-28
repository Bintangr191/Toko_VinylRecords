import { Hono } from "hono";
import { register, login } from "../controllers/authController";

const router = new Hono();

router.post("/login", login);
router.post("/register", register);

export default router;