const pool = require("../config/database");

async function getAllOrders(req, res, next) {
  try {
    const result = await pool.query(`
      SELECT
        orders.id,
        orders.status,
        orders.total_amount,
        orders.created_at,
        users.full_name AS retailer_name,
        users.email AS retailer_email
      FROM orders
      INNER JOIN users ON users.id = orders.retailer_id
      ORDER BY orders.created_at DESC
    `);

    res.status(200).json({
      orders: result.rows
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getAllOrders
};