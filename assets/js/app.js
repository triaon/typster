// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `bun add some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import { createIcons, ArrowRight, CloudUpload, Command, Eye, File, Image, Moon, Share2, Sun, Type, Zap } from "lucide"
import { siGithub } from "simple-icons"
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/typster"
import topbar from "../vendor/topbar"
import * as Hooks from "./hooks"
import "@hugeicons/react"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {
    ...colocatedHooks,
    CodeMirror: Hooks.CodeMirror,
    Preview: Hooks.Preview,
    SaveStatus: Hooks.SaveStatus
  },
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

const Github = [["path", { d: siGithub.path, fill: "currentColor", stroke: "none" }]]

createIcons({ icons: { ArrowRight, CloudUpload, Command, Eye, File, Image, Moon, Share2, Sun, Type, Zap, Github } })

// ── Nav scroll state ─────────────────────────────────────────────────────
(function initNav() {
  const nav = document.querySelector('.mk-nav');
  if (!nav) return;
  const update = () => nav.classList.toggle('is-scrolled', window.scrollY > 16);
  window.addEventListener('scroll', update, { passive: true });
  update();
})();

// ── Marketing page animations ────────────────────────────────────────────
(function initMotion() {
  if (!('IntersectionObserver' in window)) return;

  // Enable motion styles only when JS is available (progressive enhancement)
  document.body.classList.add('js-motion');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

  // Observe individual reveal elements
  document.querySelectorAll('.mk-reveal').forEach(el => observer.observe(el));

  // Observe staggered groups
  document.querySelectorAll('.mk-reveal-group').forEach(el => {
    // Assign --i CSS variable to each child for stagger delay
    Array.from(el.children).forEach((child, i) => {
      child.style.setProperty('--i', i);
    });
    observer.observe(el);
  });
})();

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
