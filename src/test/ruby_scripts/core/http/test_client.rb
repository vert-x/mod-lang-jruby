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
@tu.check_thread
@server = HttpServer.new
@client = HttpClient.new
@client.port = 8080
@logger = Vertx.logger

# This is just a basic test. Most testing occurs in the Java tests

def test_get
  http_method(false, "GET", false)
end

def test_get_ssl
  http_method(true, "GET", false)
end

def test_put
  http_method(false, "PUT", false)
end

def test_put_ssl
  http_method(true, "PUT", false)
end

def test_post
  http_method(false, "POST", false)
end

def test_post_ssl
  http_method(true, "POST", false)
end

def test_head
  http_method(false, "HEAD", false)
end

def test_head_ssl
  http_method(true, "HEAD", false)
end

def test_options
  http_method(false, "OPTIONS", false)
end

def test_options_ssl
  http_method(true, "OPTIONS", false)
end

def test_delete
  http_method(false, "DELETE", false)
end

def test_delete_ssl
  http_method(true, "DELETE", false)
end

def test_trace
  http_method(false, "TRACE", false)
end

def test_trace_ssl
  http_method(true, "TRACE", false)
end

def test_connect
  http_method(false, "CONNECT", false)
end

def test_connect_ssl
  http_method(true, "CONNECT", false)
end

def test_patch
  http_method(false, "PATCH", false)
end

def test_patch_ssl
  http_method(true, "PATCH", false)
end


def test_get_chunked
  http_method(false, "GET", true)
end

def test_get_ssl_chunked
  http_method(true, "GET", true)
end

def test_put_chunked
  http_method(false, "PUT", true)
end

def test_put_ssl_chunked
  http_method(true, "PUT", true)
end

def test_post_chunked
  http_method(false, "POST", true)
end

def test_post_ssl_chunked
  http_method(true, "POST", true)
end

def test_head_chunked
  http_method(false, "HEAD", true)
end

def test_head_ssl_chunked
  http_method(true, "HEAD", true)
end

def test_options_chunked
  http_method(false, "OPTIONS", true)
end

def test_options_ssl_chunked
  http_method(true, "OPTIONS", true)
end

def test_delete_chunked
  http_method(false, "DELETE", true)
end

def test_delete_ssl_chunked
  http_method(true, "DELETE", true)
end

def test_trace_chunked
  http_method(false, "TRACE", true)
end

def test_trace_ssl_chunked
  http_method(true, "TRACE", true)
end

def test_connect_chunked
  http_method(false, "CONNECT", true)
end

def test_connect_ssl_chunked
  http_method(true, "CONNECT", true)
end

def test_patch_chunked
  http_method(false, "PATCH", true)
end

def test_patch_ssl_chunked
  http_method(true, "PATCH", true)
end

def test_form_file_upload
  content = "Vert.x rocks!"
  @server.request_handler do |req|
    if req.uri == '/form'
      req.expect_multipart = true
      req.response.chunked = true
      req.upload_handler do |upload|
        @tu.azzert(upload.filename == 'tmp-0.txt')
        @tu.azzert(upload.content_type == 'image/gif')
        upload.data_handler do |buffer|
          @tu.azzert(content == buffer.to_s())
        end
      end
      req.end_handler do
        attrs = req.form_attributes
        @tu.azzert(attrs.empty?)
        req.response.end()
      end
    end
  end
  @server.listen(8080) do |err, server|
    @tu.azzert err == nil
    @client.port = 8080
    req = @client.post("/form") do |resp|
      # assert the response
      @tu.azzert(200 == resp.status_code)
      resp.body_handler do |body|
        @tu.azzert(0 == body.length)
      end
      @tu.test_complete()
    end
    boundary = "dLV9Wyq26L_-JQxk6ferf-RT153LhOO"
    buffer = Buffer.create()
    b =
        "--" + boundary + "\r\n" +
            "Content-Disposition: form-data; name=\"file\"; filename=\"tmp-0.txt\"\r\n" +
            "Content-Type: image/gif\r\n" +
            "\r\n" +
            content + "\r\n" +
            "--" + boundary + "--\r\n"

    buffer.append_str(b)
    req.put_header('content-length', buffer.length)
    req.put_header('content-type', 'multipart/form-data; boundary=' + boundary)
    req.write(buffer).end()
  end
end

def test_form_upload_attributes
  @server.request_handler do |req|
    if req.uri == '/form'
      req.response.chunked = true
      req.expect_multipart = true
      req.upload_handler do |event|
        event.data_handler do |buffer|
          @tu.azzert(false)
        end
      end
      req.end_handler do
        attrs = req.form_attributes
        @tu.azzert(attrs['framework'] == 'vertx')
        @tu.azzert(attrs['runson'] == 'jvm')
        req.response.end()
      end
    end
  end
  @server.listen(8080) do |err, server|
    @tu.azzert err == nil
    @client.port = 8080
    req = @client.post("/form") do |resp|
      # assert the response
      @tu.azzert(200 == resp.status_code)
      resp.body_handler do |body|
        @tu.azzert(0 == body.length)
      end
      @tu.test_complete()
    end
    buffer = Buffer.create()
    buffer.append_str('framework=vertx&runson=jvm')
    req.put_header('content-length', buffer.length)
    req.put_header('content-type', 'application/x-www-form-urlencoded')
    req.write(buffer).end()
  end
end


def test_http_compression
  @server.compression = true
  @client.compression = true

  @server.request_handler do |req|
    if req.uri == '/compression'
      req.response = 'HTTP Compression!'
    end
  end

  @server.listen(8080) do |err, server|
    @tu.azzert err == nil
    @tu.azzert @server.compression? == true

    @client.compression = true
    @client.port = 8080
    req = @client.get('/compression') do |resp|
      resp.body_handler do |body|
        @tu.azzert body.to_s == 'HTTP Compression!'
      end
    end
  end
  @tu.test_complete()

end


def http_method(ssl, method, chunked)

  if ssl
    @server.ssl = true
    @server.key_store_path = './src/test/keystores/server-keystore.jks'
    @server.key_store_password = 'wibble'
    @server.trust_store_path = './src/test/keystores/server-truststore.jks'
    @server.trust_store_password = 'wibble'
    @server.client_auth_required = true
  end

  path = "/someurl/blah.html"
  query = "param1=vparam1&param2=vparam2"
  uri = "http://localhost:8080" + path + "?" + query;

  @server.request_handler do |req|
    @tu.check_thread
    @tu.azzert(req.version == 'HTTP_1_1')
    @tu.azzert(req.uri == uri)
    @tu.azzert(req.method == method)
    @tu.azzert(req.path == path)
    @tu.azzert(req.query == query)
    @tu.azzert(req.headers['header1'] == 'vheader1')
    @tu.azzert(req.headers['header2'] == 'vheader2')
    @tu.azzert(req.params['param1'] == 'vparam1')
    @tu.azzert(req.params['param2'] == 'vparam2')

    headers = req.headers
    @tu.azzert(headers.contains('header1'))
    @tu.azzert(headers.contains('header2'))
    @tu.azzert(headers.contains('header3'))
    @tu.azzert(!headers.empty?)

    headers.remove('header3')
    @tu.azzert(!headers.contains('header3'))

    req.response.put_header('rheader1', 'vrheader1')
    req.response.put_header('rheader2', 'vrheader2')
    body = Buffer.create()
    req.data_handler do |data|
      @tu.check_thread
      body.append_buffer(data)
    end

    if method != 'HEAD' && method != 'CONNECT'
      req.response.chunked = chunked
    end

    req.end_handler do
      @tu.check_thread
      if method != 'HEAD' && method != 'CONNECT'
        req.response.put_header('Content-Length', body.length()) if !chunked
        req.response.write(body)
        if chunked
          req.response.put_trailer('trailer1', 'vtrailer1')
          req.response.put_trailer('trailer2', 'vtrailer2')
        end
      end
      req.response.end
    end
  end
  @server.listen(8080) do |err, server|
    @tu.azzert err == nil
    @tu.azzert @server == server
    if ssl
      @client.ssl = true
      @client.key_store_path = './src/test/keystores/client-keystore.jks'
      @client.key_store_password = 'wibble'
      @client.trust_store_path = './src/test/keystores/client-truststore.jks'
      @client.trust_store_password = 'wibble'
    end

    sent_buff = TestUtils.gen_buffer(1000)

    request = @client.request(method, uri) do |resp|
      @tu.check_thread
      @tu.azzert(200 == resp.status_code)

      @tu.azzert('vrheader1' == resp.headers['rheader1'])
      @tu.azzert('vrheader2' == resp.headers['rheader2'])
      body = Buffer.create()
      resp.data_handler do |data|
        @tu.check_thread
        body.append_buffer(data)
      end

      resp.end_handler do
        @tu.check_thread
        if method != 'HEAD' && method != 'CONNECT'
          @tu.azzert(TestUtils.buffers_equal(sent_buff, body))
          if chunked
            @tu.azzert('vtrailer1' == resp.trailers['trailer1'])
            @tu.azzert('vtrailer2' == resp.trailers['trailer2'])
          end
        end
        resp.headers.clear
        @tu.azzert(resp.headers.empty?)
        @tu.test_complete
      end
    end

    request.chunked = chunked;
    request.put_header('header1', 'vheader1')
    request.put_header('header2', 'vheader2')
    request.put_header('Content-Length', sent_buff.length()) if !chunked
    request.headers.add('header3', 'vheader3_1').add('header3', 'vheader3')

    size = request.headers.size()
    names = request.headers.names()
    @tu.azzert(size == names.count())

    request.headers.each do |k, v|
      @tu.azzert(request.headers.get_all(k).include?(v))
    end

    request.write(sent_buff)

    request.end
  end
end

def vertx_stop
  @tu.check_thread
  @tu.unregister_all
  @client.close
  @server.close do |err|
    @tu.azzert err == nil
    @tu.app_stopped
  end
end

@tu.register_all(self)
@tu.app_ready

