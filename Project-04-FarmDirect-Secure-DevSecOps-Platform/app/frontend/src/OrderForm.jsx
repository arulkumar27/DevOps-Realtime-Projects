import { useState } from "react";

function OrderForm({ products, onOrderPlaced }) {
  const [productId, setProductId] = useState("");
  const [quantity, setQuantity] = useState("");
  const [message, setMessage] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();

    if (!productId || !quantity) {
      setMessage("Select a product and enter quantity.");
      return;
    }

    setMessage("Placing order...");

    try {
      const response = await fetch("/api/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("farmdirect_token")}`
        },
        body: JSON.stringify({
          items: [
            {
              productId: Number(productId),
              quantity: Number(quantity)
            }
          ]
        })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Unable to place order");
      }

      setMessage(`Order #${data.order.id} placed successfully.`);
      setProductId("");
      setQuantity("");
      onOrderPlaced();
    } catch (error) {
      setMessage(error.message);
    }
  }

  return (
    <section className="add-product">
      <p>RETAILER DASHBOARD</p>
      <h2>Place a fresh produce order</h2>

      <form onSubmit={handleSubmit}>
        <select
          value={productId}
          onChange={(event) => setProductId(event.target.value)}
          required
        >
          <option value="">Select produce</option>

          {products.map((product) => (
            <option key={product.id} value={product.id}>
              {product.product_name} — ₹{product.price_per_unit}/{product.unit}
            </option>
          ))}
        </select>

        <input
          type="number"
          min="1"
          placeholder="Quantity"
          value={quantity}
          onChange={(event) => setQuantity(event.target.value)}
          required
        />

        <button type="submit">Place secure order</button>
      </form>

      {message && <span className="form-message">{message}</span>}
    </section>
  );
}

export default OrderForm;