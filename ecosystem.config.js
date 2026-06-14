export default {
  apps: [
    {
      name: "gena-api",
      script: "./dist/server.js",
      instances: "max",
      exec_mode: "cluster",
      watch: false,
      env: {
        NODE_ENV: "production",
      },
      env_development: {
        NODE_ENV: "development",
      }
    }
  ]
};
