import committees from "./committees";

import express from "express";
const router = express.Router();

router.use("/committees", committees);

export default router;
