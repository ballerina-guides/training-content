import { useState } from "react";
import axios from "axios";
import { Reservation } from "../types/generated";
import { User } from "../types/generated";

const baseUrl = "http://localhost:9090/reservations";

export function useReserveRoom() {
  const [reservation, setReservation] = useState<Reservation>();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error>();

  const reserveRoom = async (
    checkIn: string,
    checkOut: string,
    rate: number,
    roomType: string,
    user: User,
  ): Promise<void> => {
    setLoading(true);
    try {
      const response = await axios.post<Reservation>(baseUrl, {
        checkinDate: checkIn,
        checkoutDate: checkOut,
        rate: rate,
        roomType: roomType,
        user: user,
      });
      setReservation(response.data);
    } catch (e: any) {
      setError(e);
    }
    setLoading(false);
  };

  return { reservation, loading, error, reserveRoom };
}

export function useGetReservations() {
  const [reservations, setReservations] = useState<Reservation[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error>();

  const fetchReservations = async (userId: string): Promise<void> => {
    setLoading(true);
    try {
      const response = await axios.get<Reservation[]>(
        baseUrl + "/users/" + userId,
        {
          withCredentials: false,
          // TODO: use proxy to avoid CORS disabling
          headers: {
            "Acccess-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,PUT,POST,DELETE,PATCH,OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
            "Content-Type": "application/json",
          },
        },
      );
      setReservations(response.data);
    } catch (e: any) {
      setError(e);
    }
    setLoading(false);
  };

  return { reservations, loading, error, fetchReservations };
}

export function useDeleteReservation() {
  const [deleted, setDeleted] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<Error>();

  const deleteReservation = async (id: number): Promise<void> => {
    setDeleting(true);
    try {
      await axios.delete(baseUrl + "/" + id);
      setDeleted(true);
    } catch (e: any) {
      setError(e);
    }
    setDeleting(false);
  };

  return { deleted, deleting, error, deleteReservation };
}
