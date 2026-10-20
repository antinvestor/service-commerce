// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"io/fs"
	"net/http"
	"os"
	"path"
	"strings"
)

// spa serves a built web app from dir the way its production host does:
// files as they are, a directory's index.html (the sign-in callback page),
// and the app's index.html for every other path so its router can take over.
func spa(dir string) http.Handler {
	site := os.DirFS(dir)
	files := http.FileServerFS(site)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		name := strings.TrimPrefix(path.Clean("/"+r.URL.Path), "/")
		if name == "" {
			name = "."
		}
		if info, err := fs.Stat(site, name); err == nil {
			if !info.IsDir() {
				files.ServeHTTP(w, r)
				return
			}
			if index := path.Join(name, "index.html"); fileExists(site, index) {
				http.ServeFileFS(w, r, site, index)
				return
			}
		}
		if path.Ext(name) != "" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Cache-Control", "no-store")
		http.ServeFileFS(w, r, site, "index.html")
	})
}

func fileExists(site fs.FS, name string) bool {
	info, err := fs.Stat(site, name)
	return err == nil && !info.IsDir()
}
