const pool = require("../config/database");

const getProducts = async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT
        products.id,
        products.product_name,
        products.category,
        products.unit,
        products.price_per_unit,
        products.available_quantity,
        users.full_name AS farmer_name
      FROM products
      INNER JOIN users ON users.id = products.farmer_id
      ORDER BY products.created_at DESC
    `);

    res.status(200).json({
      count: result.rows.length,
      products: result.rows
    });
  } catch (error) {
    next(error);
  }
};

const createProduct = async (req, res, next) => {
  try {
    const {
      productName,
      category,
      unit,
      pricePerUnit,
      availableQuantity
    } = req.body;

    if (
      !productName ||
      !unit ||
      !pricePerUnit ||
      availableQuantity === undefined
    ) {
      return res.status(400).json({
        message: "productName, unit, pricePerUnit and availableQuantity are required"
      });
    }

    const result = await pool.query(
      `
        INSERT INTO products (
          farmer_id,
          product_name,
          category,
          unit,
          price_per_unit,
          available_quantity
        )
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
      `,
      [
        req.user.userId,
        productName,
        category || null,
        unit,
        pricePerUnit,
        availableQuantity
      ]
    );

    res.status(201).json({
      message: "Product created successfully",
      product: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProducts,
  createProduct
};