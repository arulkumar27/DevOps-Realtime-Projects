import { useState } from "react";

function ProductForm({ onProductAdded }) {
  const [form, setForm] = useState({
    productName: "",
    category: "",
    unit: "kg",
    price: "",
    quantity: ""
  });
  const [message, setMessage] = useState("");

  function updateField(event) {
    setForm({
      ...form,
      [event.target.name]: event.target.value
    });
  }

  async function handleSubmit(event) {
    event.preventDefault();
    setMessage("Adding product...");

    try {
      const response = await fetch("/api/products", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("farmdirect_token")}`
        },
        body: JSON.stringify({
          productName: form.productName,
          category: form.category,
          unit: form.unit,
          pricePerUnit: Number(form.price),
          availableQuantity: Number(form.quantity)
        })
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Unable to add product");
      }

      setMessage("Product added successfully.");

      setForm({
        productName: "",
        category: "",
        unit: "kg",
        price: "",
        quantity: ""
      });

      onProductAdded();
    } catch (error) {
      setMessage(error.message);
    }
  }

  return (
    <section className="add-product">
      <p>FARMER DASHBOARD</p>
      <h2>Add fresh produce</h2>

      <form onSubmit={handleSubmit}>
        <input
          name="productName"
          placeholder="Product name"
          value={form.productName}
          onChange={updateField}
          required
        />

        <input
          name="category"
          placeholder="Category (example: Vegetables)"
          value={form.category}
          onChange={updateField}
        />

        <input
          name="price"
          type="number"
          min="1"
          placeholder="Price per unit (₹)"
          value={form.price}
          onChange={updateField}
          required
        />

        <input
          name="quantity"
          type="number"
          min="1"
          placeholder="Available quantity"
          value={form.quantity}
          onChange={updateField}
          required
        />

        <select name="unit" value={form.unit} onChange={updateField}>
          <option value="kg">kg</option>
          <option value="piece">piece</option>
          <option value="box">box</option>
        </select>

        <button type="submit">Add product</button>
      </form>

      {message && <span className="form-message">{message}</span>}
    </section>
  );
}

export default ProductForm;