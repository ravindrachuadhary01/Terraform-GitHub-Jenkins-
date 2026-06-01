import React, { useState } from "react";
import "./App.css";

export default function App() {
  const [page, setPage] = useState("login");
  const [message, setMessage] = useState("");

  const [form, setForm] = useState({
    username: "",
    password: ""
  });

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  // 🔥 REGISTER API
  const register = async () => {
    const res = await fetch("http://10.0.3.210:5000/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form)
    });

    const data = await res.json();
    if (res.ok) {
      setMessage("🎉 Registration Successful!");
      setPage("registerSuccess");
    } else {
      setMessage(data.message || "Register Failed");
    }
  };

  // 🔥 LOGIN API
  const login = async () => {
    const res = await fetch("http://10.0.3.210:5000/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form)
    });

    const data = await res.json();
    if (res.ok) {
      setMessage("🚀 Login Successful!");
      setPage("loginSuccess");
    } else {
      setMessage(data.message || "Login Failed");
    }
  };

  return (
    <div className="app">

      {/* LOGIN PAGE */}
      {page === "login" && (
        <div className="card glass">
          <h1>Login</h1>

          <input
            name="username"
            placeholder="Username"
            onChange={handleChange}
          />

          <input
            type="password"
            name="password"
            placeholder="Password"
            onChange={handleChange}
          />

          <button onClick={login}>Login</button>

          <p onClick={() => setPage("register")}>
            New user? Register
          </p>

          <div className="msg">{message}</div>
        </div>
      )}

      {/* REGISTER PAGE */}
      {page === "register" && (
        <div className="card glass">
          <h1>Register</h1>

          <input
            name="username"
            placeholder="Username"
            onChange={handleChange}
          />

          <input
            type="password"
            name="password"
            placeholder="Password"
            onChange={handleChange}
          />

          <button onClick={register}>Register</button>

          <p onClick={() => setPage("login")}>
            Already have account? Login
          </p>

          <div className="msg">{message}</div>
        </div>
      )}

      {/* SUCCESS REGISTER */}
      {page === "registerSuccess" && (
        <div className="success">
          🎉 Successfully Registered!
          <button onClick={() => setPage("login")}>
            Go to Login
          </button>
        </div>
      )}

      {/* SUCCESS LOGIN */}
      {page === "loginSuccess" && (
        <div className="success">
          🚀 Login Successful!
          <button onClick={() => setPage("login")}>
            Logout
          </button>
        </div>
      )}
    </div>
  );
}