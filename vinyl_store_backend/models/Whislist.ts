import mongoose from "mongoose";

const wishlistSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    vinyl: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Vinyl",
      required: true,
    },
  },
  { timestamps: true }
);

wishlistSchema.index({ user: 1, vinyl: 1 }, { unique: true });

export default mongoose.model("Wishlist", wishlistSchema);