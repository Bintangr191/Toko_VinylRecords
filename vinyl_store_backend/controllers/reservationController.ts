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

// =======================
// ADMIN: Lihat semua reservasi
// =======================
export const getAllReservations = async (c: Context) => {
  const currentUser = (c as any).currentUser;
  if (!currentUser || currentUser.role !== "admin")
    return c.json({ error: "Forbidden (Admin only)" }, 403);

  const reservations = await Reservation.find()
    .populate("user", "username email")
    .populate("vinyl", "title artist")
    .sort({ reservedAt: -1 });

  return c.json(reservations);
};

// =======================
// ADMIN: Update status reservasi
// =======================
export const updateReservationStatus = async (c: Context) => {
  const currentUser = (c as any).currentUser;
  if (!currentUser || currentUser.role !== "admin")
    return c.json({ error: "Forbidden (Admin only)" }, 403);

  const id = c.req.param("id");
  const { status } = await c.req.json();

  if (!["active", "expired", "collected"].includes(status)) {
    return c.json({ error: "Status tidak valid" }, 400);
  }

  const reservation = await Reservation.findById(id);
  if (!reservation) return c.json({ error: "Reservation not found" }, 404);

  // Jika expired, kembalikan stock vinyl
  if (status === "expired") {
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
