import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    this.subscription = consumer.subscriptions.create("DashboardMetricsChannel", {
      received: (data) => this._update(data)
    })
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  _update(data) {
    const rateEl = document.getElementById("footer-ingestion-rate")
    const eventsEl = document.getElementById("footer-events-per-sec")
    if (rateEl) rateEl.textContent = data.ingestion_rate_kbps + " KB/S"
    if (eventsEl) eventsEl.textContent = data.events_per_sec
  }
}
