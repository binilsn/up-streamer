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
        const rateEl = document.getElementById("metric-ingestion-rate");
        const eventsEl = document.getElementById("metric-events-per-sec");
        if (rateEl) rateEl.textContent = data.ingestion_rate_kbps;
        if (eventsEl) eventsEl.textContent = data.events_per_sec;

        const alertsEl = document.getElementById("metric-active-alerts");
        if (alertsEl && data.active_alerts !== undefined) {
            alertsEl.textContent = data.active_alerts;
        }

        const totalLogsEl = document.getElementById("metric-total-logs");
        if (totalLogsEl && data.total_logs_24h !== undefined) {
            totalLogsEl.textContent = this._formatCount(data.total_logs_24h);
        }

        const trendEl = document.getElementById("metric-total-logs-trend");
        if (trendEl && data.total_logs_trend_pct !== undefined) {
            const pct = data.total_logs_trend_pct;
            const sign = pct >= 0 ? "+" : "";
            const icon = pct >= 0 ? "trending_up" : "trending_down";
            const color = pct >= 0 ? "text-secondary-container" : "text-error";
            trendEl.innerHTML = `<span class="material-symbols-outlined text-[16px]">${icon}</span><span>${sign}${pct}% vs last period</span>`;
            trendEl.className = `flex items-center gap-1 font-body text-[12px] ${color} mb-4`;
        }
    }

    _formatCount(count) {
        if (count >= 1_000_000) {
            return (count / 1_000_000).toFixed(1) + "M";
        } else if (count >= 1_000) {
            return (count / 1_000).toFixed(1) + "K";
        }
        return count.toString();
    }
}
