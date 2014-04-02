VertxAssert = Java::OrgVertxTesttools::VertxAssert

VertxAssert.initialize(org.vertx.java.platform.impl.JRubyVerticleFactory.vertx)

def start_tests(top)
  method_name = Vertx.config['methodName']
  self.send(method_name)
end
