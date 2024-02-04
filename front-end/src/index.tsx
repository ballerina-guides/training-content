import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

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
      <App />
    </div>
  </React.StrictMode>
);
