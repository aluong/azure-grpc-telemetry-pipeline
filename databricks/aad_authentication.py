import logging
import random
import socket
import string
import subprocess
import webbrowser

from six.moves import BaseHTTPServer

logger = logging.getLogger('aad_auth_code')


class ClientRedirectServer(BaseHTTPServer.HTTPServer):
    query_params = {}


class ClientRedirectHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            from urllib.parse import parse_qs
        except ImportError:
            from urlparse import parse_qs

        if self.path.endswith('/favicon.ico'):  # deal with legacy IE
            self.send_response(204)
            return

        query = self.path.split('?', 1)[-1]
        query = parse_qs(query, keep_blank_values=True)
        self.server.query_params = query

        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()


def _get_platform_info():
    import platform
    uname = platform.uname()
    # python 2, `platform.uname()` returns: tuple(system, node, release, version, machine, processor)
    platform_name = getattr(uname, 'system', None) or uname[0]
    release = getattr(uname, 'release', None) or uname[2]
    return platform_name.lower(), release.lower()


def _is_wsl(platform_name, release):
    return platform_name == 'linux' and release.split('-')[-1] == 'microsoft'


def _open_page_in_browser(url):
    platform_name, release = _get_platform_info()

    if _is_wsl(platform_name, release):  # windows 10 linux subsystem
        try:
            return subprocess.call(['cmd.exe', '/c', "start {}".format(url.replace('&', '^&'))])
        except OSError:  # WSL might be too old  # FileNotFoundError introduced in Python 3
            pass
    elif platform_name == 'darwin':
        # handle 2 things:
        # a. On OSX sierra, 'python -m webbrowser -t <url>' emits out "execution error: <url> doesn't
        #    understand the "open location" message"
        # b. Python 2.x can't sniff out the default browser
        return subprocess.Popen(['open', url])
    try:
        return webbrowser.open(url, new=2)  # 2 means: open in a new tab, if possible
    except TypeError:  # See https://bugs.python.org/msg322439
        return webbrowser.open(url, new=2)


def _get_authorization_code_worker(authority_url, client_id, resource_id, results):
    reply_url = None
    for port in range(8400, 9000):
        try:
            web_server = ClientRedirectServer(('localhost', port), ClientRedirectHandler)
            reply_url = "http://localhost:{}".format(port)
            break
        except socket.error as ex:
            logger.warning("Port '%s' is taken with error '%s'. Trying with the next one", port, ex)

    if reply_url is None:
        logger.warning("Error: can't reserve a port for authentication reply url")
        return

    try:
        request_state = ''.join(
            random.SystemRandom().choice(string.ascii_lowercase + string.digits) for _ in range(20))
    except NotImplementedError:
        request_state = 'code'

    # launch browser:
    url = ('{0}/oauth2/authorize?response_type=code&client_id={1}'
           '&redirect_uri={2}&state={3}&resource={4}&prompt=select_account')
    url = url.format(authority_url, client_id, reply_url, request_state, resource_id)
    succ = _open_page_in_browser(url)
    if succ is False:
        web_server.server_close()
        results['no_browser'] = True
        return

    # wait for callback from browser.
    while True:
        web_server.handle_request()
        if 'error' in web_server.query_params or 'code' in web_server.query_params:
            break

    if 'error' in web_server.query_params:
        logger.warning('Authentication Error: "%s". Description: "%s" ', web_server.query_params['error'],
                       web_server.query_params.get('error_description'))
        return

    if 'code' in web_server.query_params:
        code = web_server.query_params['code']
    else:
        logger.warning('Authentication Error: Authorization code was not captured in query strings "%s"',
                       web_server.query_params)
        return

    if 'state' in web_server.query_params:
        response_state = web_server.query_params['state'][0]
        if response_state != request_state:
            raise RuntimeError("mismatched OAuth state")
    else:
        raise RuntimeError("missing OAuth state")

    results['code'] = code[0]
    results['reply_url'] = reply_url


def get_authorization_code(config, resource_id):
    import threading
    import time
    results = {}
    authority_url = "https://login.microsoftonline.com/" + config.tenant_id
    t = threading.Thread(target=_get_authorization_code_worker,
                         args=(authority_url, config.client_id, resource_id, results))
    t.daemon = True
    t.start()
    while True:
        time.sleep(2)  # so that ctrl+c can stop the command
        if not t.is_alive():
            break  # done
    if results.get('no_browser'):
        raise RuntimeError()
    return results
