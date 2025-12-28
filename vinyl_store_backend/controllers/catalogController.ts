// controllers/catalogController.ts
import type { Context } from "hono";
import Vinyl from "../models/Vinyl";

// HOME / CATALOG
export const getCatalog = async (c: Context) => {
  const vinyls = await Vinyl.find(
    { stock: { $gt: 0 } } // hanya yang tersedia
  )
  .select("title artist year genre price coverUrl") // ringkas
  .sort({ createdAt: -1 });

  return c.json(vinyls);
};

// DETAIL PRODUK
export const getCatalogDetail = async (c: Context) => {
  const id = c.req.param("id");

  const vinyl = await Vinyl.findById(id).select(
    "title artist year genre price stock description coverUrl audioUrl"
  );

  if (!vinyl) return c.json({ error: "Not found" }, 404);

  return c.json(vinyl);
};