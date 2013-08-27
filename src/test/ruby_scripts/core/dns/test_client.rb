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
@logger = Vertx.logger

def prepare_dns(server)
  server.start()
  @server = server
  DnsClient.new(Addrinfo.tcp('127.0.0.1', server.getTransports()[0].getAcceptor().getLocalAddress().getPort()))
end

def test_resolve_a
  ip = '10.0.0.1'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveA(ip))
  client.resolve_a('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert ip == result[0].ip_address
    @tu.test_complete
  end

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


@tu.register_all(self)
@tu.app_ready

def vertx_stop
  if defined? @server
    @server.stop()
  end
  @tu.unregister_all
  @tu.app_stopped
end