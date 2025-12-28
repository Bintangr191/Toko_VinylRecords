import { Hono } from "hono";
import {
  keepVinyl,
  getMyReservations,
} from "../controllers/reservationController";
import {requireAuth} from "../middleware/auth";

const router = new Hono();

// =======================
// USER routes
// =======================
router.post("/keep/:id", requireAuth, keepVinyl);
router.get("/my", requireAuth, getMyReservations);

export default router;
