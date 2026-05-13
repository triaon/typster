import { setImportWasmModule } from "@myriaddreamin/typst-ts-web-compiler"
import { $typst } from "@myriaddreamin/typst.ts/contrib/snippet"

// Fetch WASM from a known static path rather than relying on import.meta.url
// (which resolves to the bundle location, not the original package directory)
setImportWasmModule(async (wasmName) => {
  const response = await fetch(`/assets/js/${wasmName}`)
  if (!response.ok) throw new Error(`Failed to fetch ${wasmName}: ${response.status}`)
  return response.arrayBuffer()
})

let initialized = false

async function ensureInitialized() {
  if (initialized) return
  initialized = true
  await $typst.svg({ mainContent: "" }).catch(() => {})
}

self.onmessage = async function (event) {
  const { type, content, project } = event.data

  if (type === "compile") {
    try {
      await ensureInitialized()

      $typst.setMainFilePath("/main.typ")
      await $typst.addSource("/main.typ", content || "")

      if (project?.sources) {
        for (const source of project.sources) {
          if (source.path !== "/main.typ" && source.path !== "main.typ") {
            await $typst.addSource(`/${source.path}`, source.content || "")
          }
        }
      }

      const svg = await $typst.svg({ mainFilePath: "/main.typ" })

      self.postMessage({ type: "render", data: { svg } })
    } catch (error) {
      self.postMessage({ type: "error", data: { message: error.message } })
    }
  }
}
