import { useEffect, useState } from "react";
import "./App.css";

function App() {
  const [products, setProducts] = useState([]);
  const [message, setMessage] = useState("Loading products...");

  useEffect(() => {
    fetch("/api/products")
      .then((response) => {
        if (!response.ok) {
          throw new Error("API failed");
        }
        return response.json();
      })
      .then((data) => {
        setProducts(data.products || []);
        setMessage("");
      })
      .catch(() => {
        setMessage("Backend is unavailable. Check Docker containers.");
      });
  }, []);

  return (
    <main className="app">
      <header>
        <p className="logo">Farm<span>Direct</span></p>
        <button>Login</button>
      </header>

      <section className="hero">
        <p>FARM-TO-RETAIL PLATFORM</p>
        <h1>Fresh produce, directly from trusted farmers.</h1>
        <span>Secure inventory and order management for farmers and retailers.</span>
      </section>

      <section className="products">
        <p>LIVE INVENTORY</p>
        <h2>Available produce</h2>

        {message && <p className="message">{message}</p>}

        <div className="product-grid">
          {products.map((product) => (
            <article className="product-card" key={product.id}>
              <div>🌿</div>
              <small>{product.category || "Fresh produce"}</small>
              <h3>{product.product_name}</h3>
              <p>Sold by {product.farmer_name}</p>
              <strong>₹{product.price_per_unit} / {product.unit}</strong>
              <span>{product.available_quantity} {product.unit} in stock</span>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}

export default App;