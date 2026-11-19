"""Download a large official archive in resumable ranges; verify the final digest.

Usage: python scripts/download.py URL OUTPUT --sha256 HEX [--workers 12]
Partial files are retained under OUTPUT.parts for a later retry.
"""
import argparse
import concurrent.futures
import hashlib
import os
from pathlib import Path
import re
import urllib.request


def download(url, output, sha256, workers=12):
    output = Path(output)
    algorithm, expected = (sha256.split(":", 1) if ":" in sha256 else ("sha256", sha256))
    if algorithm not in ("sha256", "sha1"):
        raise ValueError("Unsupported checksum algorithm")
    if output.exists() and hashlib.new(algorithm, output.read_bytes()).hexdigest() == expected:
        return
    request = urllib.request.Request(url, headers={"Range": "bytes=0-0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        match = re.fullmatch(r"bytes 0-0/(\d+)", response.headers.get("Content-Range", ""))
        if response.status != 206 or not match:
            raise RuntimeError("Server does not support verified range downloads")
        size = int(match[1])
        response.read()
    parts = output.with_name(output.name + ".parts")
    parts.mkdir(parents=True, exist_ok=True)
    chunk_size = 512 * 1024
    ranges = [(i, min(i + chunk_size, size)) for i in range(0, size, chunk_size)]

    def fetch(pair):
        start, end = pair
        part = parts / str(start)
        if part.exists() and part.stat().st_size == end - start:
            return part
        request = urllib.request.Request(url, headers={"Range": f"bytes={start}-{end - 1}"})
        for attempt in range(3):
            try:
                with urllib.request.urlopen(request, timeout=90) as response:
                    expected = f"bytes {start}-{end - 1}/{size}"
                    if response.status != 206 or response.headers.get("Content-Range") != expected:
                        raise RuntimeError("Unexpected range response")
                    data = response.read(end - start + 1)
                if len(data) != end - start:
                    raise RuntimeError("Incomplete range")
                part.write_bytes(data)
                return part
            except Exception:
                if attempt == 2:
                    raise

    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        for count, _ in enumerate(pool.map(fetch, ranges), 1):
            if count % 10 == 0 or count == len(ranges):
                print(f"{count}/{len(ranges)} ranges", flush=True)
    pending = output.with_name(output.name + ".pending")
    digest = hashlib.new(algorithm)
    with pending.open("wb") as dest:
        for start, _ in ranges:
            data = (parts / str(start)).read_bytes()
            digest.update(data)
            dest.write(data)
    if digest.hexdigest() != expected:
        pending.unlink()
        raise RuntimeError("Checksum mismatch; archive was not installed")
    os.replace(pending, output)
    print(f"{algorithm.upper()} verified: {output}", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("url")
    parser.add_argument("output")
    checksums = parser.add_mutually_exclusive_group(required=True)
    checksums.add_argument("--sha256")
    checksums.add_argument("--sha1", help="For Android SDK packages whose official metadata uses SHA-1")
    parser.add_argument("--workers", type=int, default=12)
    args = parser.parse_args()
    expected = args.sha256.lower() if args.sha256 else "sha1:" + args.sha1.lower()
    download(args.url, args.output, expected, args.workers)
