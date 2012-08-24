"""
Simple server relays HTTP request to another URL.
Requires open port.

Example:

$ python relay_http.py &
$ python curl.py http://localhost:8080/?http://google.com/finance/historical?q=NASDAQ:GOOG&output=csv
Relay http://google.com/finance/?q=NASDAQ:GOOG
Date,High,Close,...
...

"""

# http://www.doughellmann.com/PyMOTW/BaseHTTPServer/ {{{

import os
import StringIO
from BaseHTTPServer import BaseHTTPRequestHandler
import urlparse
import urllib2

class GetHandler(BaseHTTPRequestHandler):
    
    def do_GET(self):
        parsed_path = urlparse.urlparse(self.path)
        message_parts = [
                'CLIENT VALUES:',
                'client_address=%s (%s)' % (self.client_address,
                                            self.address_string()),
                'command=%s' % self.command,
                'path=%s' % self.path,
                'real path=%s' % parsed_path.path,
                'query=%s' % parsed_path.query,
                'request_version=%s' % self.request_version,
                '',
                'SERVER VALUES:',
                'server_version=%s' % self.server_version,
                'sys_version=%s' % self.sys_version,
                'protocol_version=%s' % self.protocol_version,
                '',
                'HEADERS RECEIVED:',
                ]
        for name, value in sorted(self.headers.items()):
            message_parts.append('%s=%s' % (name, value.rstrip()))
        message_parts.append('')
        message = '\r\n'.join(message_parts)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(message)
        return

def serve(handler_class):
    from BaseHTTPServer import HTTPServer
    server = HTTPServer(('', 8080), handler_class)
    print 'Starting server, use <Ctrl-C> to stop'
    server.serve_forever()

# }}}

    try:
        request = urllib2.urlopen(url)
        return request.read()
    except urllib2.URLError, e:
        print "Request failed", e
        return None


def relay(self, url):
    try:
        request = urllib2.urlopen(url)
        message = request.read()
        self.send_response(200)
    except urllib2.URLError, e:
        message = "Request failed", e
        self.send_response(500)
        print message
    return message


def read_path(self, path):
    """Read path and return message"""
    relative_path = path.strip('/')
    if os.path.exists(relative_path):
        try:
            message = open(relative_path).read()
            self.send_response(200)
        except Exception, e:
            message = "Request failed", e
            self.send_response(501)
            print message
    else:
        message = 'File not found'
        self.send_response(404)
    return message


def relay_query_or_read_path(self):
    """
    Relay query or return path.
    """
    parsed_path = urlparse.urlparse(self.path)
    if hasattr(parsed_path, 'query'):
        # Python 2.5
        query = parsed_path.query
        path = parsed_path.path
    else:
        # Python 2.4
        scheme, netloc, path, parameters, query, fragment = parsed_path
    if query:
        message = relay(self, query)
    else:
        message = read_path(self, path)
    self.end_headers()
    self.wfile.write(message)


class RelayHandler(BaseHTTPRequestHandler):
    
    def do_GET(self):
        return relay_query_or_read_path(self)


class MockHandler(object):

    def __init__(self):
        self.path = ''
        self._mock_status = None
        self.wfile = StringIO.StringIO()

    def end_headers(self):
        pass

    def send_response(self, status):
        self._mock_status = status


def test_path():
    """
    On path, Ethan expects to serve contents of that file,
    For example, crossdomain.xml is served.
    """
    crossdomain_path = '/crossdomain.xml'

    handler = MockHandler()
    message = read_path(handler, crossdomain_path)
    assert '<cross-domain-policy>' in message, '%r' % message

    handler = MockHandler()
    handler.path = crossdomain_path
    relay_query_or_read_path(handler)
    handler.wfile.seek(0)
    message = handler.wfile.read()
    assert '<cross-domain-policy>' in message, '%r' % message


def test_relay():
    """
    On query Ethan expects to relay URL.
    For example, get historical stock quotes of Google from Google finance.
    Ask Google to format text as comma-separated values (CSV).
    Ethan expects first line to be comma-separated headers:  Date,Open,...
    """
    url = 'http://google.com/finance/historical?q=NASDAQ:GOOG&output=csv'

    handler = MockHandler()
    message = relay(handler, url)
    assert 'Date,Open,High,Low,Close,Volume' in message.splitlines()[0], \
        message.splitlines()[0]
    assert 200 == handler._mock_status, handler._mock_status

    handler = MockHandler()
    handler.path = '/?' + url
    relay_query_or_read_path(handler)
    handler.wfile.seek(0)
    message = handler.wfile.read()
    assert 'Date,Open,High,Low,Close,Volume' in message.splitlines()[0], \
        message.splitlines()[0]
    assert 200 == handler._mock_status, handler._mock_status


if __name__ == '__main__':
    import sys
    if '--test' == sys.argv[-1]:
        test_path()
        test_relay()
    else:
        # serve(GetHandler)
        serve(RelayHandler)

