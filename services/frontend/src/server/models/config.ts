import Env from "./env";

class Config {
  get(env: Env) {
    switch (env) {
      case Env.BFF_ALLOW_ORIGIN_HOSTS:
        return JSON.parse(process.env[env] || "[]");
      case Env.BFF_SECURE_COOKIE:
        return JSON.parse(process.env[env] || "false");
      default:
        return process.env[env];
    }
  }
}

export default Config;
