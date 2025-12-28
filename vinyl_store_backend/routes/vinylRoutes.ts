import { Hono } from "hono";
import {
  getVinyls,
  getVinyl,
  createVinyl,
  updateVinyl,
  deleteVinyl,
  uploadImage,
  uploadAudio
} from "../controllers/vinylController";
import { requireAdmin } from "../middleware/auth";

const router = new Hono();

// Public (user bisa lihat)
router.get("/", getVinyls);
router.get("/:id", getVinyl);

// Admin only
router.post("/", requireAdmin, createVinyl);
router.put("/:id", requireAdmin, updateVinyl);
router.delete("/:id", requireAdmin, deleteVinyl);

// Upload image/audio
router.post("/:id/image", requireAdmin, uploadImage);
router.post("/:id/audio", requireAdmin, uploadAudio);

export default router;