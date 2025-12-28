// controllers/vinylController.ts
import type { Context } from "hono";
import Vinyl from "../models/Vinyl";
import { uploadFileToPublic } from "../middleware/upload";
import { promises as fs } from "fs";
import path from "path";


// GET all vinyl
export const getVinyls = async (c: Context) => {
  const list = await Vinyl.find().sort({ createdAt: -1 });
  return c.json(list);
};

// GET 1 vinyl
export const getVinyl = async (c: Context) => {
  const id = c.req.param("id");
  const vinyl = await Vinyl.findById(id);
  return vinyl ? c.json(vinyl) : c.json({ error: "Not found" }, 404);
};

// CREATE vinyl (form-data)
export const createVinyl = async (c: Context) => {
  const form = await c.req.formData();

  const title = form.get("title") as string;
  const artist = form.get("artist") as string;
  if (!title || !artist) return c.json({ error: "title and artist are required" }, 400);

  // numeric fields
  const year = form.get("year") ? Number(form.get("year")) : undefined;
  const price = form.get("price") ? Number(form.get("price")) : undefined;
  const stock = form.get("stock") ? Number(form.get("stock")) : undefined;
  const genre = form.get("genre") as string;
  const description = form.get("description") as string;

  // file upload
  const coverFile = form.get("cover") as File | null;
  const audioFile = form.get("audio") as File | null;

  const coverUrl = coverFile ? await uploadFileToPublic(coverFile) : "";
  const audioUrl = audioFile ? await uploadFileToPublic(audioFile) : "";

  const vinyl = await Vinyl.create({
    title,
    artist,
    year,
    price,
    stock,
    genre,
    description,
    coverUrl,
    audioUrl,
  });

  return c.json(vinyl, 201);
};

// UPDATE vinyl (form-data)
export const updateVinyl = async (c: Context) => {
  const id = c.req.param("id");
  const form = await c.req.formData();

  const updateData: any = {};
  if (form.get("title")) updateData.title = form.get("title");
  if (form.get("artist")) updateData.artist = form.get("artist");
  if (form.get("year")) updateData.year = Number(form.get("year"));
  if (form.get("price")) updateData.price = Number(form.get("price"));
  if (form.get("stock")) updateData.stock = Number(form.get("stock"));
  if (form.get("genre")) updateData.genre = form.get("genre");
  if (form.get("description")) updateData.description = form.get("description");

  // optional file upload
  const coverFile = form.get("cover") as File | null;
  const audioFile = form.get("audio") as File | null;
  if (coverFile) updateData.coverUrl = await uploadFileToPublic(coverFile);
  if (audioFile) updateData.audioUrl = await uploadFileToPublic(audioFile);

  const vinyl = await Vinyl.findByIdAndUpdate(id, updateData, { new: true });
  return vinyl ? c.json(vinyl) : c.json({ error: "Not found" }, 404);
};

// DELETE vinyl + hapus file cover & audio
export const deleteVinyl = async (c: Context) => {
  const id = c.req.param("id");

  // ambil data vinyl
  const vinyl = await Vinyl.findById(id);
  if (!vinyl) return c.json({ error: "Not found" }, 404);

  // hapus cover image
  if (vinyl.coverUrl) {
    const coverPath = path.join(process.cwd(), vinyl.coverUrl);
    try { await fs.unlink(coverPath); } catch (err) { /* ignore jika file tidak ada */ }
  }

  // hapus audio
  if (vinyl.audioUrl) {
    const audioPath = path.join(process.cwd(), vinyl.audioUrl);
    try { await fs.unlink(audioPath); } catch (err) { /* ignore jika file tidak ada */ }
  }

  // hapus data dari DB
  await Vinyl.findByIdAndDelete(id);

  return c.json({ message: "Vinyl and its files deleted"});
};

// UPLOAD image only (optional)
export const uploadImage = async (c: Context) => {
  const id = c.req.param("id");
  const imageFile = (await c.req.formData()).get("image") as File | null;
  if (!imageFile) return c.json({ error: "No file uploaded" }, 400);

  const imageUrl = await uploadFileToPublic(imageFile);
  const vinyl = await Vinyl.findByIdAndUpdate(id, { coverUrl: imageUrl }, { new: true });
  return c.json(vinyl);
};

// UPLOAD audio only (optional)
export const uploadAudio = async (c: Context) => {
  const id = c.req.param("id");
  const audioFile = (await c.req.formData()).get("audio") as File | null;
  if (!audioFile) return c.json({ error: "No audio uploaded" }, 400);

  const audioUrl = await uploadFileToPublic(audioFile);
  const vinyl = await Vinyl.findByIdAndUpdate(id, { audioUrl }, { new: true });
  return c.json(vinyl);
};