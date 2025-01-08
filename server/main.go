package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/gorilla/mux"
)

type Item struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

var items = []Item{
	{1, "Car"},
	{2, "Knife"},
}

func GetItemsHandler(w http.ResponseWriter, r *http.Request) {
	var path string = r.URL.Path[1:]
	log.Printf("Received request: %s", path)
	time.Sleep(5 * time.Second)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(items)
	log.Printf("Request handled: %s", path)
}

var healthy int32

func HealthHandler(w http.ResponseWriter, r *http.Request) {
	if atomic.LoadInt32(&healthy) == 1 {
		log.Print("Server reported healthy")
		w.WriteHeader(http.StatusOK)
		return
	}
	log.Print("Server reported unavailable")
	w.WriteHeader(http.StatusServiceUnavailable)
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/items", GetItemsHandler).Methods("GET")
	router.HandleFunc("/health", HealthHandler).Methods("GET")
	server := http.Server{
		Addr:    "0.0.0.0:8080",
		Handler: router,
	}

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)

	log.Printf("Starting server")
	go server.ListenAndServe()
	log.Printf("Server started")

	// Server is now healthy
	atomic.StoreInt32(&healthy, 1)

	<-stop

	log.Print("Shutdowning server")
	atomic.StoreInt32(&healthy, 0)
	if err := server.Shutdown(context.Background()); err != nil {
		log.Fatalf("Failed to shutdown server: %v", err)
	}

	log.Print("Server shutdown gracefully")
	os.Exit(0)
}
