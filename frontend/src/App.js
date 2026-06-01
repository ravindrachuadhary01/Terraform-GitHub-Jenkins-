import React, { useState } from "react";
import "./App.css";

const API_URL = "http://app-alb-1630608787.ap-south-1.elb.amazonaws.com";

export default function App() {
  const [page, setPage] = useState("login");
  const [message, setMessage] = useState("");

  const [form, setForm] = useState({
    username: "",
    password: "",
  });

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value,
    });
  };

  const register = async () => {
    try {
      const res = await fetch(`${API_URL}/register`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(form),
      });

      const data = await res.json();

      if (res.ok) {
        setMessage("🎉 Registration Successful!");
        setPage("registerSuccess");
      } else {
        setMessage(data.message || "Registration Failed");
      }
    } catch (error) {
      setMessage("❌ Backend Connection Error");
    }
  };

  const login = async () => {
    try {
      const res = await fetch(`${API_URL}/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(form),
      });

      const data = await res.json();

      if (res.ok) {
        setMessage("🚀 Login Successful!");
        setPage("loginSuccess");
      } else {
        setMessage(data.message || "Login Failed");
      }
    } catch (error) {
      setMessage("❌ Backend Connection Error");
    }
  };

  return (
    <div className="app">
      {page === "login" && (
        <div className="card glass">
          <h1>LOGIN PAGE</h1>

          <input
            type="text"
            name="username"
            placeholder="Enter Username"
            value={form.username}
            onChange={handleChange}
          />

          <input
            type="password"
            name="password"
            placeholder="Enter Password"
            value={form.password}
            onChange={handleChange}
          />

          <button onClick={login}>Login</button>

          <p
            style={{ cursor: "pointer" }}
            onClick={() => {
              setMessage("");
              setPage("register");
            }}
          >
            New user? Register
          </p>

          <div className="msg">{message}</div>
        </div>
      )}

      {page === "register" && (
        <div className="card glass">
          <h1>REGISTER PAGE</h1>

          <input
            type="text"
            name="username"
            placeholder="Enter Username"
            value={form.username}
            onChange={handleChange}
          />

          <input
            type="password"
            name="password"
            placeholder="Password"
            value={form.password}
            onChange={handleChange}
          />

          <button onClick={register}>Register</button>

          <p
            style={{ cursor: "pointer" }}
            onClick={() => {
              setMessage("");
              setPage("login");
            }}
          >
            Already have an account? Login
          </p>

          <div className="msg">{message}</div>
        </div>
      )}

      {page === "registerSuccess" && (
        <div className="success">
          <h2>🎉 Registration Successful!</h2>

          <button
            onClick={() => {
              setMessage("");
              setPage("login");
            }}
          >
            Go To Login
          </button>
        </div>
      )}

      {page === "loginSuccess" && (
        <div className="success">
          <h2>🚀 Login Successful!</h2>

          <button
            onClick={() => {
              setForm({
                username: "",
                password: "",
              });
              setMessage("");
              setPage("login");
            }}
          >
            Logout
          </button>
        </div>
      )}
    </div>
  );
}