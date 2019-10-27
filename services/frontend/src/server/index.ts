import Express from "express";
import next from "next";
import * as ENV from "./constant";

const dev = process.env.NODE_ENV !== "production";

(async () => {
  const app = Express();
  const nextApp = next({ dev, dir: "./src/client" });
  const handle = nextApp.getRequestHandler();
  await nextApp.prepare();

  app.get("/about", (req, res) => {
    return nextApp.render(req, res, "/about", req.query);
  });

  app.get("/p/:id", (req, res) => {
    const actualPage = "/post";
    const queryParams = { title: req.params.id };
    return nextApp.render(req, res, actualPage, queryParams);
  });

  app.use((req, res) => {
    handle(req, res);
  });

  app.listen(ENV.APP_PORT, ENV.APP_HOST, (err: Express.Errback) => {
    if (err) throw err;
    console.log(`> Ready on http://${ENV.APP_HOST}:${ENV.APP_PORT}`);
  });
})();
