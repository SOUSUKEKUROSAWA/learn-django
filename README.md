# https://youtu.be/ZxMB6Njs3ck
- github
  - https://github.com/SteinOveHelset/puddle
# ⌨️ (0:02:20) Setting up
- manage.py
  - 管理タスクを実行するための一種のスクリプト
- asgi.py, wsgi.py
  - Webサーバーのエントリポイント
    - プロジェクトをライブサーバーに配置する
- settings.py
  - プロジェクト全体の構成ファイル
# ⌨️ (0:06:00) First app
- core
  - admin.py
    - DBモデルを登録する
  - apps.py
    - このアプリケーション専用の構成ファイル
- djangoに使用しているアプリケーションを伝えることができる
  - settings.py
    - INSTALLED_APPSに追加
- 引数：request
  - リクエスト情報全般を取得
- templatesディレクトリ
  - Djangoはsettings.pyで登録したアプリケーション内のtemplatesを自動で参照する
- templateの継承
  - ページタイトルとかも動的に変化させられる
# ⌨️ (0:24:51) Items
# ⌨️ (0:44:30) Item detail
# ⌨️ (0:55:56) Signing up
# ⌨️ (1:10:06) Logging in
# ⌨️ (1:15:44) Adding items
# ⌨️ (1:28:25) Dashboard
# ⌨️ (1:32:36) Delete items
# ⌨️ (1:36:58) Edit items
# ⌨️ (1:40:01) Searching
# ⌨️ (1:53:43) Communication
# ⌨️ (2:23:00) Summary

---

# Tips
- `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
  - mobileフレンドリーにする設定
- `href="{% url 'contact' %}"`
  - urls.pyでname指定したルートを設置できる