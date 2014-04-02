# Copyright 2011 the original author or authors.
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

require 'rubygems'
require 'json'

module Vertx

  # This class represents a distributed lightweight event bus which can encompass multiple vert.x instances.
  # It is very useful for otherwise isolated vert.x application instances to communicate with each other.
  #
  # The event bus implements both publish / subscribe network and point to point messaging.
  #
  # For publish / subscribe, messages can be published to an address using one of the publish methods. An
  # address is a simple String instance. Handlers are registered against an address. There can be multiple handlers
  # registered against each address, and a particular handler can be registered against multiple addresses.
  # The event bus will route a sent message to all handlers which are registered against that address.

  # For point to point messaging, messages can be sent to an address using the send method.
  # The messages will be delivered to a single handler, if one is registered on that address. If more than one
  # handler is registered on the same address, Vert.x will choose one and deliver the message to that. Vert.x will
  # aim to fairly distribute messages in a round-robin way, but does not guarantee strict round-robin under all
  # circumstances.
  #
  # All messages sent over the bus are transient. On event of failure of all or part of the event bus messages
  # may be lost. Applications should be coded to cope with lost messages, e.g. by resending them,
  # and making application services idempotent.
  #
  # The order of messages received by any specific handler from a specific sender should match the order of messages
  # sent from that sender.
  #
  # When sending a message, a reply handler can be provided. If so, it will be called when the reply from the receiver
  # has been received. Reply messages can also be replied to, etc, ad infinitum.
  #
  # Different event bus instances can be clustered together over a network, to give a single logical event bus.
  #
  # When receiving a message in a handler the received object is an instance of EventBus::Message - this contains
  # the actual message plus a reply method which can be used to reply to it.
  #
  # @author {http://tfox.org Tim Fox}
  class EventBus

    @@handler_map = {}

    @@j_eventbus = org.vertx.java.platform.impl.JRubyVerticleFactory.vertx.eventBus()

    # Send a message on the event bus
    # @param message [Hash] The message to send
    # @param reply_handler [Block] An optional reply handler.
    # @param [Integer] timeout if specified sends the message
    # It will be called when the reply from a receiver is received.
    def EventBus.send(address, message, timeout = nil, &reply_handler)

      if timeout.nil?
        EventBus.send_or_pub(true, address, message, reply_handler)
      else
        EventBus.send_or_pub(true, address, message, reply_handler, timeout)
      end

      self
    end

    # Sets a default timeout, in ms, for replies. If a messages is sent specify a reply handler
    # but without specifying a timeout, then the reply handler is timed out, i.e. it is automatically unregistered
    # if a message hasn't been received before timeout.
    # The default value for default send timeout is -1, which means "never timeout".
    # @param timeout
    def EventBus.default_reply_timeout=(timeout)
      @@j_eventbus.setDefaultReplyTimeout(timeout)
      self
    end

    # Gets the default reply timeout value
    def EventBus.default_reply_timeout
      @@j_eventbus.getDefaultReplyTimeout
    end

    # Publish a message on the event bus
    # @param message [Hash] The message to publish
    def EventBus.publish(address, message)
      EventBus.send_or_pub(false, address, message)
      self
    end

    # @private
    def EventBus.send_or_pub(send, address, message, reply_handler = nil, timeout = nil)
      raise "An address must be specified" if !address
      raise "A message must be specified" if message == nil
      message = convert_msg(message)
      if send
        if reply_handler != nil
          if timeout != nil
            @@j_eventbus.send_with_timeout address, message, timeout, AsyncInternalHandler.new(reply_handler)
          else
            @@j_eventbus.send(address, message, InternalHandler.new(reply_handler))
          end
        else
          @@j_eventbus.send(address, message)
        end
      else
        @@j_eventbus.publish(address, message)
      end
      self
    end

    # Register a handler.
    # @param address [String] The address to register for. Messages sent to that address will be
    # received by the handler. A single handler can be registered against many addresses.
    # @param local_only [Boolean] If true then handler won't be propagated across cluster
    # @param message_hndlr [Block] The handler
    # @return [FixNum] id of the handler which can be used in {EventBus.unregister_handler}
    def EventBus.register_handler(address, local_only = false, &message_hndlr)
      raise "An address must be specified" if !address
      raise "A message handler must be specified" if !message_hndlr
      internal = InternalHandler.new(message_hndlr)
      if local_only
        @@j_eventbus.registerLocalHandler(address, internal)
      else
        @@j_eventbus.registerHandler(address, internal)
      end
      id = java.util.UUID.randomUUID.toString
      @@handler_map[id] = [address, internal]
      id
    end

    # Registers a handler against a uniquely generated address, the address is returned as the id
    # received by the handler. A single handler can be registered against many addresses.
    # @param local_only [Boolean] If true then handler won't be propagated across cluster
    # @param message_hndlr [Block] The handler
    # @return [FixNum] id of the handler which can be used in {EventBus.unregister_handler}
    def EventBus.register_simple_handler(local_only = false, &message_hndlr)
      raise "A message handler must be specified" if !message_hndlr
      internal = InternalHandler.new(message_hndlr)
      id = java.util.UUID.randomUUID.toString
      if local_only
        @@j_eventbus.registerLocalHandler(id, internal)
      else
        @@j_eventbus.registerHandler(id, internal)
      end
      @@handler_map[id] = [id, internal]
      id
    end

    # Unregisters a handler
    # @param handler_id [FixNum] The id of the handler to unregister. Returned from {EventBus.register_handler}
    def EventBus.unregister_handler(handler_id)
      raise "A handler_id must be specified" if !handler_id
      tuple = @@handler_map.delete(handler_id)
      raise "Cannot find handler for id #{handler_id}" if !tuple
      @@j_eventbus.unregisterHandler(tuple.first, tuple.last)
      self
    end

    # @private
    def EventBus.convert_msg(message)
      if message.is_a? Hash
        message = org.vertx.java.core.json.JsonObject.new(JSON.generate(message))
      elsif message.is_a? Buffer
        message = message._to_java_buffer
      elsif message.is_a? Fixnum
        message = java.lang.Long.new(message)
      elsif message.is_a? Float
        message = java.lang.Double.new(message)
      end
      message
    end

  end

  # @private
  class InternalHandler
    include org.vertx.java.core.Handler

    def initialize(hndlr)
      @hndlr = hndlr
    end

    def handle(message)
      @hndlr.call(Message.new(message))
    end
  end


  # Represents a message received from the event bus
  # @author {http://tfox.org Tim Fox}
  class Message

    attr_reader :body

    # @private
    def initialize(message)

      @j_del = message
      if message.body.is_a? org.vertx.java.core.json.JsonObject
        @body = JSON.parse(message.body.encode)
      elsif message.body.is_a? org.vertx.java.core.buffer.Buffer
        @body = Buffer.new(message.body)
      else
        @body = message.body
      end
    end

    # Reply to this message. If the message was sent specifying a receipt handler, that handler will be
    # called when it has received a reply. If the message wasn't sent specifying a receipt handler
    # this method does nothing.
    # Replying to a message this way is equivalent to sending a message to an address which is the same as the message id
    # of the original message.
    # @param [Hash] Message send as reply
    def reply(reply, timeout = nil, &reply_handler)
      raise "A reply message must be specified" if reply == nil
      reply = EventBus.convert_msg(reply)
      if reply_handler != nil
        if timeout != nil
          @j_del.reply_with_timeout reply, timeout, AsyncInternalHandler.new(reply_handler)
        else
          @j_del.reply(reply, InternalHandler.new(reply_handler))
        end
      else
        @j_del.reply(reply)
      end
    end

    # Gets the address the message was sent to
    # @return [String] The recipient's address
    def address
      @j_del.address
    end

    def fail(failure_code, message)
      @j_del.fail failure_code, message
    end

  end


  # Error when the event bus use timeout and doesn't reply in time
  # Copied from mod-lang-jython
  class ReplyError

    TIMEOUT = 0
    NO_HANDLERS = 1
    RECIPIENT_FAILURE = 2

    def initialize(exception)
      @exception = exception
    end
    def type
      @exception.failureType().toInt()
    end
  end

  # Copied from mod-lang-jython
  class AsyncInternalHandler
    include org.vertx.java.core.AsyncResultHandler
    def initialize(hndlr)
      @hndlr = hndlr
    end
    def handle(result)
      if result.failed?
        @hndlr.call(ReplyError.new(result.cause))
      else
        @hndlr.call(Message.new(result.result))
      end
    end
  end
end
