import { test as setup, expect } from '@playwright/test'
import path from 'path'
import { fileURLToPath } from 'url'
import fs from 'fs'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
export const authFile = path.join(__dirname, '.auth/session.json')

setup('authenticate', async ({ page }) => {
  const email = `e2e-${Date.now()}-${Math.random().toString(36).slice(2)}@typster.test`

  // Load any page first so Phoenix sets a session cookie and CSRF token
  await page.goto('/')
  const csrfToken = await page.evaluate(
    () => document.querySelector('meta[name="csrf-token"]')?.content ?? ''
  )

  const response = await page.request.post('/dev/test-login', {
    form: { email, _csrf_token: csrfToken },
  })

  expect(response.status(), 'E2E test-login endpoint failed').toBeLessThan(400)

  fs.mkdirSync(path.dirname(authFile), { recursive: true })
  await page.context().storageState({ path: authFile })
})
