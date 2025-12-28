import { promises as fs } from "fs";
import path from "path";

export const uploadFileToPublic = async (file: File, folder = "") => {
  const arrayBuffer = await file.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);

  const ext = file.name.split(".").pop();
  const filename = `${Date.now()}.${ext}`;

  const dir = path.join(process.cwd(), "uploads", folder);
  await fs.mkdir(dir, { recursive: true });

  const filePath = path.join(dir, filename);
  await fs.writeFile(filePath, buffer);

  return `/uploads/${folder ? folder + "/" : ""}${filename}`;
};