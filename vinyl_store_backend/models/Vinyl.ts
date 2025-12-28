import { Schema, model } from "mongoose";

const VinylSchema = new Schema(
  {
    title: { type: String, required: true },        // judul
    artist: { type: String, required: true },
    year: Number,                                   // tahun
    genre: String,
    price: Number,                                  // harga
    stock: Number,
    description: String,                            // deskripsi
    coverUrl: String,                               // path file image
    audioUrl: String,                               // path file audio
  },
  { timestamps: true }
);

export default model("Vinyl", VinylSchema);