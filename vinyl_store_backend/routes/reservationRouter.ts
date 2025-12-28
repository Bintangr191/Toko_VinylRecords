import { Hono } from "hono";
import {
  keepVinyl,
  getMyReservations,
  getAllReservations,
  updateReservationStatus
} from "../controllers/reservationController";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = new Hono();

// =======================
// USER routes
// =======================
router.post("/keep/:id", requireAuth, keepVinyl);
router.get("/my", requireAuth, getMyReservations);

// =======================
// ADMIN routes
// =======================
router.get("/all", requireAdmin, getAllReservations);
router.put("/:id/status", requireAdmin, updateReservationStatus);

export default router;
