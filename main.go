package main

import (
	"bufio"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"github.com/joho/godotenv"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
)

var apiKey string
var targetHost string

func init() {
	_ = godotenv.Load()

	apiKey = os.Getenv("API_SECRET")
	targetHost = os.Getenv("TARGET_HOST")

	created := false

	if apiKey == "" {
		apiKey = generateSecret()
		created = true
	}

	if targetHost == "" {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("🔧 Enter target domain (e.g. forkskill.com): ")
		input, _ := reader.ReadString('\n')
		targetHost = strings.TrimSpace(input)
		created = true
	}

	if created {
		saveEnv(apiKey, targetHost)
		fmt.Println("✅ Configuration saved to .env")
		fmt.Println("🔐 Your API_SECRET:", apiKey)
	}
}

func main() {
	http.HandleFunc("/proxy", handleProxy)
	log.Println("🚀 Proxy server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleProxy(w http.ResponseWriter, r *http.Request) {
	clientKey := r.Header.Get("X-API-Key")
	if clientKey != apiKey {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	rawURL := r.URL.Query().Get("url")
	if rawURL == "" {
		http.Error(w, "Missing 'url' parameter", http.StatusBadRequest)
		return
	}

	parsedURL, err := url.Parse(rawURL)
	if err != nil || !strings.Contains(parsedURL.Host, targetHost) {
		http.Error(w, "Forbidden: Only "+targetHost+" is allowed", http.StatusForbidden)
		return
	}

	req, err := http.NewRequest("GET", rawURL, nil)
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	req.Header.Set("User-Agent", r.Header.Get("User-Agent"))
	req.Header.Set("Accept", r.Header.Get("Accept"))

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		http.Error(w, "Error fetching upstream", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	for k, v := range resp.Header {
		w.Header()[k] = v
	}
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}

func generateSecret() string {
	bytes := make([]byte, 16)
	_, _ = rand.Read(bytes)
	return hex.EncodeToString(bytes)
}

func saveEnv(secret, host string) {
	content := fmt.Sprintf("API_SECRET=%s\nTARGET_HOST=%s\n", secret, host)
	os.WriteFile(".env", []byte(content), 0644)
}
