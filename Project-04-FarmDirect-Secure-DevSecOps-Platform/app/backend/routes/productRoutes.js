const express = require("express");
const {
  getProducts,
  createProduct
} = require("../controllers/productController");
const {
  authenticateToken,
  authorizeRoles
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", getProducts);

router.post(
  "/",
  authenticateToken,
  authorizeRoles("FARMER"),
  createProduct
);

module.exports = router;