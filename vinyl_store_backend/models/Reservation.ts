import mongoose from "mongoose";

const reservationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  vinyl: { type: mongoose.Schema.Types.ObjectId, ref: "Vinyl", required: true },
  reservedAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true }, 
  status: { type: String, enum: ["active", "expired", "collected"], default: "active" }
});

export default mongoose.model("Reservation", reservationSchema);