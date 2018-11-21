OPENSSL 证书签名工具
====

用法:

# 生成 ca:

    $ ./0-init-ca.sh <yourdomain.com>

在这个脚本末尾会调用 `./1-sign-site.sh yourdomain.com`，生成 "yourdomain.com" 和 "*.yourdomain.com" 的 https 证书。

# 配置 nginx

参考 `cert/site/<yourdomain.com>/nginx.conf`

**注意**: 证书吊销文件 `crl.pem` 的有效期默认是 365 天, 别忘了及时更新，否则 nginx 会**拒绝所有**请求。如果你不需要这个功能，把那一行注释掉。

# 生成 https 证书:

你已经可以用生成好的 https 证书了，位于 `cert/site/yourdomain.com/`.

如果你想给其他域名生成证书，你可以试试这样：

    $ ./1-sign-site.sh <another-domain.com>

注：自签名证书仅用于测试。生产环境可以考虑使用 Let's Encrypt 项目生成的免费证书。

# 生成客户端证书：

    $ ./2-sign-user.sh <cert-holder-name>

这个命令会给用户分配一个 PKCS#12 格式的证书 (p12 文件, 以及对应的密码), 可以在 Windows、MacOS、iOS、Android 导入。

每个证书都会分配一个序列号作为其唯一标识（用在吊销列表里），具体编号在 `cert/index.txt` 下可以看到，也可以用命令查看：

    openssl x509 -in cert/newcerts/<name>/cert.crt -serial | grep serial

Tips: 在 iOS 下，可以用系统自带的 邮件 App 来导入。

# 吊销证书

    $ ./3-revoke-user.sh <cert-holder-name>

`./cert/crl.pem` 会被更新，用于替换配置到 web 服务器的旧版本。别忘了重启 web 服务器。

Tips:

* 你可以修改 `./openssl.conf` 74行的 "default_crl_days" (过期时间)

* 如果你想恢复一个被吊销的证书，在 `cert/index.php` 找到对应的那一行，将开头的 'R'(Revoked) 改为 'V'(Valid), 删掉第三列（吊销时间）, 然后在 `./cert` 下执行这个命令来更新 `crl.pem`:

    openssl ca -config ../openssl.cnf -gencrl -out crl.pem

# 查看吊销列表的详细信息

    $ ./4-list-revoked-cert.sh

它会解析 crl.pem ，展示吊销证书列表（以 serial_no 编号）

# 更新 CRL 文件

    $ ./5-update-crl.sh

`./cert/crl.pem` 会被更新，用于替换配置到 web 服务器的旧版本。别忘了重启 web 服务器。

CRL 文件应当定期更新，而且最好是自动更新。

# 测试

你可以导入 PKCS#12 证书后用浏览器测试。简单点的话，也可以这样：

    $ ./6-curl-test-request.sh <cert-holder-name>

如果一切顺利，你会看到这样的信息（由 `html/index.php` 输出）:

```
HTTP/1.1 200 OK
Server: nginx/1.14.0 (Ubuntu)
Date: Wed, 21 Nov 2018 18:45:25 GMT
Content-Type: text/plain; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive

[SUCCESS] emailAddress=test1@dev.com,CN=test1,O=dev.com

$_SERVER = array (
      ...
      'SSL_DN' => 'emailAddress=test1@dev.com,CN=test1,O=dev.com',
      'VERIFIED' => 'SUCCESS',
      ...
)
```

# 已知问题

TODO: 不能为同一个名字重复颁发证书，待修复

# 特别感谢

[How to Create a CA and User Certificates for Your Organization](https://help.cloud.fabasoft.com/index.php?topic=doc/How-to-Create-a-CA-and-User-Certificates-for-Your-Organization-in-Fabasoft-Cloud/certificate-revocation-list-via-openssl.htm)
