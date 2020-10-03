// Fileserver is a minimal service for to serving contents from the file system over HTTP.

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	filesDir := os.Getenv("WORK_PATH")
	if filesDir == "" {
		filesDir = "/tmp"
	}
	fs := http.FileServer(http.Dir(filesDir))
	http.Handle("/", fs)

	addr := os.Getenv("FILESERVER_ADDR")
        if addr == "" {
	    addr = ":80"
	}
	s := &http.Server{
		Addr: addr,
	}
	fmt.Println("服务器启动中 %s : %s..\n", filesDir,addr)
	log.Fatal(s.ListenAndServe())
}