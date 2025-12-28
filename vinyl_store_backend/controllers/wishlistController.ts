import type { Context } from "hono";
import Wishlist from "../models/whislist";

// TOGGLE wishlist (add / remove)
export const toggleWishlist = async (c: Context) => {
  const user = (c as any).currentUser;
  if (!user) return c.json({ error: "Unauthorized" }, 401);

  const vinylId = c.req.param("id");

  const existing = await Wishlist.findOne({
    user: user.id,
    vinyl: vinylId,
  });

  if (existing) {
    await existing.deleteOne();
    return c.json({ wishlisted: false });
  }

  await Wishlist.create({
    user: user.id,
    vinyl: vinylId,
  });

  return c.json({ wishlisted: true });
};

// GET my wishlist
export const getMyWishlist = async (c: Context) => {
  const user = (c as any).currentUser;
  if (!user) return c.json({ error: "Unauthorized" }, 401);

  const wishlist = await Wishlist.find({ user: user.id })
    .populate("vinyl", "title artist coverUrl price stock")
    .sort({ createdAt: -1 });

  return c.json(wishlist);
};

// CHECK is wishlisted
export const isWishlisted = async (c: Context) => {
  const user = (c as any).currentUser;
  if (!user) return c.json({ wishlisted: false });

  const vinylId = c.req.param("id");

  const exists = await Wishlist.exists({
    user: user.id,
    vinyl: vinylId,
  });

  return c.json({ wishlisted: !!exists });
};