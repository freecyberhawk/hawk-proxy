![Hawk proxy](inc/hawk-proxy.jpg)

# Hawk Proxy V1.1.0

### 🌐 Simple traffic forwarder through PHP & proxy servers

![Go](https://img.shields.io/badge/Made%20with-Go-blue?logo=go&logoColor=white)
![PHP](https://img.shields.io/badge/Works%20with-PHP-777bb4?logo=php&logoColor=white)
![Docker](https://img.shields.io/badge/Dockerized-yes-blue?logo=docker)
![License](https://img.shields.io/github/license/freecyberhawk/hawk-proxy)
![Stars](https://img.shields.io/github/stars/freecyberhawk/hawk-proxy?style=social)
---

## 👤 Author

**freecyberhawk**

- GitHub: [@freecyberhawk](https://github.com/freecyberhawk)

## 🌟 Show Your Support

If you found this project helpful, please give it a ⭐️ on [GitHub](https://github.com/freecyberhawk/hawk-proxy)!

## 🇬🇧 English

**hawk_proxy** is a lightweight PHP-based traffic redirection system.

It receives incoming HTTP traffic and forwards it to one of the predefined proxy servers (typically hosted on virtual private servers). If the first proxy fails, it automatically tries the next one.

## 📦 1 - Quick Install (VPS)

```bash
bash <(curl -Ls https://raw.githubusercontent.com/freecyberhawk/hawk-proxy/main/install.sh)
````


#### Install Manually Docker (Optionally)
- just if quick method stopped on docker installation!!!
```bash
bash <(curl -Ls https://get.docker.com)
```

![Hawk proxy](inc/secret_key.png)


## 🔧 2 - Host Config

1.Create a file named `.htaccess` on your shared hosting or source domain.
2. Create a file named `index.php` on your shared hosting or source domain.
3. Paste the following code inside it:
4. Replace the IPs and API key in the `$proxies` and `API_KEY` constants with your own values.

---

`.htaccess` file:
```text
RewriteRule . index.php [L]
```
`index.php` file:

```php
<?php

if ((isset($_SERVER['HTTP_USER_AGENT']) and empty($_SERVER['HTTP_USER_AGENT'])) or !isset($_SERVER['HTTP_USER_AGENT'])){
    http_response_code(403);
    exit("<h2>Access Denied</h2><br>You don't have permission to view this site.<br>Error code:403 forbidden");
}

$isTextHTML = str_contains(($_SERVER['HTTP_ACCEPT'] ?? ''), 'text/html');


// Change as need
$proxies = [
    'http://123.123.123.123:8080/proxy?url=',
    'http://124.124.124.124:8080/proxy?url=',
];


const API_KEY = 'MY_SECRET_API_KEY'; // Change this same as vps config


$targetPath = $_SERVER['SCRIPT_URL'] ?? '';
$encodedURL = urlencode('https://subscription-domain.com' . $targetPath);


$headers = [
    'X-API-Key: ' . API_KEY,
    'User-Agent: ' . $_SERVER['HTTP_USER_AGENT']
];
if ($isTextHTML) {
    $headers[] = 'Accept: text/html';
}

$response = null;
$code = 0;
$contentType = 'text/plain';


foreach ($proxies as $proxyBase) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $proxyBase . $encodedURL);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    $response = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
    curl_close($ch);

    if ($response !== false && $code === 200) {
        break;
    }
}


if ($response === false || $code !== 200) {
    http_response_code(502);
    exit("Both proxy servers failed. Try again later.");
}

http_response_code($code);
header("Content-Type: $contentType");
echo $response;
```

## Commands

- `hawk-proxy` up
- `hawk-proxy` logs 
- `hawk-proxy` down  
- `hawk-proxy` status


---

### 🚫 Uninstall

To completely remove hawk-proxy from your server:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/freecyberhawk/hawk-proxy/main/uninstall.sh)

---
