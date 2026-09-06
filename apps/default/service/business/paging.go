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
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect"

	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// pageFromSearch translates the common SearchRequest cursor into a repository
// page. An undecodable cursor is an InvalidArgument.
func pageFromSearch(search *commonv1.SearchRequest) (repository.Page, error) {
	page := repository.Page{}
	cursor := search.GetCursor()
	if cursor == nil {
		return page, nil
	}
	page.Limit = int(cursor.GetLimit())
	after, err := repository.DecodePageKey(cursor.GetPage())
	if err != nil {
		return page, connect.NewError(connect.CodeInvalidArgument, err)
	}
	page.After = after
	return page, nil
}

// nextCursor encodes the key of the next page, or "" on the last page.
func nextCursor(key *repository.PageKey) string {
	return repository.EncodePageKey(key)
}
