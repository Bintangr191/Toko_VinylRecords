import { Hono } from "hono";
import {
  getAllReservations,
  updateReservationStatus,
} from "../controllers/reservationAdminController";
import {requireAdmin} from "../middleware/auth";

const adminReservation = new Hono();

adminReservation.use("*", requireAdmin);
adminReservation.get("/", getAllReservations);
adminReservation.patch("/:id", updateReservationStatus);

export default adminReservation;