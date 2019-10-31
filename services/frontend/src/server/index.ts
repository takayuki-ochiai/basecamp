import Express from "express";
import cookieParser from "cookie-parser";
import next from "next";
import * as ENV from "./constant";
import { createTerminus } from "@godaddy/terminus";
import http from "http";
import admin from "firebase-admin";
// import serverCredential from "../credentials/server";

const dev = process.env.NODE_ENV !== "production";

const firebase = admin.initializeApp(
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  { credential: admin.credential.cert(require("../credentials/server.json")) },
  "server"
);

(async () => {
  const express = Express();
  const nextApp = next({ dev, dir: "./src/client" });
  const handle = nextApp.getRequestHandler();
  await nextApp.prepare();

  // TODO: CORS設定の準備

  express.get("/p/:id", (req, res) => {
    const actualPage = "/post";
    const queryParams = { title: req.params.id };
    return nextApp.render(req, res, actualPage, queryParams);
  });

  // Content-Typeがurlencodedなデータをなんかいい感じにparseするためのミドルウェア
  // POSTされるデータのparse用。parseされたデータはreq.bodyに入ってくる
  express.use(Express.json());
  // Content-Typeがurlencodedなデータをなんかいい感じにparseするためのミドルウェア
  // POSTされるデータのparse用。parseされたデータはreq.bodyに入ってくる
  // extended: trueだとqsライブラリでurlencodedされた値をparseする
  express.use(Express.urlencoded({ extended: true }));
  // cookie
  express.use(cookieParser());
  express.post("/api/login", (req, res) => {
    if (!req.body) return res.sendStatus(400);
    // 既にセッションがある場合は新しくsessionCookieは発行しない
    if (req.cookies.session != null) {
      return res.end(JSON.stringify({ newSession: false }));
    }

    const idToken = req.body.idToken.toString();
    // Set session expiration to 1 hour.
    const expiresIn = 60 * 60 * 1000;
    firebase
      .auth()
      .createSessionCookie(idToken, { expiresIn })
      .then(
        sessionCookie => {
          const options = { maxAge: expiresIn, httpOnly: true };
          res.cookie("session", sessionCookie, options);
          res.end(JSON.stringify({ newSession: true }));
        },
        error => {
          res.status(401).send("UNAUTHORIZED REQUEST!");
        }
      );
  });

  express.post("/api/logout", (req, res) => {
    res.clearCookie("session");
    res.end(JSON.stringify({ status: "success" }));
  });

  express.get("/about", (req, res) => {
    console.log("about page called!!!");
    return nextApp.render(req, res, "/about");
  });

  // nextjsのフレームワークが返す静的アセットは認証なしでも見れるようにする
  express.all("/_next/*", (req, res) => {
    handle(req, res);
  });

  express.get("/", (req, res) => {
    console.log("index page called!!!");
    return nextApp.render(req, res, "/");
  });

  express.get("/childs", (req, res) => {
    console.log("child page called!!!");
    return nextApp.render(req, res, "/childs");
  });

  express.use((req, res, next) => {
    console.log("authentication start");
    const sessonCookie: string = req.cookies.session || "";
    firebase
      .auth()
      .verifySessionCookie(sessonCookie, true)
      .then(() => {
        next();
      })
      .catch(error => {
        res.redirect("/about");
      });
  });

  express.use((req, res) => {
    handle(req, res);
  });

  const server = http.createServer(express);
  // graceful shutdown
  const beforeShutdown = () => {
    // SIGTERMシグナルが送信された後でもリクエストが流れてくる可能性を考慮し5秒待つ
    return new Promise(resolve => {
      setTimeout(resolve, 5000);
    });
  };

  createTerminus(server, { beforeShutdown });
  server.listen(ENV.APP_PORT);
})();
