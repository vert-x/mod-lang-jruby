# Copyright 2011-2012 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "vertx"
include Vertx
require "test_utils"
require 'socket'


@tu = TestUtils.new
@tu.check_thread
@client = DnsClient.new(Addrinfo.tcp('127.0.0.1', 53))
@logger = Vertx.logger


def test_resolve_a
  # TODO: Add me
  @tu.test_complete
end

def test_resolve_aaaa
  # TODO: Add me
 @tu.test_complete
end

def test_resolve_mx
  # TODO: Add me
  @tu.test_complete
end

def test_resolve_txt
  # TODO: Add me
  @tu.test_complete
end

def test_resolve_ns
  # TODO: Add me
  @tu.test_complete
end

def test_resolve_cname
  # TODO: Add me
  @tu.test_complete
end

def test_resolve_ptr
  # TODO: Add me
  @tu.test_complete
end

def test_resolve_srv
  # TODO: Add me
  @tu.test_complete
end

def test_lookup_6
  # TODO: Add me
  @tu.test_complete
end

def test_lookup_4
  # TODO: Add me
  @tu.test_complete
end

def test_lookup
  # TODO: Add me
  @tu.test_complete
end

def vertx_stop
  @tu.unregister_all
  @tu.app_stopped
end

@tu.register_all(self)
@tu.app_ready
