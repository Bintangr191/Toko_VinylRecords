import { Hono } from "hono";
import { getCatalog, getCatalogDetail } from "../controllers/catalogController";


const router = new Hono();

// GET /catalog
router.get("/", getCatalog);
// GET /catalog/:id
router.get("/:id", getCatalogDetail);

export default router;


