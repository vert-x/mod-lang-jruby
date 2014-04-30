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

module Vertx

  # Mixin module that provides all the common Network params that can be set.
  #
  # @author {http://tfox.org Tim Fox}
  module NetworkSupport

    # Set the send buffer size.
    # @param [FixNum] val. The size in bytes.
    # @return [] A reference to self so invocations can be chained
    def send_buffer_size=(val)
      @j_del.setSendBufferSize(val)
      self
    end

    # Get send buffer size for fluent API
    def send_buffer_size
      @j_del.getSendBufferSize
    end

    # Set the receive buffer size.
    # @param [FixNum] val. The size in bytes.
    # @return [] A reference to self so invocations can be chained
    def receive_buffer_size=(val)
      @j_del.setReceiveBufferSize(val)
      self
    end

    #
    # Gets the receive buffer size.
    #
    def receive_buffer_size
        @j_del.getReceiveBufferSize
    end


    # Set the TCP reuse address setting.
    # @param [Boolean] val. If true, then TCP reuse address will be enabled.
    # @return [] A reference to self so invocations can be chained
    def reuse_address=(val)
      @j_del.setReuseAddress(val)
      self
    end

    # Get TCP reuse address for fluent API
    def reuse_address?
      @j_del.isReuseAddress
    end

    # Set the traffic class setting.
    # @param [FixNum] val. The TCP traffic class setting.
    # @return [] A reference to self so invocations can be chained
    def traffic_class=(val)
      @j_del.setTrafficClass(val)
      self
    end

    # Get traffic class for fluent API
    def traffic_class
        @j_del.getTrafficClass
    end
  end
end