#!/usr/bin/env python3
"""Cross-platform license verification. Python 3 stdlib only — zero pip dependencies.

This script is shipped in every Leopoldo bootstrap ZIP at .leopoldo/hooks/verify-license.py.
It is called by session-start.sh (bash wrapper) or directly from hooks.json (Windows).

Exit behavior:
  - Prints a single status line to stdout (LICENSE_VALID, ACTIVATION_REQUIRED, etc.)
  - Always exits 0 (hooks should not block Claude on internal errors)

Dependencies:
  - Python 3.6+ stdlib (json, hashlib, subprocess, os, platform, base64, tempfile, sys)
  - openssl CLI (Mac/Linux) or PowerShell .NET (Windows) for Ed25519 verification
"""
import json
import hashlib
import subprocess
import sys
import platform
import os
import base64
import tempfile
from datetime import datetime, timezone


def get_machine_id() -> str:
    """Get stable device identifier per OS."""
    system = platform.system()
    try:
        if system == "Darwin":
            r = subprocess.run(
                ["ioreg", "-rd1", "-c", "IOPlatformExpertDevice"],
                capture_output=True, text=True, timeout=5,
            )
            for line in r.stdout.splitlines():
                if "IOPlatformUUID" in line:
                    return line.split('"')[-2]
        elif system == "Linux":
            if os.path.exists("/etc/machine-id"):
                with open("/etc/machine-id") as f:
                    return f.read().strip()
        elif system == "Windows":
            r = subprocess.run(
                ["reg", "query",
                 "HKLM\\SOFTWARE\\Microsoft\\Cryptography",
                 "/v", "MachineGuid"],
                capture_output=True, text=True, timeout=5,
            )
            for line in r.stdout.splitlines():
                if "MachineGuid" in line:
                    return line.split()[-1]
    except Exception:
        pass
    return "unknown"


def get_fingerprint() -> str:
    """sha256(machine_id + os_username)."""
    machine_id = get_machine_id()
    username = os.environ.get("USER") or os.environ.get("USERNAME") or "unknown"
    return hashlib.sha256(f"{machine_id}{username}".encode()).hexdigest()


def verify_signature_openssl(payload_bytes: bytes, signature_bytes: bytes, pubkey_path: str) -> bool:
    """Verify Ed25519 signature using openssl CLI (Mac/Linux)."""
    payload_file = None
    sig_file = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".bin") as pf:
            pf.write(payload_bytes)
            payload_file = pf.name
        with tempfile.NamedTemporaryFile(delete=False, suffix=".bin") as sf:
            sf.write(signature_bytes)
            sig_file = sf.name

        r = subprocess.run(
            ["openssl", "pkeyutl", "-verify",
             "-pubin", "-inkey", pubkey_path,
             "-sigfile", sig_file, "-rawin", "-in", payload_file],
            capture_output=True, text=True, timeout=10,
        )
        return "Verified Successfully" in r.stdout or r.returncode == 0
    except Exception:
        return False
    finally:
        if payload_file and os.path.exists(payload_file):
            os.unlink(payload_file)
        if sig_file and os.path.exists(sig_file):
            os.unlink(sig_file)


def verify_signature_powershell(payload_bytes: bytes, signature_bytes: bytes, pubkey_path: str) -> bool:
    """Verify Ed25519 signature using PowerShell .NET (Windows)."""
    payload_file = None
    sig_file = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".bin") as pf:
            pf.write(payload_bytes)
            payload_file = pf.name
        with tempfile.NamedTemporaryFile(delete=False, suffix=".bin") as sf:
            sf.write(signature_bytes)
            sig_file = sf.name

        ps_script = f"""
        Add-Type -AssemblyName System.Security
        $pubPem = Get-Content '{pubkey_path}' -Raw
        $pubPem = $pubPem -replace '-----BEGIN PUBLIC KEY-----','' -replace '-----END PUBLIC KEY-----','' -replace "`n",'' -replace "`r",''
        $pubBytes = [Convert]::FromBase64String($pubPem)
        $payload = [System.IO.File]::ReadAllBytes('{payload_file}')
        $sig = [System.IO.File]::ReadAllBytes('{sig_file}')
        try {{
            $eddsa = [System.Security.Cryptography.Ed25519]::Create()
            $eddsa.ImportSubjectPublicKeyInfo($pubBytes, [ref]$null)
            $result = $eddsa.VerifyData($payload, $sig)
            Write-Output $result
        }} catch {{
            Write-Output "False"
        }}
        """
        r = subprocess.run(
            ["powershell", "-NoProfile", "-Command", ps_script],
            capture_output=True, text=True, timeout=10,
        )
        return r.stdout.strip() == "True"
    except Exception:
        return False
    finally:
        if payload_file and os.path.exists(payload_file):
            os.unlink(payload_file)
        if sig_file and os.path.exists(sig_file):
            os.unlink(sig_file)


def verify_signature(payload_bytes: bytes, signature_bytes: bytes, pubkey_path: str) -> bool:
    """Verify Ed25519 signature using platform-appropriate method."""
    if platform.system() == "Windows":
        return verify_signature_powershell(payload_bytes, signature_bytes, pubkey_path)
    return verify_signature_openssl(payload_bytes, signature_bytes, pubkey_path)


def validate_license_file(license_path: str, pubkey_path: str) -> dict | None:
    """Read and validate license.dat. Returns payload dict if valid, None otherwise."""
    if not os.path.exists(license_path):
        return None
    if not os.path.exists(pubkey_path):
        return None

    try:
        with open(license_path) as f:
            raw = base64.b64decode(f.read().strip())
        data = json.loads(raw)
        payload = data["payload"]
        signature = base64.b64decode(data["signature"])
        payload_bytes = json.dumps(payload, sort_keys=True).encode()

        if not verify_signature(payload_bytes, signature, pubkey_path):
            return None
        return payload
    except Exception:
        return None


def main():
    """Main entry point. Prints status to stdout."""
    license_path = ".leopoldo/license.dat"
    pubkey_path = ".leopoldo/leopoldo-public.pem"

    # 1. Check license exists
    if not os.path.exists(license_path):
        print("ACTIVATION_REQUIRED")
        return

    # 2. Validate signature
    payload = validate_license_file(license_path, pubkey_path)
    if payload is None:
        print("LICENSE_INVALID")
        return

    # 3. Verify device fingerprint
    current_fp = get_fingerprint()
    if current_fp != payload.get("device_fingerprint"):
        print("LICENSE_WRONG_DEVICE")
        return

    # 4. Check expiry
    expires_str = payload.get("expires_at")
    if expires_str:
        try:
            expires = datetime.fromisoformat(expires_str.replace("Z", "+00:00"))
            if datetime.now(timezone.utc) > expires:
                print("LICENSE_EXPIRED")
                return
        except Exception:
            pass

    # 5. All checks passed
    # Output payload as JSON for session-start.sh to parse
    print("LICENSE_VALID")
    print(json.dumps({
        "client_id": payload.get("client_id", ""),
        "products": payload.get("products", []),
        "expires_at": payload.get("expires_at", ""),
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Hooks should never block Claude
        print("LICENSE_CHECK_ERROR")
        sys.exit(0)
