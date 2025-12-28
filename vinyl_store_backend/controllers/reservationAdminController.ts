import type { Context } from "hono";
import Reservation from "../models/Reservation";
import Vinyl from "../models/Vinyl";

// ADMIN: lihat semua reservasi
export const getAllReservations = async (c: Context) => {
  const user = (c as any).currentUser;
  if (!user || user.role !== "admin") {
    return c.json({ error: "Forbidden" }, 403);
  }

  const data = await Reservation.find()
    .populate("user", "username email")
    .populate("vinyl", "title artist price")
    .sort({ reservedAt: -1 });

  return c.json(data);
};

// ADMIN: ubah status reservasi
export const updateReservationStatus = async (c: Context) => {
  const user = (c as any).currentUser;
  if (!user || user.role !== "admin") {
    return c.json({ error: "Forbidden" }, 403);
  }

  const id = c.req.param("id");
  const { status } = await c.req.json();

  if (!["active", "expired", "collected"].includes(status)) {
    return c.json({ error: "Status tidak valid" }, 400);
  }

  const reservation = await Reservation.findById(id);
  if (!reservation) {
    return c.json({ error: "Reservation not found" }, 404);
  }

  // Kalau expired → kembalikan stock
  if (status === "expired" && reservation.status === "active") {
    const vinyl = await Vinyl.findById(reservation.vinyl);
    if (vinyl) {
      vinyl.stock += 1;
      await vinyl.save();
    }
  }

  reservation.status = status;
  await reservation.save();

  return c.json(reservation);
};