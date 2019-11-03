import url from "url";
import Express from "express";
import cookieParser from "cookie-parser";
import next from "next";
import { createTerminus } from "@godaddy/terminus";
import http from "http";
import admin from "firebase-admin";
import config from "config";
const dev = process.env.NODE_ENV !== "production";

const firebase = admin.initializeApp(
  {
    credential: admin.credential.cert(
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      require(config.get("Server.credential"))
    )
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
      const allowOriginHosts: string[] = config.get("Server.allowOriginHosts");
      if (host != null && !allowOriginHosts.includes(host)) {
        return res.sendStatus(400);
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
    const secureCookie: boolean = config.get("Server.secureCookie");
    firebase
      .auth()
      .createSessionCookie(idToken, { expiresIn })
      .then(
        sessionCookie => {
          const options = {
            maxAge: expiresIn,
            httpOnly: true,
            sameSite: "Lax",
            secure: secureCookie
          };
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
    // cookieから削除するだけじゃなく、firebase側のtokenも無効化しないと、
    // 何らかの要因でトークンを外部に晒してしまい、そのトークンによるセッションハイジャックを自主的に防ぐための
    // アクションとしてのログアウトは期待通りに機能しなくなるため
    const sessionCookie: string = req.cookies.session || "";
    firebase
      .auth()
      .verifySessionCookie(sessionCookie)
      .then(decodedClaims => {
        // リフレッシュトークンをrevokeしつつtokensValidAfterTimeを現在のUTCにする
        // ログイン状態の確認の時点でcheckForRevocation: trueにしているので、
        // 次にバックエンドでログイン状態を確認した際にtokenがrevokeされていることを確認して、仮にトークンが漏洩してもログイン状態と判定しなくなる
        return firebase.auth().revokeRefreshTokens(decodedClaims.sub);
      });
    res.end(JSON.stringify({ status: "success" }));
  });

  express.get("/about", (req, res) => {
    return nextApp.render(req, res, "/about");
  });

  // nextjsのフレームワークが返す静的アセットは認証なしでも見れるようにする
  express.all("/_next/*", (req, res) => {
    handle(req, res);
  });

  express.get("/", (req, res) => {
    return nextApp.render(req, res, "/");
  });

  express.get("/childs", (req, res) => {
    return nextApp.render(req, res, "/childs");
  });

  // ログイン状態の確認
  express.use((req, res, next) => {
    const sessionCookie: string = req.cookies.session || "";
    firebase
      .auth()
      .verifySessionCookie(sessionCookie, true)
      .then(decodedIdToken => {
        next();
      })
      .catch(error => {
        res.redirect("/login");
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
  server.listen(config.get("Server.port"));
})();
