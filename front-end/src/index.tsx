import Cookies from 'js-cookie';
import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom/client';
import Home from './Home';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { toast, ToastContainer } from 'react-toastify';
import RoomList from './RoomList';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <>
    <App />
    <ToastContainer />
  </>
  // <React.StrictMode>
  //   <div style={{ display: 'flex', height: '96vh', width: '96vw' }}>
  //     <BrowserRouter>
  //       <Routes>
  //         <Route path='/' Component={Home} />
  //         <Route path='/home' Component={Home} />
  //         {/* rooms */}
  //         <Route path='/rooms' Component={RoomList} />
  //         {/* reservations */}
  //         <Route path='/reservations' Component={()=><div>Reservation listing</div>} />
  //         {/* reservation detail */}
  //         <Route path='/reservations/:id' Component={()=><div>Reservation detail</div>} />
  //         {/* Otherwise, show not found page */}
  //         <Route path='*' Component={()=><div>Not found</div>} />
  //       </Routes>
  //     </BrowserRouter>
  //   </div>
  // </React.StrictMode>
);

export default function App() {
  const [isLoading, setIsLoading] = useState(false);
  const [isAuthLoading, setIsAuthLoading] = useState(true);
  const [signedIn, setSignedIn] = useState(false);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    if (Cookies.get('userinfo')) {
      // We are here after a login
      const userInfoCookie = Cookies.get('userinfo')
      sessionStorage.setItem('userInfo', userInfoCookie as string);
      Cookies.remove('userinfo');
      var userInfo = userInfoCookie ? JSON.parse(atob(userInfoCookie)) : null;
      setSignedIn(true);
      setUser(userInfo);
    } else if (sessionStorage.getItem('userInfo')) {
      // We have already logged in
      var userInfo = JSON.parse(atob(sessionStorage.getItem('userInfo')!));
      setSignedIn(true);
      setUser(userInfo);
    } else {
      console.log('User is not signed in');
    }
    setIsAuthLoading(false);
  }, []);

  useEffect(() => {
    // Handle errors from Managed Authentication
    const errorCode = new URLSearchParams(window.location.search).get('code');
    const errorMessage = new URLSearchParams(window.location.search).get('message');
    if (errorCode) {
      toast.error(<>
        <p>Something went wrong !</p>
        <p>Error Code : {errorCode}<br />Error Description: {errorMessage}</p>
      </>);    
    }
  }, []);

  if (isAuthLoading) {
    return <div>Loading</div>;
  }

  if (!signedIn) {
    return (
      <button
        onClick={() => { window.location.href = '/auth/login' }}
      >
        Login
      </button>
    );
  }

  return (
    <>
      <div>
        {user && (
          <p>
            {user?.username}
          </p>
        )}
      </div>
      <RoomList />
      <button
        onClick={() => {
          sessionStorage.removeItem('userInfo');
          window.location.href = `/auth/logout?session_hint=${Cookies.get('session_hint')}`;
        }}
      >
        Logout
      </button>
    </>
  );
}

