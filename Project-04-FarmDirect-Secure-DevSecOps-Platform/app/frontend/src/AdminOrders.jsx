import { useEffect, useState } from "react";

function AdminOrders() {
  const [orders, setOrders] = useState([]);
  const [message, setMessage] = useState("Loading all orders...");

  useEffect(() => {
    fetch("/api/admin/orders", {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("farmdirect_token")}`
      }
    })
      .then((response) => {
        if (!response.ok) throw new Error("Unable to load admin orders");
        return response.json();
      })
      .then((data) => {
        setOrders(data.orders || []);
        setMessage("");
      })
      .catch((error) => {
        setMessage(error.message);
      });
  }, []);

  return (
    <section className="admin-orders">
      <p>ADMIN DASHBOARD</p>
      <h2>All retailer orders</h2>

      {message && <span className="form-message">{message}</span>}

      {!message && (
        <div className="order-table">
          <div className="table-heading">
            <span>Order</span>
            <span>Retailer</span>
            <span>Total</span>
            <span>Status</span>
          </div>

          {orders.map((order) => (
            <div className="table-row" key={order.id}>
              <span>#{order.id}</span>
              <span>{order.retailer_name}</span>
              <span>₹{order.total_amount}</span>
              <span className="order-status">{order.status}</span>
            </div>
          ))}
        </div>
      )}
    </section>
  );
}

export default AdminOrders;