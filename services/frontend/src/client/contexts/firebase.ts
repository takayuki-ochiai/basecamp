import * as firebase from "firebase";
import { createContext } from "react";

type FirebaseState = {
  auth: firebase.auth.Auth | null;
};

export const FirebaseContext = createContext<FirebaseState>({
  auth: null
});
