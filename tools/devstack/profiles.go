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
	"context"
	"strings"
	"sync"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/structpb"
)

// profileService stands in for service-profile with the calls commerce
// makes: find a person by contact, create one, and read one back. Profiles
// live in memory.
type profileService struct {
	profilev1connect.UnimplementedProfileServiceHandler

	mu        sync.Mutex
	byID      map[string]*profilev1.ProfileObject
	byContact map[string]string
}

func newProfileService() *profileService {
	return &profileService{byID: map[string]*profilev1.ProfileObject{}, byContact: map[string]string{}}
}

// ensure returns the profile for contact, creating it with id and name when
// there is none. Signing in uses it so the dev user is a profile too.
func (s *profileService) ensure(id, name, contact string) *profilev1.ProfileObject {
	s.mu.Lock()
	defer s.mu.Unlock()
	if known, ok := s.byContact[contactKey(contact)]; ok {
		return s.copyOf(known)
	}
	props, _ := structpb.NewStruct(map[string]any{"au_name": name})
	return s.add(id, contact, props)
}

func (s *profileService) GetById( //nolint:revive,staticcheck // name fixed by the generated interface
	_ context.Context,
	req *profilev1.GetByIdRequest,
) (*profilev1.GetByIdResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	profile := s.copyOf(req.GetId())
	if profile == nil {
		return nil, connect.NewError(connect.CodeNotFound, "profile not found")
	}
	return profilev1.GetByIdResponse_builder{Data: profile}.Build(), nil
}

func (s *profileService) GetByContact(
	_ context.Context,
	req *profilev1.GetByContactRequest,
) (*profilev1.GetByContactResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	id, ok := s.byContact[contactKey(req.GetContact())]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "profile not found")
	}
	return profilev1.GetByContactResponse_builder{Data: s.copyOf(id)}.Build(), nil
}

func (s *profileService) Create(
	_ context.Context,
	req *profilev1.CreateRequest,
) (*profilev1.CreateResponse, error) {
	contact := strings.TrimSpace(req.GetContact())
	if contact == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "contact is required")
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, taken := s.byContact[contactKey(contact)]; taken {
		return nil, connect.NewError(connect.CodeAlreadyExists, "contact already belongs to a profile")
	}
	return profilev1.CreateResponse_builder{Data: s.add(util.IDString(), contact, req.GetProperties())}.Build(), nil
}

// add stores a new person profile; callers hold mu.
func (s *profileService) add(id, contact string, props *structpb.Struct) *profilev1.ProfileObject {
	kind := profilev1.ContactType_EMAIL
	if !strings.Contains(contact, "@") {
		kind = profilev1.ContactType_MSISDN
	}
	profile := profilev1.ProfileObject_builder{
		Id:         id,
		Type:       profilev1.ProfileType_PERSON,
		Properties: props,
		State:      commonv1.STATE_ACTIVE,
		Contacts: []*profilev1.ContactObject{profilev1.ContactObject_builder{
			Id: util.IDString(), Type: kind, Detail: contact, State: commonv1.STATE_ACTIVE,
		}.Build()},
	}.Build()
	s.byID[id] = profile
	s.byContact[contactKey(contact)] = id
	return s.copyOf(id)
}

// copyOf returns a copy of the profile with id, or nil; callers hold mu.
func (s *profileService) copyOf(id string) *profilev1.ProfileObject {
	profile, ok := s.byID[id]
	if !ok {
		return nil
	}
	c, _ := proto.Clone(profile).(*profilev1.ProfileObject)
	return c
}

func contactKey(contact string) string { return strings.ToLower(strings.TrimSpace(contact)) }
