<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<style type="text/css">
html, body {
    min-height: 100%;
}
body {
    background: #282828 url("/bootstrap/img/dark-bg.jpg") repeat scroll center top;
    color: #333;
    font-family: Arial, Verdana, Helvetica, sans-serif;
}
.login-page {
    min-height: 100vh;
    padding: 24px 16px;
}
.login-panel {
    width: 100%;
    max-width: 360px;
    margin: 8vh auto 0;
    padding: 24px 26px 24px;
    box-sizing: border-box;
    background: #f5f5f5;
    border: 0;
}
.login-title {
    margin: 0 0 6px;
    color: #333;
    font-size: 22px;
    font-weight: normal;
    line-height: 1.3;
    text-align: center;
}
.login-subtitle {
    margin: 0 0 24px;
    color: #777;
    font-size: 13px;
    text-align: center;
}
.login-form label {
    color: #555;
    font-size: 13px;
    font-weight: bold;
}
.login-form input[type="text"],
.login-form input[type="password"] {
    width: 100%;
    height: 42px;
    padding: 8px 10px;
    border: 1px solid #bbb;
    border-radius: 3px;
    box-sizing: border-box;
    font-size: 16px;
}
.login-form input:focus {
    border-color: #3a87ad;
    box-shadow: 0 0 3px rgba(58, 135, 173, .5);
    outline: none;
}
.password-row {
    position: relative;
}
.password-row input {
    padding-right: 66px;
}
.password-toggle {
    position: absolute;
    top: 4px;
    right: 4px;
    height: 34px;
    padding: 0 8px;
    color: #3a87ad;
    background: transparent;
    border: 0;
    font-size: 12px;
}
.login-error {
    display: none;
    margin: 0 0 18px;
    padding: 9px 12px;
    color: #b94a48;
    background: #f2dede;
    border: 1px solid #eed3d7;
    border-radius: 3px;
    font-size: 13px;
    line-height: 1.4;
}
.login-error.visible {
    display: block;
}
.login-submit {
    width: 100%;
    min-height: 42px;
    margin-top: 6px;
    font-size: 16px;
}
.login-footer {
    margin-top: 22px;
    color: #999;
    font-size: 11px;
    text-align: center;
}
@media (max-width: 480px) {
    .login-page {
        padding: 12px 10px;
    }
    .login-panel {
        margin-top: 5vh;
        padding: 20px 18px 22px;
    }
}
</style>
<script type="text/javascript">
function initial() {
    var error = '<% get_parameter("error"); %>';
    var errorBox = document.getElementById("loginError");
    var username = document.getElementById("username");
    var password = document.getElementById("password");

    if (error == "1") {
        errorBox.className = "login-error visible";
        password.focus();
    } else {
        username.focus();
    }
}

function togglePassword() {
    var password = document.getElementById("password");
    var button = document.getElementById("passwordToggle");
    if (password.type == "password") {
        password.type = "text";
        button.innerHTML = "隐藏";
    } else {
        password.type = "password";
        button.innerHTML = "显示";
    }
}
</script>
</head>
<body onload="initial()">
<div class="login-page">
    <div class="login-panel">
        <h1 class="login-title"><#Web_Title#></h1>
        <p class="login-subtitle">登录路由器管理页面</p>
        <div id="loginError" class="login-error" role="alert">用户名或密码错误，请重试。</div>
        <form class="login-form" method="post" action="Login.asp" autocomplete="on">
            <div class="control-group">
                <label for="username"><#menu5_13_username#></label>
                <input id="username" name="username" type="text" value="admin" autocomplete="username" autocapitalize="none" spellcheck="false" required>
            </div>
            <div class="control-group">
                <label for="password"><#menu5_13_password#></label>
                <div class="password-row">
                    <input id="password" name="password" type="password" autocomplete="current-password" required>
                    <button id="passwordToggle" class="password-toggle" type="button" onclick="togglePassword()">显示</button>
                </div>
            </div>
            <button class="btn btn-primary login-submit" type="submit"><#Login#></button>
        </form>
        <div class="login-footer"><#Web_Title#></div>
    </div>
</div>
</body>
</html>
