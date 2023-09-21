#!/usr/bin/env bash
#BaseX EJR (migrated from python to bash)
#20230820_1739_(est) EJR
#prereqs
pip install mnemonic ecdsa pycryptodome pyperclip qrcode
#===========================================================================================================================
pf1() {
local arg1="$1"
local pycode=$(cat <<PYEOF
#!/usr/bin/env python3
#base64 private key to others
#20230815_1549_(est) EJR
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
import os, pyperclip, hashlib, base58, secrets, qrcode, subprocess, sys
from Crypto.Hash import RIPEMD160
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Secp256k1 Curve Parameters
a = 0
b = 7
p = 2 ** 256 - 2 ** 32 - 2 ** 9 - 2 ** 8 - 2 ** 7 - 2 ** 6 - 2 ** 4 - 1
n = 115792089237316195423570985008687907852837564279074904382605163141518161494337
g = {
  'x': 55066263022277343669578718895168534326250603453777594175500187360389116729240,
  'y': 32670510020758816978083085130507043184471273380659243275938904335757337482424
}
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Elliptic Curve Mathematics
def modinv(a, m = p):
    a = a % m if a < 0 else a
    prevy, y = 0, 1
    while a > 1:
        q = m // a
        y, prevy = prevy - q * y, y
        a, m = m % a, a
    return y
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
def double(point):
    slope = ((3 * point['x'] ** 2) * modinv((2 * point['y']))) % p
    x = (slope ** 2 - (2 * point['x'])) % p
    y = (slope * (point['x'] - x) - point['y']) % p
    return {'x': x, 'y': y}
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
def add(point1, point2):
    if point1 == point2:
        return double(point1)
    slope = ((point1['y'] - point2['y']) * modinv(point1['x'] - point2['x'])) % p
    x = (slope ** 2 - point1['x'] - point2['x']) % p
    y = ((slope * (point1['x'] - x)) - point1['y']) % p
    return {'x': x, 'y': y}
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
def multiply(k, point = g):
    current = point
    binary = format(k, 'b')[1:]
    for char in binary:
        current = double(current)
        if char == '1':
            current = add(current, point)
    return current
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Convert Private Key to WIF
def private_key_to_wif(private_key_hex):
    extended = "80" + private_key_hex + "01"
    checksum = hashlib.sha256(hashlib.sha256(bytes.fromhex(extended)).digest()).digest()[:4]
    extended_checksum = extended + checksum.hex()
    wif = base58.b58encode(bytes.fromhex(extended_checksum)).decode()
    return wif
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Hash160 Public Key Function
def hash160(data):
    # Convert hexadecimal string to byte sequence first
    binary = bytes.fromhex(data)

    # SHA-256
    sha256 = hashlib.sha256(binary).digest()

    # RIPEMD-160
    ripemd160 = RIPEMD160.new()
    ripemd160.update(sha256)
    hash160_bytes = ripemd160.digest()

    # Convert from byte sequence back to hexadecimal
    hash160_hex = hash160_bytes.hex()

    return hash160_hex
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Get user input for private key or generation option
choice = sys.argv[1]
if choice == '1':
    prvkeyhex = input("Enter a 64-character hexadecimal private key: ")
    if len(prvkeyhex) != 64:
        print("Invalid private key length.")
        exit()
elif choice == '2':
    # Generate a random 32-byte private key
    prvkeybytes = secrets.token_bytes(32)
    prvkeyhex = prvkeybytes.hex()
else:
    print("Invalid choice.")
    exit()
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Convert private key to bytes
prvkeybytes = bytes.fromhex(prvkeyhex)
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Generate public key from private key
prvkeyint = int.from_bytes(prvkeybytes, byteorder="big")
point = multiply(prvkeyint)
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Convert x and y values of the public key point to hexadecimal
x = format(point['x'], '064x')
y = format(point['y'], '064x')
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Compressed public key
prefix = '02' if point['y'] % 2 == 0 else '03'
pubkeyhex = prefix + x
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Hash160 of the public key
pubkey_hash160 = hash160(pubkeyhex) # Step 1
versioned_hash = '00' + pubkey_hash160  # Step 2
checksum = hashlib.sha256(hashlib.sha256(bytes.fromhex(versioned_hash)).digest()).digest()[:4]  # Step 3
final_address = versioned_hash + checksum.hex()  # Step 4
public_address = base58.b58encode(bytes.fromhex(final_address)).decode()  # Step 5
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
# Convert Private Key to WIF
wif = private_key_to_wif(prvkeyhex)
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .

# VARS
print(prvkeyhex, wif, pubkeyhex, pubkey_hash160, public_address, flush=True)

#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
#  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .

PYEOF
)
	#.............................................................................
	local output=$(python3 -c "$pycode" "$arg1")
	read -r prvkeyhex wif pubkeyhex pubkey_hash160 public_address <<< "$output"
	#.............................................................................
}
#===========================================================================================================================
	#.............................................................................
	#menu
	clear
	echo '(1) Enter Private Key'
	echo '(2) Generate New Private Key'
	read -n 1 pf1a1; echo; clear
	pf1 "$pf1a1"
	# Generate QR codes for various values
	clear; echo
	echo "Private Key: $prvkeyhex"
		qrencode -t ASCIIi $prvkeyhex; echo
	echo "WIF: $wif"
		qrencode -t ASCIIi "$wif"; echo
	echo "Public Key: $pubkeyhex"
		qrencode -t ASCIIi "$pubkeyhex"; echo
	echo "Public Key Hash160: $pubkey_hash160"
		qrencode -t ASCIIi "$pubkey_hash160"; echo
	echo "Public Address: $public_address"
		qrencode -t ASCIIi "$public_address"
	#..........................................
	basexfile="$HOME/Desktop/basex.txt"
	echo; echo "Append Data to $basexfile? [y/n]"
	read -n 1 zask; echo
	if [ "${zask,,}" = "n" ]; then  echo 'not saving...'; exit 0; fi
	echo 'saving.......'
	touch $basexfile
	echo '_______________________________________________________________________________________________________________________' >>$basexfile
	echo '~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~' >>$basexfile; echo >>$basexfile
	echo "Private Key: $prvkeyhex" >>$basexfile
		qrencode -t ASCIIi $prvkeyhex >>$basexfile; echo >>$basexfile
	echo "WIF: $wif" >>$basexfile
		qrencode -t ASCIIi "$wif" >>$basexfile; echo >>$basexfile
	echo "Public Key: $pubkeyhex" >>$basexfile
		qrencode -t ASCIIi "$pubkeyhex" >>$basexfile; echo >>$basexfile
	echo "Public Key Hash160: $pubkey_hash160" >>$basexfile
		qrencode -t ASCIIi "$pubkey_hash160" >>$basexfile; echo >>$basexfile
	echo "Public Address: $public_address" >>$basexfile
		qrencode -t ASCIIi "$public_address" >>$basexfile
	echo 'saved.......'



#===========================================================================================================================
