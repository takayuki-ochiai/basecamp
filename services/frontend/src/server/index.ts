import Express from "express";
import next from "next";
import * as ENV from "./constant";

const dev = process.env.NODE_ENV !== "production";

(async () => {
  const app = Express();
  const nextApp = next({ dev, dir: "./src/client" });
  const handle = nextApp.getRequestHandler();
  await nextApp.prepare();

  app.use((req, res) => {
    handle(req, res);
  });

  app.listen(ENV.APP_PORT, ENV.APP_HOST, (err: Express.Errback) => {
    if (err) throw err;
    console.log(`> Ready on http://${ENV.APP_HOST}:${ENV.APP_PORT}`);
  });
})();

// app.get("/", (req, res) => {
//   const data = { ping: "pong" };
//   res.send(data);
// });
// const express = require('express')
// const next = require('next')
//
// const dev = process.env.NODE_ENV !== 'production'
// const app = next({ dev })
// const handle = app.getRequestHandler()
//
// app.prepare()
//     .then(() => {
//         const server = express()
//
//         server.get('*', (req, res) => {
//             return handle(req, res)
//         })
//
//         server.listen(3000, (err) => {
//             if (err) throw err
//             console.log('> Ready on http://localhost:3000')
//         })
//     })
//     .catch((ex) => {
//         console.error(ex.stack)
//     })
//         process.exit(1)
// console.log("Hello world!!!!!!!!!!!!!!!!");
// export default undefined;
