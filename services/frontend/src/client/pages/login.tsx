import React, { useCallback } from "react";
import * as firebase from "firebase";

const Login = () => {
  const handleLogin = useCallback(() => {
    firebase.auth().signInWithPopup(new firebase.auth.GoogleAuthProvider());
  }, []);

  return (
    <>
      <button onClick={handleLogin}>ログイン・新規登録はこちら</button>
    </>
  );
};

export default Login;
