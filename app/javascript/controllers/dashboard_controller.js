import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  connect() {
    this.subscription = consumer.subscriptions.create("DashboardMetricsChannel", {
      received: (data) => this._update(data)
    });
  }

  disconnect() {
    this.subscription?.unsubscribe();
  }

  _update(data) {
    const rateEl = document.getElementById("metric-ingestion-rate");
    const eventsEl = document.getElementById("metric-events-per-sec");
    if (rateEl) rateEl.textContent = data.ingestion_rate_kbps;
    if (eventsEl) eventsEl.textContent = data.events_per_sec;
  }
}
