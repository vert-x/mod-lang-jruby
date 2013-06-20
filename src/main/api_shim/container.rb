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

require 'core/wrapped_handler'

module Vertx

  # Deploy a verticle. The actual deploy happens asynchronously
  # @param main [String] The main of the verticle to deploy
  # @param config [Hash] JSON configuration for the verticle
  # @param instances [FixNum] Number of instances to deploy
  # @param block [Block] Block will be executed when deploy has completed - the first parameter passed to
  # the block will be an exception or nil if no failure occurred, the second parameter will be the deployment id
  def Vertx.deploy_verticle(main, config = nil, instances = 1, &block)
    if config
      json_str = JSON.generate(config)
      config = org.vertx.java.core.json.JsonObject.new(json_str)
    end
    if block
      block = ARWrappedHandler.new(block)
    end
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.deployVerticle(main, config, instances, block)
  end

  # Deploy a worker verticle. The actual deploy happens asynchronously
  # @param main [String] The main of the verticle to deploy
  # @param config [Hash] JSON configuration for the verticle
  # @param instances [FixNum] Number of instances to deploy
  # @param block [Block] Block will be executed when deploy has completed - the first parameter passed to
  # the block will be an exception or nil if no failure occurred, the second parameter will be the deployment id
  def Vertx.deploy_worker_verticle(main, config = nil, instances = 1, multi_threaded = false, &block)
    if config
      json_str = JSON.generate(config)
      config = org.vertx.java.core.json.JsonObject.new(json_str)
    end
    if block
      block = ARWrappedHandler.new(block)
    end
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.deployWorkerVerticle(main, config, instances, multi_threaded, block)
  end

  # Deploy a module. The actual deploy happens asynchronously
  # @param module_name [String] The name of the module to deploy
  # @param config [Hash] JSON configuration for the module
  # @param instances [FixNum] Number of instances to deploy
  # @param block [Block] Block will be executed when deploy has completed - the first parameter passed to
  # the block will be an exception or nil if no failure occurred, the second parameter will be the deployment id
  def Vertx.deploy_module(module_name, config = nil, instances = 1, &block)
    if config
      json_str = JSON.generate(config)
      config = org.vertx.java.core.json.JsonObject.new(json_str)
    end
    if block
      block = ARWrappedHandler.new(block)
    end
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.deployModule(module_name, config, instances, block)
  end

  # Undeploy a verticle
  # @param id [String] The deployment id  - the undeploy happens asynchronously
  # @param block [Block] Block will be executed when undeploy has completed, an exception will be passed to the block
  # as the first parameter if undeploy failed
  def Vertx.undeploy_verticle(id, &block)
    if block
      block = ARWrappedHandler.new(block)
    end
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.undeployVerticle(id, block)
  end

  # Undeploy a module
  # @param id [String] The deployment id
  # @param block [Block] Block will be executed when undeploy has completed, an exception will be passed to the block
  # as the first parameter if undeploy failed
  def Vertx.undeploy_module(id, &block)
    if block
      block = ARWrappedHandler.new(block)
    end
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.undeployModule(id, block)
  end

  # Cause the container to exit
  def Vertx.exit
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.exit
  end

  # Get config for the verticle
  # @return [Hash] The JSON config for the verticle
  def Vertx.config
    if !defined? @@j_conf
      @@j_conf = org.vertx.java.platform.impl.JRubyVerticleFactory.container.config
      @@j_conf = JSON.parse(@@j_conf.encode) if @@j_conf
    end
    @@j_conf
  end

  # @return [Hash] Get the environment for the verticle
  def Vertx.env
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.env
  end

  # @return [Logger] Get the logger for the verticle
  def Vertx.logger
    org.vertx.java.platform.impl.JRubyVerticleFactory.container.logger
  end

end
