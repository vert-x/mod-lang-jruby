VertxAssert = Java::IoVertxTesttools::VertxAssert

def init_tests(top)
  VertxAssert.initialize(org.vertx.java.platform.impl.JRubyVerticleFactory.vertx)
  method_name = Vertx.config['methodName']
  self.send(method_name)
end
