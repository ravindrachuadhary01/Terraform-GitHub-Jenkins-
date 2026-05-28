import { useEffect, useState } from "react";

function App() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch("/api/users")
      .then((res) => res.json())
      .then((data) => setUsers(data));
  }, []);

  return (
    <div>
      <h1>Users Welcome</h1>

      {users.map((u, i) => (
        <p key={i}>{u.name}</p>
      ))}
    </div>
  );
}

export default App;