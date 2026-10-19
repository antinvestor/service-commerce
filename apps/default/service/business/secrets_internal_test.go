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
	"encoding/base64"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSecretBox(t *testing.T) {
	t.Parallel()
	key := base64.StdEncoding.EncodeToString([]byte(strings.Repeat("k", secretKeyLength)))
	box, err := NewSecretBox(key)
	require.NoError(t, err)
	require.True(t, Sealing(box))

	sealed, err := box.Seal("s3cret")
	require.NoError(t, err)
	require.True(t, strings.HasPrefix(sealed, sealedPrefix))
	require.NotContains(t, sealed, "s3cret")
	again, err := box.Seal("s3cret")
	require.NoError(t, err)
	require.NotEqual(t, sealed, again, "a fresh nonce per seal")

	opened, err := box.Open(sealed)
	require.NoError(t, err)
	require.Equal(t, "s3cret", opened)

	legacy, err := box.Open("plain-secret")
	require.NoError(t, err)
	require.Equal(t, "plain-secret", legacy, "values stored before sealing still work")

	empty, err := box.Seal("")
	require.NoError(t, err)
	require.Empty(t, empty)

	otherKey := base64.StdEncoding.EncodeToString([]byte(strings.Repeat("x", secretKeyLength)))
	other, err := NewSecretBox(otherKey)
	require.NoError(t, err)
	_, err = other.Open(sealed)
	require.Error(t, err, "the wrong key cannot open it")

	plain, err := NewSecretBox("")
	require.NoError(t, err)
	require.False(t, Sealing(plain))
	_, err = plain.Open(sealed)
	require.Error(t, err, "a sealed value needs the key")

	_, err = NewSecretBox("not-base64!")
	require.Error(t, err)
	_, err = NewSecretBox(base64.StdEncoding.EncodeToString([]byte("short")))
	require.Error(t, err)
}
