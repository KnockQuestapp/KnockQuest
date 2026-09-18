"""Serve a local Flutter web build and relay test events to Zapier.

This is for local testing only. Bind to loopback; deploy a server-side relay for
hosted web use. The hook URL is never logged.
"""

import argparse
import json
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen


class Handler(SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/crm-hook":
            self.send_error(404)
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length <= 0 or length > 65536:
                raise ValueError("Invalid request size")
            body = json.loads(self.rfile.read(length))
            hook = body["webhookUrl"]
            payload = body["payload"]
            parsed = urlparse(hook)
            if (
                parsed.scheme != "https"
                or parsed.hostname != "hooks.zapier.com"
                or not parsed.path.startswith("/hooks/catch/")
                or not isinstance(payload, dict)
            ):
                raise ValueError("Only Zapier Catch Hook URLs are accepted")
            request = Request(
                hook,
                data=json.dumps(payload).encode("utf-8"),
                headers={
                    "Content-Type": "application/json",
                    "X-KnockQuest-Source": "knockquest-app",
                },
                method="POST",
            )
            with urlopen(request, timeout=12) as response:
                status = response.status
        except (ValueError, KeyError, TypeError):
            status = 400
        except HTTPError as error:
            status = error.code
        except URLError:
            status = 502
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": status}).encode("utf-8"))

    def log_message(self, format, *args):
        # Avoid logging the hook URL or contact payload.
        if self.path != "/crm-hook":
            super().log_message(format, *args)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8769)
    parser.add_argument("--directory", default="build/web")
    args = parser.parse_args()
    directory = Path(args.directory).resolve()
    handler = lambda *items, **kwargs: Handler(
        *items, directory=str(directory), **kwargs
    )
    server = ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    print(f"Serving {directory} on http://127.0.0.1:{args.port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
