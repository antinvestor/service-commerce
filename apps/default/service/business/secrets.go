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

package business

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
)

// sealedPrefix marks a value sealed by SecretBox; anything else is a legacy
// plaintext value and is returned as stored.
const sealedPrefix = "v1:"

const secretKeyLength = 32

// SecretBox seals values such as shop webhook secrets before they are
// stored, so a database dump does not let anyone sign webhooks.
type SecretBox interface {
	Seal(plain string) (string, error)
	Open(stored string) (string, error)
}

// NewSecretBox builds an AES-256-GCM box from a base64 key of 32 bytes. An
// empty key yields a box that stores values as given (development only).
func NewSecretBox(keyBase64 string) (SecretBox, error) {
	keyBase64 = strings.TrimSpace(keyBase64)
	if keyBase64 == "" {
		return plainBox{}, nil
	}
	key, err := base64.StdEncoding.DecodeString(keyBase64)
	if err != nil {
		return nil, fmt.Errorf("decode secret key: %w", err)
	}
	if len(key) != secretKeyLength {
		return nil, fmt.Errorf("secret key must be %d bytes, got %d", secretKeyLength, len(key))
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("secret key cipher: %w", err)
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("secret key aead: %w", err)
	}
	return &gcmBox{aead: aead}, nil
}

// Sealing reports whether box encrypts, for a startup warning.
func Sealing(box SecretBox) bool {
	_, plain := box.(plainBox)
	return !plain
}

type plainBox struct{}

func (plainBox) Seal(plain string) (string, error) { return plain, nil }

func (plainBox) Open(stored string) (string, error) {
	if strings.HasPrefix(stored, sealedPrefix) {
		return "", errors.New("value is sealed but no secret key is configured")
	}
	return stored, nil
}

type gcmBox struct {
	aead cipher.AEAD
}

func (b *gcmBox) Seal(plain string) (string, error) {
	if plain == "" {
		return "", nil
	}
	nonce := make([]byte, b.aead.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return "", fmt.Errorf("secret nonce: %w", err)
	}
	sealed := b.aead.Seal(nonce, nonce, []byte(plain), nil)
	return sealedPrefix + base64.StdEncoding.EncodeToString(sealed), nil
}

func (b *gcmBox) Open(stored string) (string, error) {
	if !strings.HasPrefix(stored, sealedPrefix) {
		return stored, nil
	}
	raw, err := base64.StdEncoding.DecodeString(strings.TrimPrefix(stored, sealedPrefix))
	if err != nil {
		return "", fmt.Errorf("decode sealed value: %w", err)
	}
	size := b.aead.NonceSize()
	if len(raw) < size {
		return "", errors.New("sealed value is too short")
	}
	plain, err := b.aead.Open(nil, raw[:size], raw[size:], nil)
	if err != nil {
		return "", fmt.Errorf("open sealed value: %w", err)
	}
	return string(plain), nil
}
