import { useState } from "react";
import axios from "axios";
import {
  Reservation,
  ReservationRequest,
  UpdateReservationRequest,
} from "../types/generated";

const baseUrl = "http://localhost:9090/reservations";

export function useReserveRoom() {
  const [reservation, setReservation] = useState<Reservation>();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error>();

  const reserveRoom = async (request: ReservationRequest): Promise<void> => {
    setLoading(true);
    try {
      const response = await axios.post<Reservation>(baseUrl, request);
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

export function useUpdateReservation() {
  const [updated, setUpdated] = useState(false);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState<Error>();

  const updateReservation = async (
    id: number,
    updateRequest: UpdateReservationRequest,
  ): Promise<void> => {
    setUpdating(true);
    try {
      await axios.put(baseUrl + "/" + id, updateRequest);
      setUpdated(true);
    } catch (e: any) {
      setError(e);
    }
    setUpdating(false);
  };

  return { updated, updating, error, updateReservation };
}
