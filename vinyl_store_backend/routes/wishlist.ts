import { Hono } from "hono";
import { requireAuth } from "../middleware/auth";
import {
  toggleWishlist,
  getMyWishlist,
  isWishlisted,
} from "../controllers/wishlistController";

const router = new Hono();

router.post("/:id", requireAuth, toggleWishlist);
router.get("/my", requireAuth, getMyWishlist);
router.get("/check/:id", requireAuth, isWishlisted);

export default router;