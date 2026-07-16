import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
    connect() {
        this.subscription = consumer.subscriptions.create(
            "DashboardMetricsChannel",
            {
                received: (data) => this._update(data),
            },
        );
    }

    disconnect() {
        this.subscription?.unsubscribe();
    }

    _update(data) {
        const rateEl = document.getElementById("footer-ingestion-rate");
        const eventsEl = document.getElementById("footer-events-per-sec");
        if (rateEl) rateEl.textContent = data.ingestion_rate_kbps + " KB/S";
        if (eventsEl) eventsEl.textContent = data.events_per_sec;

        const memUsedEl = document.getElementById("footer-memory-used");
        const memTotalEl = document.getElementById("footer-memory-total");
        const cpuEl = document.getElementById("footer-cpu-pct");
        if (memUsedEl && data.memory_used_mb != null) {
            memUsedEl.textContent = (data.memory_used_mb / 1024).toFixed(1);
        }
        if (memTotalEl && data.memory_total_mb != null) {
            memTotalEl.textContent = (data.memory_total_mb / 1024).toFixed(1);
        }
        if (cpuEl && data.cpu_pct != null) {
            cpuEl.textContent = data.cpu_pct.toFixed(1);
        }

        const uptimeEl = document.getElementById("footer-uptime");
        if (uptimeEl && data.uptime) {
            uptimeEl.textContent = data.uptime;
        }
    }
}
