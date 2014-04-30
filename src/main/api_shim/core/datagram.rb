# Copyright 2013 the original author or authors.
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

require 'core/buffer'
require 'core/wrapped_handler'
require 'core/network_support'
require 'core/streams'
require 'socket'

module Vertx


  #
  # A Datagram socket which can be used to send data to remote Datagram servers and receive [DatagramPacket]s .
  #
  # Usually you use a Datragram Client to send UDP over the wire. UDP is connection-less which means you are not connected
  # to the remote peer in a persistent way. Because of this you have to supply the address and port of the remote peer
  # when sending data.
  #
  # You can send data to ipv4 or ipv6 addresses, which also include multicast addresses.
  #
  # @author Norman Maurer
  class DatagramSocket
    include ReadSupport, DrainSupport, NetworkSupport

    def initialize(ipv4=nil)
      if ipv4 == nil
        family = nil
      elsif ipv4
        family = org.vertx.java.core.datagram.InternetProtocolFamily::IPv4
      else
        family = org.vertx.java.core.datagram.InternetProtocolFamily::IPv6
      end
      @j_del = org.vertx.java.platform.impl.JRubyVerticleFactory.vertx.createDatagramSocket(family)
      @local_address = nil
    end

    # Write the given {@link org.vertx.java.core.buffer.Buffer} to the {@link java.net.InetSocketAddress}. The {@link org.vertx.java.core.Handler} will be notified once the
    # write completes.
    #
    # @param [String] host              the host address of the remote peer
    # @param [FixNum] port              the host port of the remote peer
    # @param [Buffer] packet            the buffer to write
    # @param [Block] hndlr              the handler to notify once the write completes.
    # @return [DatagramSocket] self     itself for method chaining
    def send(host, port, packet,  &hndlr)
      @j_del.send(packet._to_java_buffer, host, port, ARWrappedHandler.new(hndlr) { |j_del| self })
      self
    end

    #
    # Write the given {@link String} to the {@link InetSocketAddress} using UTF8 encoding. The {@link Handler} will be notified once the
    # write completes.
    #
    #
    # @param [String] host              the host address of the remote peer
    # @param [FixNum] port              the host port of the remote peer
    # @param [String] str               the data to send
    # @param [String] enc               the charset to use to encode the data
    # @param [Block] hndlr              the handler to notify once the write completes.
    # @return [DatagramSocket] self     itself for method chaining
    def send_str(host, port, str, enc = 'UTF-8',  &hndlr)
      @j_del.send(str, enc, host, port, ARWrappedHandler.new(hndlr) { |j_del| self })
      self
    end

    #
    # set the {@link java.net.StandardSocketOptions#SO_BROADCAST} option.
    #
    def broadcast=(val)
      @j_del.setBroadcast(val)
      self
    end

    #
    # set the {@link java.net.StandardSocketOptions#SO_BROADCAST} option.
    #
    def broadcast?
      @j_del.isBroadcast
    end

    #
    # Set the {@link java.net.StandardSocketOptions#IP_MULTICAST_LOOP} option.
    #
    def multicast_loopback_mode=(val)
      @j_del.setMulticastLoopbackMode(val)
       self
    end

    #
    # Set the {@link java.net.StandardSocketOptions#IP_MULTICAST_LOOP} option.
    #
    def multicast_loopback_mode?
      @j_del.isMulticastLoopbackMode
    end

    #
    # Set  the {@link java.net.StandardSocketOptions#IP_MULTICAST_TTL} option.
    #
    def multicast_time_to_live=(val)
      @j_del.setMulticastTimeToLive(val)
      self
    end

    #
    # Gets  the {@link java.net.StandardSocketOptions#IP_MULTICAST_TTL} option.
    #
    def multicast_time_to_live
      @j_del.getMulticastTimeToLive
    end

    #
    # Set the {@link java.net.StandardSocketOptions#IP_MULTICAST_IF} option.
    #
    def multicast_network_interface=(val)
      @j_del.setMulticastNetworkInterface(val)
      self
    end

    #
    # Gets the {@link java.net.StandardSocketOptions#IP_MULTICAST_IF} option.
    #
    def multicast_network_interface
      @j_del.getMulticastNetworkInterface
    end


    #
    # Close the socket asynchronous and notifies the handler once done.
    #
    # @param [Block] hndlr the handler to notify once the opeation completes.
    def close(&hndlr)
      if hndlr
        @j_del.close(ARWrappedHandler.new(hndlr))
      else
        @j_del.close
      end
    end

    #
    # Return the Addrinfo to which the local end of the socket is bound
    #
    # @return [Addrinfo] local_addr   the local address to which the socket is bound if it is bound at all.
    def local_address
      if !@local_address
        addr = j_del.localAddress
        if addr != null
          @local_address = Addrinfo.tcp(@local_address.getAddress().getHostAddress(), @@local_address.getPort())
        end
      end
      @local_address
    end

    #
    # Joins a multicast group and so start listen for packets send to it. The {@link Handler} is notified once the operation completes.
    #
    #
    # @param  [String]            multicast_address   the address of the multicast group to join
    # @param  [String]            source              the address of the source for which we will listen for mulicast packets
    # @param  [String]            network_interface   the network interface on which to listen for packets.
    # @param  [Block]             hndlr               the handler to notify once the opeation completes.
    # @return [DatagramSocket]    self                itself for method chaining
    def listen_multicast_group(multicast_address, source = nil, network_interface = nil,  &hndlr)
      if network_interface != nil && source != nil
        @j_del.listenMulticastGroup(multicast_address, network_interface, source, ARWrappedHandler.new(hndlr) { |j_del| self })
      else
        @j_del.listenMulticastGroup(multicast_address, ARWrappedHandler.new(hndlr) { |j_del| self })
      end
      self
    end

    #
    # Leaves a multicast group and so stop listen for packets send to it on the given network interface.
    # The {@link Handler} is notified once the operation completes.
    #
    #
    # @param  [String]            multicast_address   the address of the multicast group to leave
    # @param  [String]            source              the address of the source for which we will listen for mulicast packets
    # @param  [String]            network_interface   the network interface on which to listen for packets.
    # @param  [Block]             hndlr               the handler to notify once the opeation completes.
    # @return [DatagramSocket]    self                itself for method chaining
    def unlisten_multicast_group(multicast_address, source = nil, network_interface = nil, &hndlr)
      if network_interface != nil && source != nil
        @j_del.unlistenMulticastGroup(multicast_address, network_interface, source, ARWrappedHandler.new(hndlr) { |j_del| self })
      else
        @j_del.unlistenMulticastGroup(multicast_address, ARWrappedHandler.new(hndlr) { |j_del| self })
      end
      self
    end

    #
    # Block the given sourceToBlock address for the given multicastAddress on the given network interface and notifies
    # the {@link Handler} once the operation completes.
    #
    #
    # @param  [String]          multicast_address   the address for which you want to block the sourceToBlock
    # @param  [String]          source_to_block     the source address which should be blocked. You will not receive an multicast packets
    #                                               for it anymore.
    # @param  [String]          network_interface   the network interface on which the blocking should accour.
    # @param  [Block]           hndlr               the handler to notify once the opeation completes.
    # @return [DatagramSocket]  self                itself for method chaining
    #
    def block_multicast_group(multicast_address, source_to_block, network_interface = nil, &hndlr)
      if network_interface != nil
        @j_del.blockMulticastGroup(multicast_address, network_interface, source_to_block, ARWrappedHandler.new(hndlr) { |j_del| self })
      else
        @j_del.blockMulticastGroup(multicast_address, source_to_block, ARWrappedHandler.new(hndlr) { |j_del| self })
      end
      self
    end

    #
    # Listen for incoming [DatagramPacket]s on the given address and port.
    #
    #
    # @param  [FixNum]          port                the port on which to listen for incoming [DatagramPacket]s
    # @param  [String]          address             the address on which to listen for incoming [DatagramPacket]s
    # @param  [Block]           hndlr               the handler to notify once the opeation completes.
    # @return [DatagramSocket]  self                itself for method chaining
    #
    def listen(port, address = '0.0.0.0', &hndlr)
      @j_del.listen(address, port, ARWrappedHandler.new(hndlr) { |j_del| self })
      self
    end


    # Set a data handler. As data is read, the handler will be called with the data.
    #
    # @param [Block] hndlr. The data handler
    def data_handler(&hndlr)
      @j_del.dataHandler(Proc.new { |j_packet|
        hndlr.call(DatagramPacket.new(j_packet))
      })
      self
    end
  end


  # A received Datagram packet (UDP) which contains the data and information about the sender of the data itself.
  #
  # @author Norman Maurer
  class DatagramPacket
    def initialize(j_packet)
      @j_packet = j_packet
      @sender = nil
      @data = nil
    end

    # Return the address of the sender of this [DatagramPacket].
    #
    # @return [AddrInfo] addr   the address of the sender
    def sender
      if !@sender
        @sender = Addrinfo.tcp(@j_packet.sender().getAddress().getHostAddress(), @j_packet.sender().getPort())
      end
      @sender
    end

    # Return the data which was received
    #
    # @return [Buffer] data   the data which was received
    def data
      if !@data
        @data = Buffer.new(@j_packet.data())
      end
      @data
    end
  end
end