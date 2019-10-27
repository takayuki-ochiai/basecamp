import Express from "express";
import next from "next";
import * as ENV from "./constant";
import { createTerminus } from "@godaddy/terminus";
import http from "http";

const dev = process.env.NODE_ENV !== "production";

(async () => {
  const express = Express();
  const nextApp = next({ dev, dir: "./src/client" });
  const handle = nextApp.getRequestHandler();
  await nextApp.prepare();

  express.use((req, res, next) => {
    if (dev) {
      console.log(req.originalUrl);
      console.log(`request method: ${req.method}`);
    }
    next();
  });

  express.get("/p/:id", (req, res) => {
    const actualPage = "/post";
    const queryParams = { title: req.params.id };
    return nextApp.render(req, res, actualPage, queryParams);
  });

  express.all("*", (req, res) => {
    handle(req, res);
  });

  const server = http.createServer(express);
  // graceful shutdown
  function beforeShutdown() {
    // SIGTERMシグナルが送信された後でもリクエストが流れてくる可能性を考慮し5秒待つ
    return new Promise(resolve => {
      setTimeout(resolve, 5000);
    });
  }

  createTerminus(server, { beforeShutdown });
  server.listen(ENV.APP_PORT);
})();
