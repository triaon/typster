const { defineConfig, devices } = require("@playwright/test")

const port = process.env.PORT || "4010"
const baseURL = process.env.PLAYWRIGHT_BASE_URL || `http://127.0.0.1:${port}`

module.exports = defineConfig({
  testDir: "./e2e",
  timeout: 20_000,
  expect: {
    timeout: 5_000
  },
  use: {
    baseURL,
    trace: "retain-on-failure"
  },
  webServer: {
    command: `cd .. && PORT=${port} mix phx.server`,
    url: baseURL,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] }
    }
  ]
})
