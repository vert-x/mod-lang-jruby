/*
 * Copyright 2011-2012 the original author or authors.
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

package org.vertx.java.tests.core.isolation;

import org.junit.Test;
import org.vertx.java.testframework.TestBase;

/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
public class RubyIsolationTest extends TestBase {

  @Override
  protected void setUp() throws Exception {
    super.setUp();
  }

  @Override
  protected void tearDown() throws Exception {
    super.tearDown();
  }

  @Test
  public void test_isolated_global1() throws Exception {
    startApp("core/isolation/test_client1.rb");
    startApp("core/isolation/test_client2.rb");
    startTest("test_isolated_global_init1_1");
    startTest("test_isolated_global_init1_2");
    startTest("test_isolated_global1");
  }

  @Test
  public void test_isolated_global2() throws Exception {
    startApp("core/isolation/test_client1.rb");
    startTest("test_isolated_global_init2_1");
    startApp("core/isolation/test_client1.rb");
    startTest("test_isolated_global_init2_2");
    startTest("test_isolated_global2");
  }
}
