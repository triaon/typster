import { test as setup, expect } from '@playwright/test'
import path from 'path'
import { fileURLToPath } from 'url'
import fs from 'fs'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
export const authFile = path.join(__dirname, '.auth/session.json')

setup('authenticate', async ({ page, request }) => {
  const email = `e2e-${Date.now()}@typster.test`

  // Clear the mailbox so we get exactly the email we expect
  await request.post('/dev/mailbox/clear')

  // Navigate to registration and wait for LiveView to fully mount
  await page.goto('/users/register')
  await page.waitForLoadState('networkidle')

  // pressSequentially triggers real DOM input events, which phx-change requires
  await page.locator('#registration_form input[type="email"]').pressSequentially(email, { delay: 30 })
  await page.locator('#registration_form button[type="submit"]').click()

  // Poll the mailbox until the registration email arrives (up to 15s)
  let magicLink = null
  await expect.poll(
    async () => {
      const res = await request.get('/dev/mailbox/json')
      const { data: emails } = await res.json()
      const latest = emails[emails.length - 1]
      if (!latest) return null
      const match = (latest.text_body ?? '').match(/http[^\s]+\/users\/log-in\/[^\s]+/)
      if (match) magicLink = match[0]
      return magicLink
    },
    { timeout: 15_000, message: 'Registration email never arrived in the Swoosh mailbox' }
  ).not.toBeNull()

  // Navigate to the magic link to complete authentication
  await page.goto(magicLink)
  await expect(page).not.toHaveURL(/log-in/, { timeout: 10_000 })

  fs.mkdirSync(path.dirname(authFile), { recursive: true })
  await page.context().storageState({ path: authFile })
})
