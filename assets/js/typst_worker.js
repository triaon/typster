let worker = null
let previewContainer = null
let pushEvent = null

export function initTypstWorker(hook) {
  if (typeof Worker !== "undefined") {
    if (hook && typeof hook.pushEvent === "function") {
      pushEvent = hook.pushEvent.bind(hook)
    }

    previewContainer = hook ? hook.el : document.getElementById("preview-container")

    if (!worker) {
      worker = new Worker("/assets/js/typst_worker_impl.js", { type: "module" })

      worker.onmessage = (event) => {
        const { type, data } = event.data

        if (type === "render") {
          if (previewContainer && data.svg) {
            let svgContainer = previewContainer.querySelector("#typst-svg-output")
            if (!svgContainer) {
              svgContainer = document.createElement("div")
              svgContainer.id = "typst-svg-output"
              svgContainer.style.cssText = "width:100%;overflow:auto;"
              const placeholder = previewContainer.querySelector("#preview-placeholder")
              if (placeholder) {
                placeholder.style.display = "none"
              }
              previewContainer.appendChild(svgContainer)
            }
            svgContainer.innerHTML = data.svg
          }
        } else if (type === "error") {
          if (typeof pushEvent === "function") {
            pushEvent("preview_error", { message: data.message || "Typst preview failed" })
          }
          console.error("Typst compilation error:", data)
        }
      }

      worker.onerror = (error) => {
        console.error("Typst worker error:", error)
      }

      window.typstWorker = worker
    }

    return worker
  } else {
    console.warn("Web Workers are not supported in this browser")
    return null
  }
}

export function compileTypst(content, project = {}) {
  if (!worker) {
    const container = document.getElementById("preview-container")
    if (container) {
      const hook = container.__liveSocketHook || null
      if (hook && typeof hook.pushEvent === "function") {
        initTypstWorker(hook)
      } else {
        initTypstWorker(null)
      }
    } else {
      initTypstWorker(null)
    }
  }

  if (!pushEvent && previewContainer) {
    const hook = previewContainer.__liveSocketHook || null
    if (hook && typeof hook.pushEvent === "function") {
      pushEvent = hook.pushEvent.bind(hook)
    }
  }

  if (worker) {
    worker.postMessage({
      type: "compile",
      content: content,
      project: project
    })
  }
}

export function destroyTypstWorker() {
  if (worker) {
    worker.terminate()
    worker = null
    previewContainer = null
    pushEvent = null
    window.typstWorker = null
  }
}
