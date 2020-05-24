import url from "url";
import Express from "express";
import cookieParser from "cookie-parser";
import axios from "axios";
import next from "next";
import { createTerminus } from "@godaddy/terminus";
import http from "http";
import HttpStatus from "http-status-codes";
import admin from "firebase-admin";
import Config from "./models/config";
import Env from "./models/env";
const config = new Config();
const dev = config.get(Env.BFF_ENV) !== "production";

const firebase = admin.initializeApp(
  {
    credential: admin.credential.cert(
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      require(config.get(Env.BFF_ADMIN_CREDENTIAL))
    ),
  },
  "server"
);

(async () => {
  const express = Express();
  const nextApp = next({ dev, dir: "./src/client" });
  const handle = nextApp.getRequestHandler();
  await nextApp.prepare();

  // リソース更新系メソッド（POST PUT PATCH DELETE）の場合はALLOW_ORIGIN_HOSTSに含まれるhostからのアクセスでなければならない
  // CSRF対策
  express.use((req, res, next) => {
    if (
      req.method === "POST" ||
      req.method === "PUT" ||
      req.method === "PATCH" ||
      req.method === "DELETE"
    ) {
      const origin = req.get("origin");
      const host = origin && url.parse(origin, false).host;
      const allowOriginHosts: string[] = config.get(Env.BFF_ALLOW_ORIGIN_HOSTS);
      if (host != null && !allowOriginHosts.includes(host)) {
        return res
          .status(HttpStatus.BAD_REQUEST)
          .send("Bad Request NOT ALLOW ORIGIN HOSTS");
      }
    }
    next();
  });

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
    const idToken = req.body.idToken.toString();
    // Set session expiration to 1 hour.
    const expiresIn = 60 * 60 * 1000;
    const secureCookie: boolean = config.get(Env.BFF_SECURE_COOKIE);
    firebase
      .auth()
      .createSessionCookie(idToken, { expiresIn })
      .then(
        (sessionCookie) => {
          const options = {
            maxAge: expiresIn,
            httpOnly: true,
            sameSite: "Lax",
            secure: secureCookie,
          };
          res
            .cookie("session", sessionCookie, options)
            .status(HttpStatus.OK)
            .end();
        },
        () => {
          res
            .status(HttpStatus.UNAUTHORIZED)
            .send("UNAUTHORIZED REQUEST!")
            .end();
        }
      );
  });

  express.get("/", (req, res) => {
    return nextApp.render(req, res, "/");
  });

  express.get("/about", (req, res) => {
    return nextApp.render(req, res, "/about");
  });

  express.get("/childs", (req, res) => {
    return nextApp.render(req, res, "/childs");
  });

  express.get("/login", (req, res) => {
    return nextApp.render(req, res, "/login");
  });

  // nextjsのフレームワークが返す静的アセットは認証なしでも見れるようにする
  express.all("/_next/*", (req, res) => {
    handle(req, res);
  });

  // ログイン状態の確認
  express.use((req, res, next) => {
    const sessionCookie: string = req.cookies.session || "";
    firebase
      .auth()
      .verifySessionCookie(sessionCookie, true)
      .then((decodedIdToken) => {
        next();
      })
      .catch(() => {
        console.log("Fail verifySessionCookie request!");
        console.log(`url: ${req.url}`);
        // res.redirect("/login");
      });
  });

  express.post("/api/users", async (req, res) => {
    const endpoint = config.get(Env.BACKEND_ENDPOINT);
    const backendResponse = await axios
      .post(`${endpoint}/api/v1/users`, {
        user: {
          email: req.body.user.email,
          uid: req.body.user.uid,
        },
      })
      .catch((err) => {
        return err.response;
      });
    res.status(backendResponse.status).send(backendResponse.data).end();
  });

  express.post("/api/logout", (req, res) => {
    // cookieから削除するだけじゃなく、firebase側のtokenも無効化しないと、
    // 何らかの要因でトークンを外部に晒してしまい、そのトークンによるセッションハイジャックを自主的に防ぐための
    // アクションとしてのログアウトは期待通りに機能しなくなるため
    const sessionCookie: string = req.cookies.session || "";
    firebase
      .auth()
      .verifySessionCookie(sessionCookie)
      .then((decodedClaims) => {
        // リフレッシュトークンをrevokeしつつtokensValidAfterTimeを現在のUTCにする
        // ログイン状態の確認の時点でcheckForRevocation: trueにしているので、
        // 次にバックエンドでログイン状態を確認した際にtokenがrevokeされていることを確認して、仮にトークンが漏洩してもログイン状態と判定しなくなる
        return firebase.auth().revokeRefreshTokens(decodedClaims.sub);
      });
    res.clearCookie("session").status(HttpStatus.OK).send("success").end();
  });

  express.use((req, res) => {
    handle(req, res);
  });

  const server = http.createServer(express);
  // graceful shutdown
  const beforeShutdown = () => {
    // SIGTERMシグナルが送信された後でもリクエストが流れてくる可能性を考慮し5秒待つ
    return new Promise((resolve) => {
      setTimeout(resolve, 5000);
    });
  };

  createTerminus(server, { beforeShutdown });
  server.listen(config.get(Env.BFF_PORT));
})();
