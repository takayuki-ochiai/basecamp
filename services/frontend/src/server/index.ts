import Express from "express";
import next from "next";
import * as ENV from "./constant";

const dev = process.env.NODE_ENV !== "production";

(async () => {
  const server = Express();
  const nextApp = next({ dev, dir: "./src/client" });
  const handle = nextApp.getRequestHandler();
  await nextApp.prepare();

  server.use((req, res, next) => {
    if (dev) {
      console.log(req.originalUrl);
      console.log(`request method: ${req.method}`);
    }
    next();
  });

  server.get("/p/:id", (req, res) => {
    const actualPage = "/post";
    const queryParams = { title: req.params.id };
    return nextApp.render(req, res, actualPage, queryParams);
  });

  server.all("*", (req, res) => {
    handle(req, res);
  });

  server.listen(ENV.APP_PORT, ENV.APP_HOST, (err: Express.Errback) => {
    if (err) throw err;
    console.log(`> Ready on http://${ENV.APP_HOST}:${ENV.APP_PORT}`);
  });
})();
