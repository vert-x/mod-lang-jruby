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

package org.vertx.java.tests.core.dns;

import org.vertx.java.testframework.TestBase;


public class RubyDnsTest extends TestBase {

  @Override
  protected void setUp() throws Exception {
    super.setUp();
    startApp("core/dns/test_client.rb");
  }

  @Override
  protected void tearDown() throws Exception {
    super.tearDown();
  }

  public void test_resolve_a() {
    startTest(getMethodName());
  }

  public void test_resolve_aaaa() {
    startTest(getMethodName());
  }

  public void test_resolve_mx() {
    startTest(getMethodName());
  }

  public void test_resolve_txt() {
    startTest(getMethodName());
  }

  public void test_resolve_ns() {
    startTest(getMethodName());
  }

  public void test_resolve_cname() {
    startTest(getMethodName());
  }

  public void test_resolve_ptr() {
    startTest(getMethodName());
  }

  public void test_resolve_srv() {
    startTest(getMethodName());
  }

  public void test_lookup_6() {
    startTest(getMethodName());
  }

  public void test_lookup_4() {
    startTest(getMethodName());
  }

  public void test_lookup() {
    startTest(getMethodName());
  }

  public void test_lookup_non_existing() {
    startTest(getMethodName());
  }

  public void test_reverse_lookup_ipv4() {
    startTest(getMethodName());
  }

  public void test_reverse_lookup_ipv6() {
    startTest(getMethodName());
  }
}
