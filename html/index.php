<?php

header("Content-Type: text/plain; charset=utf-8");

if (array_key_exists("SSL_DN", $_SERVER)) {
    echo "[{$_SERVER['VERIFIED']}] {$_SERVER['SSL_DN']}\n\n";
}

echo '$_SERVER = ';
var_export($_SERVER);
