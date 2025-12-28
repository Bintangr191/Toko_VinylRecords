import { Schema, model } from "mongoose";

const VinylSchema = new Schema(
  {
    title: { type: String, required: true },       
    artist: { type: String, required: true },
    year: Number,                                  
    genre: String,
    price: Number,                                  
    stock: Number,
    description: String,                            
    coverUrl: String,                               
    audioUrl: String,                               
  },
  { timestamps: true }
);

export default model("Vinyl", VinylSchema);