import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

const Chart = window.Chart;

const MAX_POINTS = 60;
const CHART_COLORS = {
    primary: "#0052FF",
    secondary: "#FF8C00",
    grid: "rgba(226, 232, 240, 0.4)",
    text: "#94A3B8",
};

export default class extends Controller {
    connect() {
        console.log("[LogVolumeChart] connecting");
        this.dataPoints = [];
        this.labels = [];

        try {
            this.chart = this._buildChart();
            console.log("[LogVolumeChart] chart created");
        } catch (e) {
            console.error("[LogVolumeChart] chart creation failed:", e);
        }

        this.subscription = consumer.subscriptions.create(
            "DashboardMetricsChannel",
            {
                received: (data) => this._push(data),
            },
        );
        console.log("[LogVolumeChart] subscribed to DashboardMetricsChannel");
    }

    disconnect() {
        this.subscription?.unsubscribe();
        this.chart?.destroy();
    }

    _buildChart() {
        return new Chart(this.element, {
            type: "line",
            data: {
                labels: this.labels,
                datasets: [
                    {
                        label: "Ingestion Rate",
                        data: this.dataPoints,
                        borderColor: CHART_COLORS.primary,
                        backgroundColor: "rgba(0, 82, 255, 0.04)",
                        borderWidth: 2,
                        pointRadius: 0,
                        pointHoverRadius: 4,
                        pointHoverBackgroundColor: CHART_COLORS.primary,
                        tension: 0.3,
                        fill: true,
                    },
                ],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: { duration: 200 },
                interaction: {
                    intersect: false,
                    mode: "index",
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: "#0F172A",
                        titleFont: { family: "Inter, sans-serif", size: 12 },
                        bodyFont: { family: "Inter, sans-serif", size: 13 },
                        padding: 10,
                        cornerRadius: 6,
                        displayColors: false,
                        callbacks: {
                            label: (ctx) => `${ctx.parsed.y.toFixed(1)} KB/S`,
                        },
                    },
                },
                scales: {
                    x: {
                        display: true,
                        grid: { color: CHART_COLORS.grid },
                        ticks: {
                            color: CHART_COLORS.text,
                            font: { size: 11 },
                            maxTicksLimit: 8,
                            callback: (_, i) => this.labels[i] || "",
                        },
                    },
                    y: {
                        display: true,
                        grid: { color: CHART_COLORS.grid },
                        ticks: {
                            color: CHART_COLORS.text,
                            font: { size: 11 },
                            callback: (v) => `${v} KB/S`,
                        },
                        beginAtZero: true,
                    },
                },
            },
        });
    }

    _push(data) {
        const now = new Date();
        const label = now.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
        });

        this.labels.push(label);
        this.dataPoints.push(data.ingestion_rate_kbps);

        if (this.labels.length > MAX_POINTS) {
            this.labels.shift();
            this.dataPoints.shift();
        }

        this.chart.update();
    }
}
