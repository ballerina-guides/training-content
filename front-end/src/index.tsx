import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import RoomListing from './pages/room_listing';
import Header from './layout/AppBar';
import ReservationAddingPage from './pages/reservations_adding';
import ReservationListing from './pages/reservation_listing';

// TODO: add code formatter with linter

// TODO: add content only scroller layout

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <div style={{
      backgroundImage: 'url("https://images.unsplash.com/photo-1618773928121-c32242e63f39")',
      minHeight: "98vh",
      backgroundSize: 'cover'
    }}>
      <Header />
      <div style={{ display: 'flex', flexDirection: 'column', width: '100%', alignItems: 'center' }}>
        <BrowserRouter>
          <Routes>
            {/* rooms */}
            <Route path="/" Component={RoomListing} />
            <Route path="/rooms" Component={RoomListing} />
            {/* reservations */}
            <Route path="/reservations" Component={ReservationListing} />
            {/* reservation detail */}
            <Route path="/reservations/new" Component={ReservationAddingPage} />
            {/* Otherwise, show not found page */}
            <Route path="*" Component={() => <div>Not found</div>} />
          </Routes>
        </BrowserRouter>
      </div>

    </div>
  </React.StrictMode>
);
