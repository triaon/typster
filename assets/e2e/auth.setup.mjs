import { test as setup, expect } from '@playwright/test'
import path from 'path'
import { fileURLToPath } from 'url'
import fs from 'fs'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
export const authFile = path.join(__dirname, '.auth/session.json')

setup('authenticate', async ({ page }) => {
  const email = `e2e-${Date.now()}-${Math.random().toString(36).slice(2)}@typster.test`

  // Load the home page first so Phoenix initialises a session and sets the CSRF token.
  await page.goto('/')
  const csrfToken = await page.evaluate(
    () => document.querySelector('meta[name="csrf-token"]')?.content ?? ''
  )

  // Submit the form via the browser (not page.request) so the resulting session
  // cookie is stored directly in the browser context.
  await page.evaluate(({ email, csrfToken }) => {
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/dev/test-login'

    const addField = (name, value) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = name
      input.value = value
      form.appendChild(input)
    }

    addField('email', email)
    addField('_csrf_token', csrfToken)
    document.body.appendChild(form)
    form.submit()
  }, { email, csrfToken })

  // Wait for the redirect after login to settle on an authenticated page.
  await page.waitForURL(/\/projects/, { timeout: 15_000 })

  fs.mkdirSync(path.dirname(authFile), { recursive: true })
  await page.context().storageState({ path: authFile })
})
