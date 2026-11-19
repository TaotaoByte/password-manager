"""Create a disposable interoperability fixture, never a personal vault.

The public test master password is LocalVault-TEST-only. Output stays under build/.
Encryption and serialization are performed by the upstream KeePassXC CLI.
"""
import base64
from pathlib import Path
import subprocess
import uuid
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
folder = root / 'build' / 'test-vault'
folder.mkdir(parents=True, exist_ok=True)
file = ET.Element('KeePassFile')
meta = ET.SubElement(file, 'Meta')
ET.SubElement(meta, 'Generator').text = 'LocalVault disposable test fixture'
ET.SubElement(meta, 'DatabaseName').text = 'TEST ONLY - no real accounts'
group = ET.SubElement(ET.SubElement(file, 'Root'), 'Group')
ET.SubElement(group, 'UUID').text = base64.b64encode(uuid.uuid4().bytes).decode()
ET.SubElement(group, 'Name').text = 'Fixture'
entry = ET.SubElement(group, 'Entry')
ET.SubElement(entry, 'UUID').text = base64.b64encode(uuid.uuid4().bytes).decode()
for key, value in {
    'Title': 'LocalVault Test Form', 'UserName': 'fixture-user',
    'Password': 'Fixture-Password-42', 'AndroidApp': 'dev.localvault.fixture',
    'URL': 'https://example.invalid', 'Notes': 'PUBLIC SYNTHETIC DATA - never use for real accounts'
}.items():
    item = ET.SubElement(entry, 'String')
    ET.SubElement(item, 'Key').text = key
    ET.SubElement(item, 'Value').text = value
source = folder / 'fixture.xml'
output = folder / 'LocalVault-test.kdbx'
if output.exists():
    raise SystemExit('Fixture exists. Move it aside to preserve any test edits before recreating.')
ET.ElementTree(file).write(source, encoding='utf-8', xml_declaration=True)
result = subprocess.run([str(root / 'dist/windows/keepassxc-cli.exe'), 'import', '-p', '-t', '100',
                         str(source), str(output)], input='LocalVault-TEST-only\nLocalVault-TEST-only\n',
                        text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
if result.returncode:
    raise SystemExit(result.stderr)
print(output)
