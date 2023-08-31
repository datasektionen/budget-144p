import express from "express";
import prisma from "./db";
import api from "./api";


const app = express();
app.use(express.json());

app.use("/api", api);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
