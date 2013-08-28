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
    @tu.azzert ip == result[0]
    @tu.test_complete
  end

end

def test_resolve_aaaa
  ip = '::1'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveAAAA(ip))
  client.resolve_aaaa('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert '0:0:0:0:0:0:0:1' == result[0]
    @tu.test_complete
  end
end

def test_resolve_mx
  prio = 10
  name = 'mail.vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveMX(prio, name))
  client.resolve_mx('vertx.io')  do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert prio == result[0].priority
    @tu.azzert name == result[0].name
    @tu.test_complete
  end
end

def test_resolve_txt
  txt = 'Vert.x rocks'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveTXT(txt))
  client.resolve_txt('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert txt == result[0]
    @tu.test_complete
  end
end

def test_resolve_ns
  ns = 'ns.vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveNS(ns))
  client.resolve_ns('::1') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert ns == result[0]
    @tu.test_complete
  end
end

def test_resolve_cname
  cname = 'cname.vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveCNAME(cname))
  client.resolve_cname('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert cname == result[0]
    @tu.test_complete
  end
end

def test_resolve_ptr
  ptr = 'ptr.vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolvePTR(ptr))
  client.resolve_ptr('10.0.0.1.in-addr.arpa') do |err, result|
    @tu.azzert err == nil
    @tu.azzert ptr == result
    @tu.test_complete
  end
end

def test_resolve_srv
  priority = 10
  weight = 1
  port = 80
  target = 'vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testResolveSRV(priority, weight, port, target));
  client.resolve_srv('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result.length == 1
    @tu.azzert(priority == result[0].priority)
    @tu.azzert(weight == result[0].weight)
    @tu.azzert(port == result[0].port)
    @tu.azzert(target == result[0].target)
    @tu.test_complete
  end
end

def test_lookup_6
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testLookup6())
  client.lookup_6('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert '0:0:0:0:0:0:0:1' == result
    @tu.test_complete
  end
end

def test_lookup_4
  ip = '10.0.0.1'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testLookup4(ip))
  client.lookup_4('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert ip == result
    @tu.test_complete
  end
end

def test_lookup
  ip = '10.0.0.1'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testLookup4(ip))
  client.lookup('vertx.io') do |err, result|
    @tu.azzert err == nil
    @tu.azzert ip == result
    @tu.test_complete
  end
end

def test_lookup_non_existing
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testLookupNonExisting())
  client.lookup('notexist.vertx.io') do |err, result|
    @tu.azzert result == nil
    @tu.azzert 3 == err.code().code()
    @tu.test_complete
  end
end

def test_reverse_lookup_ipv4
  ptr = 'ptr.vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testReverseLookup(ptr))
  client.reverse_lookup('10.0.0.1') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result == ptr
    @tu.test_complete
    end
end

def test_reverse_lookup_ipv6
  ptr = 'ptr.vertx.io'
  client = prepare_dns(org.vertx.testtools.TestDnsServer.testReverseLookup(ptr))
  client.reverse_lookup('::1') do |err, result|
    @tu.azzert err == nil
    @tu.azzert result == ptr
    @tu.test_complete
  end
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