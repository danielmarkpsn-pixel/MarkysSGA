<?php
$root = __DIR__ . DIRECTORY_SEPARATOR . 'config' . DIRECTORY_SEPARATOR . 'jwt' . DIRECTORY_SEPARATOR;
if (!extension_loaded('openssl')) { fwrite(STDERR, "PHP OpenSSL extension unavailable\n"); exit(1); }
$key = openssl_pkey_new(['private_key_type' => OPENSSL_KEYTYPE_RSA, 'private_key_bits' => 2048]);
if (!$key || !openssl_pkey_export($key, $private)) { fwrite(STDERR, "Could not generate private key\n"); exit(1); }
$details = openssl_pkey_get_details($key);
if (!$details || empty($details['key'])) { fwrite(STDERR, "Could not generate public key\n"); exit(1); }
if (file_put_contents($root . 'private.pem', $private, LOCK_EX) === false || file_put_contents($root . 'public.pem', $details['key'], LOCK_EX) === false) { fwrite(STDERR, "Could not save keys\n"); exit(1); }
echo "JWT keys generated\n";
