import React, { useCallback, useContext } from "react";
import * as firebase from "firebase";
import axios from "axios";
import { UserDispatchContext, setUser } from "../contexts/user";

const Login = () => {
  const dispatch = useContext(UserDispatchContext);

  const handleLogin = useCallback(() => {
    firebase
      .auth()
      .signInWithPopup(new firebase.auth.GoogleAuthProvider())
      .then((credential) => {
        const user = credential.user;
        if (user === null) return;
        user
          .getIdToken()
          .then((idToken) => {
            return axios.post("/api/login", { idToken });
          })
          .then((res) => {
            dispatch(setUser(user));
          });
      });
  }, []);

  return (
    <>
      <button onClick={handleLogin}>ログイン・新規登録はこちら</button>
    </>
  );
};

export default Login;
