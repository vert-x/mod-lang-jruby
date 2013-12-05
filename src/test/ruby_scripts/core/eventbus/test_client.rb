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

@tu = TestUtils.new
@tu.check_thread

def test_simple_send

  json = {'message' => 'hello world!'}
  address = "some-address"

  id = EventBus.register_handler(address) do |msg|
    @tu.azzert(msg.body['message'] == json['message'])
    @tu.azzert(EventBus.unregister_handler(id) == EventBus)
    @tu.azzert(msg.address == address)
    @tu.test_complete
  end

  @tu.azzert(id != nil)

  @tu.azzert(EventBus.send(address, json) == EventBus)
end

def test_send_empty

  json = {}
  address = "some-address"

  id = EventBus.register_handler(address) do |msg|
    @tu.azzert(msg.body.empty?)
    @tu.azzert(EventBus.unregister_handler(id) == EventBus)
    @tu.azzert(msg.address == address)
    @tu.test_complete
  end

  @tu.azzert(id != nil)

  @tu.azzert(EventBus.send(address, json) == EventBus)
end

def test_reply

  json = {'message' => 'hello world!'}
  address = "some-address"
  reply = {'cheese' => 'stilton!'}

  id = EventBus.register_handler(address) do |msg|
    @tu.azzert(msg.body['message'] == json['message'])
    @tu.azzert(msg.address == address)
    msg.reply(reply)
  end

  @tu.azzert(id != nil)

  bus = EventBus.send(address, json) do |msg|
    @tu.azzert(msg.body['cheese'] == reply['cheese'])
    @tu.azzert(EventBus.unregister_handler(id) == EventBus)
    @tu.test_complete
  end
  @tu.azzert(bus == EventBus)

end

def test_empty_reply

  json = {'message' => 'hello world!'}
  address = "some-address"
  reply = {}

  id = EventBus.register_handler(address) do |msg|
    @tu.azzert(msg.body['message'] == json['message'])
    msg.reply(reply)
  end

  @tu.azzert(id != nil)

  bus = EventBus.send(address, json) do |msg|
    @tu.azzert(msg.body.empty?)
    @tu.azzert(EventBus.unregister_handler(id) == EventBus)
    @tu.test_complete
  end
  @tu.azzert(bus == EventBus)
end

def test_send_unregister_send

  json = {'message' => 'hello world!'}
  address = "some-address"

  received = false

  id = EventBus.register_handler(address) do |msg|
    @tu.azzert(false, "handler already called") if received
    @tu.azzert(msg.body['message'] == json['message'])
    @tu.azzert(EventBus.unregister_handler(id) == EventBus)
    received = true
    # End test on a timer to give time for other messages to arrive
    Vertx.set_timer(100) { @tu.test_complete }
  end

  @tu.azzert(id != nil)

  (1..2).each do
    @tu.azzert(EventBus.send(address, json) == EventBus)
  end
end

def test_send_multiple_matching_handlers

  json = {'message' => 'hello world!'}
  address = "some-address"

  num_handlers = 10
  count = 0

  (1..num_handlers).each do
    id = EventBus.register_handler(address) do |msg|
      @tu.azzert(msg.body['message'] == json['message'])
      #@tu.azzert(msg.address == address)
      @tu.azzert(EventBus.unregister_handler(id) == EventBus)
      count += 1
      @tu.test_complete if count == num_handlers
    end
  end

  @tu.azzert(EventBus.publish(address, json) == EventBus)
end

def test_echo_string
  echo("foo")
end

def test_echo_fixnum
  echo(12345)
end

def test_echo_float
  echo(1.2345)
end

def test_echo_boolean_true
  echo(true)
end

def test_echo_boolean_false
  echo(false)
end

def test_echo_json
  json = {"foo" => "bar", "x" => 1234, "y" => 3.45355, "z" => true, "a" => false}
  echo(json)
end

def echo(msg)
  address = "some-address"

  id = EventBus.register_handler(address) { |received|
    @tu.check_thread
    @tu.azzert(EventBus.unregister_handler(id) == EventBus)
    received.reply(received.body)
  }
  bus = EventBus.send(address, msg) { |reply|
    if reply.body.is_a? Hash
      reply.body.each do |k, v|
        @tu.azzert(msg[k] == v)
      end
    else
      @tu.azzert(msg == reply.body)
    end
    @tu.test_complete
  }
  @tu.azzert(bus == EventBus)
end

def test_reply_of_reply_of_reply

  address = "some-address"

  id = EventBus.register_handler(address) do |msg|
    @tu.azzert("message" == msg.body)
    @tu.azzert(msg.address == address)
    msg.reply("reply") do |reply|
      @tu.azzert("reply-of-reply" == reply.body)
      reply.reply("reply-of-reply-of-reply")
    end
  end

  bus = EventBus.send(address, "message") do |reply|
    @tu.azzert("reply" == reply.body);
    reply.reply("reply-of-reply") do |reply|
      @tu.azzert("reply-of-reply-of-reply" == reply.body);
      @tu.azzert(EventBus.unregister_handler(id) == EventBus)
      @tu.test_complete
    end
  end
  @tu.azzert(bus == EventBus)
end

def vertx_stop
  @tu.check_thread
  @tu.unregister_all
  @tu.app_stopped
end

@tu.register_all(self)
@tu.app_ready
