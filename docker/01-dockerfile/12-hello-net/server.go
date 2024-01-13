package main

import (
    "fmt"
    "net/http"
	"os"
	"io"
)

func hello(w http.ResponseWriter, req *http.Request) {
	Hostname, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	// fmt.Printf("Hello from: %s\n", Hostname)
	io.WriteString(w,fmt.Sprintf("Hello from %s!\n", Hostname))
}

func headers(w http.ResponseWriter, req *http.Request) {

    for name, headers := range req.Header {
        for _, h := range headers {
            fmt.Fprintf(w, "%v: %v\n", name, h)
        }
    }
}

func main() {

    http.HandleFunc("/", hello)
    http.HandleFunc("/headers", headers)

    http.ListenAndServe(":"+os.Getenv("port"), nil)
}