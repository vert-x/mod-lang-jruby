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

def test_send_receive
  @peer1 = DatagramSocket.new
  @peer2 = DatagramSocket.new
  @peer2.exception_handler do |err|
    @tu.azzert err != nil
    @tu.azzert false
  end

  @peer2.listen(1234, '127.0.0.1') do |err, result|
    @tu.check_thread
    @tu.azzert err == nil
    @tu.azzert result == @peer2
    buffer = TestUtils::gen_buffer(128)

    @peer2.data_handler do |packet|
      @tu.check_thread
      @tu.azzert(TestUtils.buffers_equal(packet.data, buffer))

      @tu.test_complete
    end

    @peer1.send('127.0.0.1', 1234, buffer) do |err, result|
      @tu.check_thread
      @tu.azzert result == @peer1
      @tu.azzert err == nil
    end
  end
end

def test_listen_host_port
  @peer2 = DatagramSocket.new
  @peer2.listen(1234, '127.0.0.1') do |err, result|
    @tu.check_thread
    @tu.azzert result == @peer2
    @tu.azzert err == nil
    @tu.test_complete
  end
end


def test_listen_port
  @peer2 = DatagramSocket.new
  @peer2.listen(1234) do |err, result|
    @tu.check_thread
    @tu.azzert result == @peer2
    @tu.azzert err == nil
    @tu.test_complete
  end
end

def test_listen_same_port_multiple_times
  @peer1 = DatagramSocket.new
  @peer2 = DatagramSocket.new
  @peer2.listen(1234) do |err, result|
    @tu.check_thread
    @tu.azzert result == @peer2
    @tu.azzert err == nil
    @peer1.listen(1234) do |err, result|
      @tu.check_thread
      @tu.azzert err != nil
      @tu.azzert result == nil
      @tu.test_complete
    end
  end
end

def test_echo
  @peer1 = DatagramSocket.new
  @peer2 = DatagramSocket.new
  @peer1.exception_handler do |err|
    @tu.azzert err != nil
    @tu.azzert false
  end
  @peer2.exception_handler do |err|
    @tu.azzert err != nil
    @tu.azzert false
  end

  @peer2.listen(1234, '127.0.0.1') do |err, result|
    @tu.check_thread
    @tu.azzert err == nil
    @tu.azzert result == @peer2
    buffer = TestUtils::gen_buffer(128)

    @peer2.data_handler do |packet|
      @tu.check_thread
      @tu.azzert(TestUtils.buffers_equal(packet.data, buffer))
      @peer2.send(packet.sender.ip_address, packet.sender.ip_port, buffer) do |err, result|
        @tu.check_thread
        @tu.azzert err == nil
        @tu.azzert result == @peer2
      end
    end

    @peer1.listen(1235, '127.0.0.1') do |err, result|
      @peer1.data_handler do |packet|
        @tu.check_thread
        @tu.azzert(TestUtils.buffers_equal(packet.data, buffer))
        @tu.test_complete
      end
    end
    @peer1.send('127.0.0.1', 1234, buffer) do |err, result|
      @tu.check_thread
      @tu.azzert result == @peer1
      @tu.azzert err == nil
    end
  end
end

def test_send_after_close_fails
  @peer1 = DatagramSocket.new
  @peer2 = DatagramSocket.new

  @peer1.close do
    @tu.check_thread
    @peer1.send_str('127.0.0.1', 1234, 'test') do |err, result|
      @tu.check_thread
      @tu.azzert result == nil
      @tu.azzert err != nil

      @peer2.close do
        @peer2.send_str('127.0.0.1', 1234, 'test') do |err, result|
          @tu.check_thread
          @tu.azzert result == nil
          @tu.azzert err != nil
          @tu.test_complete
        end
      end
    end
  end
end

def test_broadcast
  @peer1 = DatagramSocket.new
  @peer2 = DatagramSocket.new
  @peer2.exception_handler do |err|
    @tu.azzert err != nil
    @tu.azzert false
  end
  @peer1.broadcast(true)
  @peer2.broadcast(true)

  @peer2.listen(1234) do |err, result|
    @tu.check_thread
    @tu.azzert err == nil
    @tu.azzert result == @peer2
    buffer = TestUtils::gen_buffer(128)

    @peer2.data_handler do |packet|
      @tu.check_thread
      @tu.azzert(TestUtils.buffers_equal(packet.data, buffer))

      @tu.test_complete
    end

    @peer1.send('255.255.255.255', 1234, buffer) do |err, result|
      @tu.check_thread
      @tu.azzert result == @peer1
      @tu.azzert err == nil
    end
  end
end


def test_configure
  @peer1 = DatagramSocket.new

  @tu.azzert(!@peer1.broadcast)
  @peer1.broadcast(true)
  @tu.azzert(@peer1.broadcast)

  @tu.azzert(@peer1.multicast_loopback_mode)
  @peer1.multicast_loopback_mode(false)
  @tu.azzert(@peer1.multicast_loopback_mode)

  @tu.azzert(@peer1.multicast_network_interface == nil)
  iface = java.net.NetworkInterface.getNetworkInterfaces().nextElement()
  @peer1.multicast_network_interface(iface.getName())
  @tu.azzert(@peer1.multicast_network_interface == iface.getName())

  @tu.azzert(@peer1.receive_buffer_size != 1024)
  @peer1.receive_buffer_size(1024)
  @tu.azzert(@peer1.receive_buffer_size == 1024)

  @tu.azzert(@peer1.send_buffer_size != 1024)
  @peer1.send_buffer_size(1024)
  @tu.azzert(@peer1.send_buffer_size == 1024)

  @tu.azzert(!@peer1.reuse_address)
  @peer1.reuse_address(true)
  @tu.azzert(@peer1.reuse_address)

  @tu.azzert(@peer1.multicast_time_to_live != 2)
  @peer1.multicast_time_to_live(2)
  @tu.azzert(@peer1.multicast_time_to_live == 2)

  @tu.test_complete
end


def test_multicast_join_leave
  buffer = TestUtils::gen_buffer(128)
  group_address = '230.0.0.1'

  @peer1 = DatagramSocket.new
  @peer2 = DatagramSocket.new(true)

  @peer2.data_handler do |packet|
    @tu.check_thread
    @tu.azzert(TestUtils.buffers_equal(packet.data, buffer))

    # leave group
    @peer2.unlisten_multicast_group(group_address) do |err, socket|
      @tu.check_thread
      @tu.azzert err == nil
      @tu.azzert @peer2 == socket

    end
  end


  @peer2.listen(1234, '127.0.0.1') do |err, peer|
    @tu.check_thread
    @tu.azzert err == nil
    @tu.azzert peer == @peer2

    @peer2.listen_multicast_group(group_address) do |err, socket|
      @tu.check_thread
      @tu.azzert err == nil
      @tu.azzert socket == @peer2
      @peer1.send(group_address, 1234, buffer) do |err, socket|
        @tu.check_thread
        @tu.azzert err == nil
        @tu.azzert socket == @peer1
        received = false

        @peer2.data_handler do |ignore|
          received = true
        end

        @peer1.send(group_address, 1234, buffer) do |err, socket|
          @tu.check_thread
          @tu.azzert err == nil
          @tu.azzert socket == @peer1

          # schedule a timer which will check in 1 second if we received a message after the group
          # was left before
          Vertx.set_timer(1000) do |id|
            @tu.azzert !received
            @tu.test_complete
          end
        end

      end
    end
  end
end

@tu.register_all(self)
@tu.app_ready

def vertx_stop
  if defined? @peer1
    @peer1.close
  end
  if defined? @peer2
    @peer2.close
  end
  @tu.unregister_all
  @tu.app_stopped
end