const express = require("express");
const { createOrder } = require("../controllers/orderController");
const {
  authenticateToken,
  authorizeRoles
} = require("../middleware/authMiddleware");

const router = express.Router();

router.post(
  "/",
  authenticateToken,
  authorizeRoles("RETAILER"),
  createOrder
);

module.exports = router;