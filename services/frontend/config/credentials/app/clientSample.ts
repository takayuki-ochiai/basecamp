const defaultConfig = {
  fireBase: {
    apiKey: "",
    authDomain: "",
    databaseURL: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
    appId: "",
    measurementId: "",
  },
};

const productionConfig = {
  fireBase: {
    apiKey: "",
    authDomain: "",
    databaseURL: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
    appId: "",
    measurementId: "",
  },
};

const stagingConfig = {
  fireBase: {
    apiKey: "",
    authDomain: "",
    databaseURL: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
    appId: "",
    measurementId: "",
  },
};

if (process.env.NODE_ENV === "production") {
  Object.assign(defaultConfig, productionConfig);
} else if (process.env.NODE_ENV === "test") {
  Object.assign(defaultConfig, stagingConfig);
}

export default defaultConfig;
