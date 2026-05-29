import { useEffect, useState } from "react";

function App() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
   fetch("http://app-alb-1480368457.ap-south-1.elb.amazonaws.com/")
  .then(res => res.text())
  .then(data => console.log(data));
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