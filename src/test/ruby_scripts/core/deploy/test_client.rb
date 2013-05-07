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

def test_deploy

  EventBus.register_handler("test-handler") do |message|
    @tu.azzert "started" == message.body
    @tu.test_complete
  end

  conf = {'foo' => 'bar'}

  Vertx.deploy_verticle("core/deploy/child.rb", conf)
end

def test_deploy2

  Vertx.deploy_verticle("core/deploy/child2.rb") do |err, id|
    @tu.azzert(err == nil)
    @tu.azzert(id != nil)
    @tu.test_complete
  end
end

def test_deploy_fail

  Vertx.deploy_verticle("core/deploy/notexists.rb") do |err, id|
    @tu.azzert(err != nil)
    @tu.azzert(id == nil)
    @tu.test_complete
  end
end

def test_undeploy

  EventBus.register_handler("test-handler") do |message|
    @tu.test_complete if "stopped" == message.body
  end

  conf = {'foo' => 'bar'}
  Vertx.deploy_verticle("core/deploy/child.rb", conf) do |err, id|
    @tu.azzert(err == nil)
    @tu.azzert(id != nil)
    Vertx.undeploy_verticle(id)
  end

end

def test_undeploy2

  conf = {'foo' => 'bar'}
  Vertx.deploy_verticle("core/deploy/child2.rb") do |err, id|
    @tu.azzert(err == nil)
    @tu.azzert(id != nil)
    Vertx.undeploy_verticle(id) do |err|
      @tu.azzert(err == nil)
      @tu.test_complete
    end
  end

end

def test_undeploy_fail

  Vertx.undeploy_verticle('qwdqwd') do |err|
    @tu.azzert(err != nil)
    @tu.test_complete
  end

end

def vertx_stop
  @tu.unregister_all
  @tu.app_stopped
end

@tu.register_all(self)
@tu.app_ready
