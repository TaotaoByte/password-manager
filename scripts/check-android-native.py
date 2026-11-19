"""Check every 64-bit APK native library's load/RELRO alignment for 16 KB devices."""
import argparse
import struct
import zipfile


def check_apk(path):
    count = 0
    with zipfile.ZipFile(path) as apk:
        for name in apk.namelist():
            if not name.startswith(("lib/arm64-v8a/", "lib/x86_64/")) or not name.endswith(".so"):
                continue
            data = apk.read(name)
            if data[:6] != b"\x7fELF\x02\x01":
                raise ValueError(f"Unexpected ELF format: {name}")
            offset = struct.unpack_from("<Q", data, 32)[0]
            entry_size, number = struct.unpack_from("<HH", data, 54)
            headers = [struct.unpack_from("<IIQQQQQQ", data, offset + i * entry_size)
                       for i in range(number)]
            loads = [h for h in headers if h[0] == 1]
            if not loads or any(h[7] < 16384 or (h[2] - h[3]) % 16384 for h in loads):
                raise ValueError(f"LOAD alignment below 16 KB: {name}")
            for relro in (h for h in headers if h[0] == 0x6474E552):
                end = relro[3] + relro[6]
                if end % 16384:
                    if any(h[1] & 2 and h[3] <= relro[3] < h[3] + h[6]
                           and h[3] + h[6] > end for h in loads):
                        raise ValueError(f"RELRO shares a trailing page with writable data: {name}")
            print(f"16 KB ELF alignment verified: {name}")
            count += 1
    if not count:
        raise ValueError("No 64-bit native libraries found in APK")
    print(f"Checked {count} libraries. Run zipalign -c -P 16 4 APK and test on a device too.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk")
    check_apk(parser.parse_args().apk)
