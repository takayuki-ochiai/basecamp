import * as firebase from "firebase";
import { createContext } from "react";
import { User } from "../models/user";

type FirebaseState = {
  auth: firebase.auth.Auth | null;
};

export const FirebaseContext = createContext<FirebaseState>({
  auth: null
});

type UserState = {
  user: User | null;
  credential: firebase.auth.UserCredential | null;
  setCredential: (credential: firebase.auth.UserCredential | null) => void;
};

export const UserContext = createContext<UserState>({
  user: null,
  credential: null,
  setCredential: () => {}
});
