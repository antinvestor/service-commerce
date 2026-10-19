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
	"context"
	"fmt"
	"strings"

	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/types/known/structpb"
)

// profileNameProperty is the profile service's key for a person's name.
const profileNameProperty = "au_name"

// Buyer is the profile service identity an order is placed for.
type Buyer struct {
	ProfileID string
	ContactID string
}

// BuyerDirectory resolves buyers to profile service profiles. Commerce keeps
// no buyer records of its own: whoever buys, signed in or not, is a profile,
// so a shopper who later signs in with the same contact sees the same orders.
type BuyerDirectory interface {
	// Resolve returns the profile that owns contact (an email address or
	// phone number), creating a person profile named name when there is
	// none.
	Resolve(ctx context.Context, name, contact string) (*Buyer, error)
}

// NewProfileBuyerDirectory resolves buyers through the profile service. A nil
// client yields a nil directory.
func NewProfileBuyerDirectory(cli ProfileClient) BuyerDirectory {
	if cli == nil {
		return nil
	}
	return &profileBuyerDirectory{cli: cli}
}

type profileBuyerDirectory struct {
	cli ProfileClient
}

func (d *profileBuyerDirectory) Resolve(ctx context.Context, name, contact string) (*Buyer, error) {
	found, err := d.cli.GetByContact(ctx, profilev1.GetByContactRequest_builder{Contact: contact}.Build())
	switch {
	case err == nil && found.GetData().GetId() != "":
		return buyerFor(found.GetData(), contact), nil
	case err != nil && connect.CodeOf(err) != connect.CodeNotFound:
		return nil, fmt.Errorf("look up buyer: %w", err)
	}

	props, err := structpb.NewStruct(map[string]any{profileNameProperty: name})
	if err != nil {
		return nil, fmt.Errorf("buyer properties: %w", err)
	}
	created, err := d.cli.Create(ctx, profilev1.CreateRequest_builder{
		Type:       profilev1.ProfileType_PERSON,
		Contact:    contact,
		Properties: props,
	}.Build())
	if err != nil {
		return nil, fmt.Errorf("create buyer profile: %w", err)
	}
	return buyerFor(created.GetData(), contact), nil
}

// buyerFor picks the profile's contact matching what the buyer typed.
func buyerFor(profile *profilev1.ProfileObject, contact string) *Buyer {
	buyer := &Buyer{ProfileID: profile.GetId()}
	for _, c := range profile.GetContacts() {
		if strings.EqualFold(c.GetDetail(), contact) {
			buyer.ContactID = c.GetId()
			break
		}
	}
	return buyer
}
