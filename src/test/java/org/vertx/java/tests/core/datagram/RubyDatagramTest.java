/*
 * Copyright 2013 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.vertx.java.tests.core.datagram;

import org.vertx.java.testframework.TestBase;


public class RubyDatagramTest extends TestBase {

  @Override
  protected void setUp() throws Exception {
    super.setUp();
    startApp("core/datagram/test_client.rb");
  }

  @Override
  protected void tearDown() throws Exception {
    super.tearDown();
  }

  public void test_send_receive() {
    startTest(getMethodName());
  }

  public void test_listen_host_port() {
    startTest(getMethodName());
  }

  public void test_listen_port() {
    startTest(getMethodName());
  }

  public void test_listen_same_port_multiple_times() {
    startTest(getMethodName());
  }

  public void test_echo() {
    startTest(getMethodName());
  }

  public void test_send_after_close_fails() {
    startTest(getMethodName());
  }

  public void test_broadcast() {
    startTest(getMethodName());
  }

  /*public void test_configure() {
    startTest(getMethodName());
  }*/

  public void test_multicast_join_leave() {
    startTest(getMethodName());
  }
}
