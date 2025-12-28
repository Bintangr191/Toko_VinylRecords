// src/controllers/reservationController.ts
import type { Context } from "hono";
import Reservation from "../models/Reservation";
import Vinyl from "../models/Vinyl";

// =======================
// USER: Keep vinyl
// =======================
export const keepVinyl = async (c: Context) => {
  const currentUser = (c as any).currentUser;
  if (!currentUser) return c.json({ error: "Unauthorized" }, 401);

  const vinylId = c.req.param("id");
  const { confirmTitle } = await c.req.json(); // Field wajib

  const vinyl = await Vinyl.findById(vinylId);
  if (!vinyl || vinyl.stock <= 0) {
    return c.json({ error: "Vinyl tidak tersedia" }, 400);
  }

  // Validasi nama vinyl
  if (!confirmTitle || confirmTitle.trim() !== vinyl.title) {
    return c.json({
      error: "Konfirmasi gagal: tulis nama vinyl dengan benar",
    }, 400);
  }

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);

  const reservation = await Reservation.create({
    user: currentUser.id,
    vinyl: vinylId,
    expiresAt,
  });

  vinyl.stock -= 1;
  await vinyl.save();

  return c.json({ message: "Vinyl di-keep", reservation });
};

// =======================
// USER: Lihat reservasi sendiri
// =======================
export const getMyReservations = async (c: Context) => {
  const currentUser = (c as any).currentUser;
  if (!currentUser) return c.json({ error: "Unauthorized" }, 401);

  const reservations = await Reservation.find({ user: currentUser.id })
    .populate("vinyl", "title artist coverUrl price")
    .sort({ reservedAt: -1 });

  return c.json(reservations);
};

