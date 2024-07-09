// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Prism from "../vendor/prism.js"

import { SessionChannelParticipant } from "./channel_participant_hook.js"
import { SessionChannelMonitor } from "./channel_monitor_hook.js"
import { ChartJS } from "./charts.js"
import { JSPDF } from "./download_pdf.js"
import { AceEditorHook } from "./ace_editor_hook.js"

let Hooks = {}
Hooks.SessionChannelParticipant = SessionChannelParticipant;
Hooks.SessionChannelMonitor = SessionChannelMonitor;
Hooks.ChartJS = ChartJS;
Hooks.jsPDF = JSPDF;
Hooks.AceEditor = AceEditorHook;
Hooks.PrismInitializer = {
  mounted() {Prism.highlightAll();},
  updated() {Prism.highlightAll();}
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#d354ffe6"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
