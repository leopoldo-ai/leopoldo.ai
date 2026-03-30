#!/usr/bin/env python3
"""Background heartbeat — sends weekly phone-home to Leopoldo backend.

Called by session-start.sh in background (&). Non-blocking.
If heartbeat returns a renewed license, replaces license.dat silently.

Python 3 stdlib only.
"""
import json
import os
import sys
import time
from urllib.request import Request, urlopen
from urllib.error import URLError


def main():
    client_config_path = ".leopoldo/leopoldo-client.json"
    license_path = ".leopoldo/license.dat"
    last_hb_path = ".leopoldo/.last-heartbeat"

    if not os.path.exists(client_config_path):
        return

    with open(client_config_path) as f:
        config = json.load(f)

    api_key = config.get("api_key", "")
    api_url = config.get("api_url", "").rstrip("/")

    if not api_key or not api_url:
        return

    # Read current license info for renewal detection
    current_expires = None
    current_products = None
    if os.path.exists(license_path):
        try:
            import base64
            with open(license_path) as f:
                raw = base64.b64decode(f.read().strip())
            data = json.loads(raw)
            payload = data.get("payload", {})
            current_expires = payload.get("expires_at")
            products = payload.get("products", [])
            current_products = ",".join(products) if products else None
        except Exception:
            pass

    # Import fingerprint from verify-license
    try:
        from importlib.util import spec_from_file_location, module_from_spec
        spec = spec_from_file_location("verify_license", ".leopoldo/hooks/verify-license.py")
        vl = module_from_spec(spec)
        spec.loader.exec_module(vl)
        device_fingerprint = vl.get_fingerprint()
    except Exception:
        return

    # Send heartbeat
    body = json.dumps({
        "device_fingerprint": device_fingerprint,
        "version": config.get("version", "1.0.0"),
        "current_expires": current_expires,
        "current_products": current_products,
    }).encode()

    req = Request(
        f"{api_url}/api/licenses/heartbeat",
        data=body,
        headers={
            "Content-Type": "application/json",
            "X-Api-Key": api_key,
        },
        method="POST",
    )

    try:
        with urlopen(req, timeout=10) as resp:
            result = json.loads(resp.read())

        # Handle renewed license
        if "renewed_license" in result:
            with open(license_path, "w") as f:
                f.write(result["renewed_license"])

        # Handle revocation
        if result.get("status") == "revoked":
            # Remove license.dat — next session will show ACTIVATION_REQUIRED
            if os.path.exists(license_path):
                os.remove(license_path)

        # Update last heartbeat timestamp
        with open(last_hb_path, "w") as f:
            f.write(str(int(time.time())))

    except (URLError, Exception):
        # Network error — silently fail, try again next week
        pass


if __name__ == "__main__":
    main()
