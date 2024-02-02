import React from 'react';
import ReactDOM from 'react-dom/client';
import Home from './Home';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import RoomList from './RoomList';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <div style={{ display: "flex", height: "96vh", width: "96vw" }}>
      <BrowserRouter>
        <Routes>
          <Route path="/" Component={Home} />
          <Route path="/home" Component={Home} />
          {/* rooms */}
          <Route path="/rooms" Component={RoomList} />
          {/* reservations */}
          <Route path="/reservations" Component={()=><div>Reservation listing</div>} />
          {/* reservation detail */}
          <Route path="/reservations/:id" Component={()=><div>Reservation detail</div>} />
          {/* Otherwise, show not found page */}
          <Route path="*" Component={()=><div>Not found</div>} />
        </Routes>
      </BrowserRouter>
    </div>
  </React.StrictMode>
);
