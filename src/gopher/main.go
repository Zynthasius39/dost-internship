package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Count of all HTTP requests",
		},
		[]string{"endpoint", "method", "status"},
	)
	httpDuration = prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name: "http_request_duration_seconds",
        Help: "Duration of HTTP requests in seconds",
        Buckets: []float64{
            0.0001, // 0.1ms
            0.0005, // 0.5ms
            0.001,  // 1ms
            0.002,  // 2ms
            0.003,  // 3ms
            0.005,  // 5ms
            0.0075, // 7.5ms
            0.01,   // 10ms
            0.025,  // 25ms
            0.05,   // 50ms
            0.1,    // 100ms
        },
    },
    []string{"endpoint"},
	)
	httpErrorsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_errors_total",
			Help: "Count of all HTTP errors (4xx and 5xx)",
		},
		[]string{"endpoint", "status"},
	)
)

func init() {
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(httpDuration)
	prometheus.MustRegister(httpErrorsTotal)
}

func monitor(endpoint string, handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		
		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
		
		handler(rw, r)

		duration := time.Since(start).Seconds()
		httpDuration.WithLabelValues(endpoint).Observe(duration)
		
		statusStr := http.StatusText(rw.statusCode)
		if statusStr == "" {
			statusStr = "Unknown"
		}
		httpRequestsTotal.WithLabelValues(endpoint, r.Method, statusStr).Inc()

		if rw.statusCode >= 400 {
			httpErrorsTotal.WithLabelValues(endpoint, statusStr).Inc()
		}
	}
}

type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

func main() {
	http.HandleFunc("/", monitor("root", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{"error": "Not Found"})
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"version": "1.0.2"})
	}))

	http.HandleFunc("/health", monitor("health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
	}))

	http.Handle("/metrics", promhttp.Handler())

	log.Println("Server 8080 portunda başladıldı...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server xətası: %v", err)
	}
}
