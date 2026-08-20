const express = require("express");
const { getAllOrders } = require("../controllers/adminOrderController");
const {
  authenticateToken,
  authorizeRoles
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get(
  "/orders",
  authenticateToken,
  authorizeRoles("ADMIN"),
  getAllOrders
);

module.exports = router;